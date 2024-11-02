import 'dart:developer';

import 'dart:async';
import 'dart:convert';
import 'package:google_fonts/google_fonts.dart';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_integrations/asset_path.dart';
import 'package:webview_integrations/button_widget.dart';
import 'package:webview_integrations/color_config.dart';
import 'package:webview_integrations/face_analyzer_model.dart';

Color hexToColor(String hexString) {
  // Ensure the string is properly formatted
  hexString = hexString.toUpperCase().replaceAll('#', '');

  // If the hex code is only 6 characters (RRGGBB), add the 'FF' prefix for full opacity
  if (hexString.length == 6) {
    hexString = 'FF' + hexString;
  }

  // Parse the hex string to an integer and return the color
  return Color(int.parse(hexString, radix: 16));
}

class WebViewScreen extends StatefulWidget {
  const WebViewScreen(
      {super.key, required this.url, required this.personality});
  final String url;
  final bool personality;
  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isAllowed = false;

  static Map<String, String> personalityAnalysisResult = {
    "Extravert":
        "Individuals with an extravert personality are outgoing, energetic, and talkative. They thrive in social settings, seek excitement, and enjoy being the center of attention. Strong in communication, leadership, and relationship-building skills, Unveels suggests recommendations based on your extraversion.",
    "Neurotic":
        "Neuroticism reflects a tendency to experience negative emotions like anxiety, depression, and moodiness. People high in neuroticism may be more prone to worry and stress, while those low in neuroticism are more emotionally stable and resilient. Unveels offers a bespoke recommendation list based on your neuroticism.",
    "Agreable":
        "People with an agreeable personality are kind-hearted and compassionate, characterized by a strong desire to maintain harmonious relationships. They are cooperative, empathetic, and considerate towards others, making them valuable team players and supportive friends. Unveels has prepared a customized recommendation list based on your agreeable personality.",
    "Conscientious":
        "Individuals high in conscientiousness are organized, responsible, and goal-oriented. Known for their reliability, diligence, and attention to detail, they are diligent in their work and well-prepared. Unveels has unveiled the conscientious side of your personality and provides a recommended list based on it.",
    "Open":
        "Individuals with an open personality possess a vibrant imagination, curiosity, and eagerness to explore new ideas and experiences. They are creative, flexible, and adaptable, receptive to change and innovation. Unveels has prepared a recommendation list based on your open personality.",
  };
  String? runningState = "Waiting for data...";
  String? errorState = "Waiting for data...";
  String? resultData = "Waiting for data...";
  List<FaceAnalyzerModel> resultDataParsed = <FaceAnalyzerModel>[];
  Uint8List? imageBytes;

  InAppWebViewController? webViewController;
  Future<void> requestCameraPermission() async {
    var status = await Permission.camera.status;
    if (!status.isGranted) {
      await Permission.camera.request();
    }

    setState(() {
      isAllowed = true;
    });
  }

  void _launchURL(String? url) async {
    if (!await launch(url!)) throw 'Could not launch $url';
  }

  @override
  void initState() {
    requestCameraPermission();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("$runningState"),
        actions: [
          InkWell(
              onTap: () async {
                // String dataToSend = "Hello from Flutter!";
                // await webViewController!.evaluateJavascript(
                //     source: "receiveDataFromFlutter('$dataToSend');");
                // await webViewController!.reload();
                // setState(() {
                //   runningState = "Waiting for data...";
                //   errorState = "Waiting for data...";
                //   resultData = "Waiting for data...";
                // });
                log(resultData.toString());
                setState(() {
                  try {
                    resultDataParsed = FaceAnalyzerModel.fromJsonList(
                        json.decode(resultData!));
                    setState(() {
                      String tempBytes = resultDataParsed
                              .where((e) => e.name == "Image Data")
                              .first
                              .imageData ??
                          '';
                      imageBytes = base64Decode(tempBytes.contains(',')
                          ? tempBytes.split(',').last
                          : tempBytes);
                    });
                  } catch (e) {
                    log(e.toString());
                  }
                });
              },
              child: Icon(Icons.refresh))
        ],
      ),
      body: !isAllowed
          ? CircularProgressIndicator()
          : Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(url: WebUri(widget.url)),
                  //test-js.cibportofolio.com
                  // initialUrlRequest:
                  // URLRequest(url: WebUri(Uri.base.toString().replaceFirst("/#/", "/") + 'page.html')),
                  // initialFile: "assets/index.html",
                  onWebViewCreated: (controller) async {
                    webViewController = controller;
                    // Listen to JavaScript handler 'flutterDataHandler'
                    webViewController?.addJavaScriptHandler(
                      handlerName: 'detectionRun',
                      callback: (args) {
                        // Handle data sent from JavaScript here
                        setState(() {
                          runningState =
                              args.isNotEmpty ? args[0] : "No data received";
                        });
                      },
                    );
                    webViewController?.addJavaScriptHandler(
                      handlerName: 'detectionResult',
                      callback: (args) {
                        // Handle data sent from JavaScript here
                        setState(() {
                          resultData =
                              args.isNotEmpty ? args[0] : "No data received";
                          print(resultData);

                          log(resultData.toString());
                          setState(() {
                            try {
                              resultDataParsed = FaceAnalyzerModel.fromJsonList(
                                  json.decode(resultData!));
                              setState(() {
                                String tempBytes = resultDataParsed
                                        .where((e) => e.name == "Image Data")
                                        .first
                                        .imageData ??
                                    '';
                                imageBytes = base64Decode(
                                    tempBytes.contains(',')
                                        ? tempBytes.split(',').last
                                        : tempBytes);
                              });
                            } catch (e) {
                              log(e.toString());
                            }
                          });
                        });
                      },
                    );
                    webViewController?.addJavaScriptHandler(
                      handlerName: 'detectionError',
                      callback: (args) {
                        // Handle data sent from JavaScript here
                        setState(() {
                          errorState =
                              args.isNotEmpty ? args[0] : "No data received";
                        });
                      },
                    );
                  },
                  onLoadStart: (controller, url) async {
                    log('loading : $url');
                  },
                  onPermissionRequest: (controller, permissionRequest) async {
                    return PermissionResponse(
                        resources: permissionRequest.resources,
                        action: PermissionResponseAction.GRANT);
                  },
                  shouldOverrideUrlLoading:
                      (controller, navigationAction) async {
                    var uri = navigationAction.request.url!;

                    if (![
                      "http",
                      "https",
                      "file",
                      "chrome",
                      "data",
                      "javascript",
                      "about"
                    ].contains(uri.scheme)) {
                      if (await canLaunchUrl(uri)) {
                        // Launch the App
                        await launchUrl(
                          uri,
                        );
                        // and cancel the request
                        return NavigationActionPolicy.CANCEL;
                      }
                    }

                    return NavigationActionPolicy.ALLOW;
                  },

                  onLoadStop: (controller, url) async {},
                  onProgressChanged: (controller, progress) {},
                  onUpdateVisitedHistory: (controller, url, isReload) {},
                  onConsoleMessage: (controller, consoleMessage) {
                    print(consoleMessage);
                  },
                ),
                resultData != 'Waiting for data...' &&
                        errorState != "Waiting for data..."
                    ? Container(
                        padding: EdgeInsets.all(15),
                        decoration: BoxDecoration(color: Colors.white),
                        child: Center(
                          child: Text(errorState ?? '-'),
                        ),
                      )
                    : resultData != 'Waiting for data...' &&
                            runningState != "Waiting for data..."
                        ? Container(
                            padding: const EdgeInsets.only(
                              top:
                                  30, // padding to recording controller buttons
                            ),
                            color: Colors.black,
                            child: DefaultTabController(
                              length: 3,
                              child: Column(
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 15,
                                    ),
                                    child: Row(
                                      children: [
                                        Column(
                                          children: [
                                            ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(10),
                                              child: Image.memory(
                                                imageBytes!,
                                                width: 108,
                                                height: 108,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            Text(
                                              resultDataParsed
                                                      .where((e) =>
                                                          e.name ==
                                                          "Personality Finder")
                                                      .first
                                                      .outputLabel ??
                                                  '-',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 12,
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          width: 20,
                                        ),
                                        Expanded(
                                          child: Row(
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SvgPicture.asset(
                                                'assets/icons/has_tag_circle.svg',
                                              ),
                                              const SizedBox(
                                                width: 8,
                                              ),
                                              Expanded(
                                                child: Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "AI Personality Analysis :",
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                    Text(
                                                      personalityAnalysisResult[
                                                              resultDataParsed
                                                                      .where((e) =>
                                                                          e.name ==
                                                                          "Personality Finder")
                                                                      .first
                                                                      .outputLabel ??
                                                                  '-'] ??
                                                          '',
                                                      style: TextStyle(
                                                        color: Colors.white,
                                                        fontSize: 12,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 20,
                                  ),
                                  TabBar(
                                      indicatorSize: TabBarIndicatorSize.tab,
                                      unselectedLabelColor:
                                          const Color(0xFF9E9E9E),
                                      labelColor: ColorConfig.primary,
                                      indicatorColor: ColorConfig.primary,
                                      labelStyle: const TextStyle(
                                        fontSize: 16,
                                      ),
                                      padding: EdgeInsets.zero,
                                      labelPadding: EdgeInsets.zero,
                                      indicatorPadding: EdgeInsets.zero,
                                      dividerColor: const Color(0xFF9E9E9E),
                                      dividerHeight: 1.5,
                                      tabs: widget.personality
                                          ? PFTabBar.values.map((e) {
                                              return Tab(
                                                text: e.title,
                                              );
                                            }).toList()
                                          : PFTabBarNonPersnoality.values
                                              .map((e) {
                                              return Tab(
                                                text: e.title,
                                              );
                                            }).toList()),
                                  Expanded(
                                    child: TabBarView(
                                      children: [
                                        if (widget.personality)
                                          PFPersonalityAnalysisWidget(
                                              resultParsedData:
                                                  resultDataParsed),
                                        PFAttributesAnalysisWidget(
                                            resultParsedData: resultDataParsed),

                                        PfRecommendationsAnalysisWidget(),
                                        // PfRecommendationsAnalysisWidget(),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          )
                        : resultData == 'Waiting for data...' &&
                                runningState != "Waiting for data..."
                            ? Center(
                                child: CircularProgressIndicator(
                                  valueColor: AlwaysStoppedAnimation<Color>(
                                      Colors.white),
                                ),
                              )
                            : Container()
              ],
            ),
    );
  }
}

//
enum PFTabBar {
  personality,
  attributes,
  recommendations,
}

extension PFTabBarParsing on PFTabBar {
  String get title {
    switch (this) {
      case PFTabBar.personality:
        return 'Personality';
      case PFTabBar.attributes:
        return 'Attributes';
      case PFTabBar.recommendations:
        return 'Recommendations';
    }
  }
}

//
enum PFTabBarNonPersnoality {
  attributes,
  recommendations,
}

extension PFTabBarNonPersnoalityParsing on PFTabBarNonPersnoality {
  String get title {
    switch (this) {
      case PFTabBarNonPersnoality.attributes:
        return 'Attributes';
      case PFTabBarNonPersnoality.recommendations:
        return 'Recommendations';
    }
  }
}

class PFPersonalityAnalysisWidget extends StatelessWidget {
  const PFPersonalityAnalysisWidget(
      {super.key, required this.resultParsedData});
  final List<FaceAnalyzerModel> resultParsedData;

  static Map<String, String> descriptionPersonality = {
    "Extravert":
        "An extravert personality provides insights into an individual's social behaviour and interaction preferences. Extraverts are known for their outgoing, energetic, and talkative nature. They thrive in social settings, seek excitement, and enjoy being the center of attention. Extraverts are often described as sociable, assertive, and enthusiastic individuals who are comfortable in group settings and have a wide circle of friends.  This also delves into the extraversion traits; highlighting that they're strong in communication, leadership, and relationship-building skills.  Therefore, here's what Unveels suggests for you based on your Extraversio",
    "Neurotic":
        "Neuroticism is indicative of an emotional individual who feels deeply and has a tendency to worry and be self-conscious.Low scorers tend to be more resilient to change and keep calm under stress.",
    "Agreable":
        "Agreeableness speaks to kindhearted, sympathetic individuals who get along well with others.Low scorers tend to be competitive and have a harder time maintaining stable relationships.",
    "Conscientious":
        "Conscientiousness speaks to the reliable, hardworking personality type that exercises self-discipline and self-control in order to achieve their goals.Low scorers tend to see rules as restricting and confining, and have more selfish tendencies.",
    "Open":
        "Openness to Experience is representative of the imaginative, creative minds that remain curious to the world around them.High scorers are imaginative, curious minds who love to try new things.",
  };
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.only(
        top: 20,
      ),
      child: Column(
        children: [
          Column(
            children: [
              Center(
                child: Text(
                  "Main 5 Personality Traits",
                  style: GoogleFonts.roboto(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              const SizedBox(
                height: 18,
              ),
              Center(
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    _CircularChartBarWidget(
                      height: 140,
                      width: 140,
                      color: ColorConfig.yellow,
                      value: resultParsedData
                              .where((element) =>
                                  element.name == "Personality Finder")
                              .first
                              .outputData?["0"] ??
                          0.0,
                    ),
                    _CircularChartBarWidget(
                      height: 160,
                      width: 160,
                      color: ColorConfig.pink,
                      value: resultParsedData
                              .where((element) =>
                                  element.name == "Personality Finder")
                              .first
                              .outputData?["1"] ??
                          0.0,
                    ),
                    _CircularChartBarWidget(
                      height: 180,
                      width: 180,
                      color: ColorConfig.oceanBlue,
                      value: resultParsedData
                              .where((element) =>
                                  element.name == "Personality Finder")
                              .first
                              .outputData?["2"] ??
                          0.0,
                    ),
                    _CircularChartBarWidget(
                      height: 200,
                      width: 200,
                      color: ColorConfig.green,
                      value: resultParsedData
                              .where((element) =>
                                  element.name == "Personality Finder")
                              .first
                              .outputData?["3"] ??
                          0.0,
                    ),
                    _CircularChartBarWidget(
                      height: 220,
                      width: 220,
                      color: ColorConfig.purple,
                      value: resultParsedData
                              .where((element) =>
                                  element.name == "Personality Finder")
                              .first
                              .outputData?["4"] ??
                          0.0,
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: 20,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          _LegendItemWidget(
                            color: ColorConfig.yellow,
                            value: ((resultParsedData
                                            .where((element) =>
                                                element.name ==
                                                "Personality Finder")
                                            .first
                                            .outputData?["0"] ??
                                        0.0) *
                                    100.0)
                                .toInt(),
                            label: resultParsedData
                                    .where((element) =>
                                        element.name == "Personality Finder")
                                    .first
                                    .labels?[0] ??
                                '-',
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          _LegendItemWidget(
                            color: ColorConfig.pink,
                            value: ((resultParsedData
                                            .where((element) =>
                                                element.name ==
                                                "Personality Finder")
                                            .first
                                            .outputData?["1"] ??
                                        0.0) *
                                    100.0)
                                .toInt(),
                            label: resultParsedData
                                    .where((element) =>
                                        element.name == "Personality Finder")
                                    .first
                                    .labels?[1] ??
                                '-',
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          _LegendItemWidget(
                            color: ColorConfig.oceanBlue,
                            value: ((resultParsedData
                                            .where((element) =>
                                                element.name ==
                                                "Personality Finder")
                                            .first
                                            .outputData?["2"] ??
                                        0.0) *
                                    100.0)
                                .toInt(),
                            label: resultParsedData
                                    .where((element) =>
                                        element.name == "Personality Finder")
                                    .first
                                    .labels?[2] ??
                                '-',
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                      width: 20,
                    ),
                    Expanded(
                      child: Column(
                        children: [
                          _LegendItemWidget(
                            color: ColorConfig.green,
                            value: ((resultParsedData
                                            .where((element) =>
                                                element.name ==
                                                "Personality Finder")
                                            .first
                                            .outputData?["3"] ??
                                        0.0) *
                                    100.0)
                                .toInt(),
                            label: resultParsedData
                                    .where((element) =>
                                        element.name == "Personality Finder")
                                    .first
                                    .labels?[3] ??
                                '-',
                          ),
                          SizedBox(
                            height: 15,
                          ),
                          _LegendItemWidget(
                            color: ColorConfig.purple,
                            value: ((resultParsedData
                                            .where((element) =>
                                                element.name ==
                                                "Personality Finder")
                                            .first
                                            .outputData?["4"] ??
                                        0.0) *
                                    100.0)
                                .toInt(),
                            label: resultParsedData
                                    .where((element) =>
                                        element.name == "Personality Finder")
                                    .first
                                    .labels?[4] ??
                                '-',
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          ListView.builder(
            shrinkWrap: true,
            physics: NeverScrollableScrollPhysics(),
            itemCount: resultParsedData
                    .where((element) => element.name == "Personality Finder")
                    .first
                    .labels
                    ?.length ??
                0,
            itemBuilder: (context, index) {
              return PFAnalysisDetailsWidget(
                title: resultParsedData
                        .where(
                            (element) => element.name == "Personality Finder")
                        .first
                        .labels?[index] ??
                    '',
                description: descriptionPersonality[resultParsedData
                            .where((element) =>
                                element.name == "Personality Finder")
                            .first
                            .labels?[index] ??
                        ''] ??
                    '',
                percent: resultParsedData
                        .where(
                            (element) => element.name == "Personality Finder")
                        .first
                        .outputData?[index.toString()] ??
                    0.0,
              );
            },
          )
        ],
      ),
    );
  }
}

class _LegendItemWidget extends StatelessWidget {
  final Color color;
  final int value;
  final String label;

  const _LegendItemWidget({
    required this.color,
    required this.value,
    required this.label,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          height: 32,
          width: 32,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(4),
          ),
          child: Text(
            "$value%",
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
              fontWeight: FontWeight.w500,
            ),
          ),
        ),
        const SizedBox(
          width: 10,
        ),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 14,
            ),
          ),
        ),
      ],
    );
  }
}

class _CircularChartBarWidget extends StatelessWidget {
  final double height, width, value;
  final Color color;

  const _CircularChartBarWidget({
    required this.height,
    required this.width,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: height,
      width: width,
      child: Transform.rotate(
        angle: 1.5,
        child: CircularProgressIndicator(
          color: color,
          value: value,
          strokeCap: StrokeCap.round,
          strokeWidth: 6,
        ),
      ),
    );
  }
}

class PFAnalysisDetailsWidget extends StatelessWidget {
  final String title;
  final String description;
  final double percent;

  const PFAnalysisDetailsWidget(
      {super.key,
      required this.title,
      required this.description,
      required this.percent});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Divider(
                height: 40,
              ),
              Row(
                children: [
                  Image.asset(
                    'assets/icons/chevron_down.png',
                    height: 25,
                    width: 25,
                  ),
                  const SizedBox(
                    width: 10,
                  ),
                  Text(
                    title,
                    style: const TextStyle(fontSize: 32, color: Colors.white),
                  ),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              const Text(
                "Description",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              Text(
                description,
                style: const TextStyle(fontSize: 14, color: Colors.white),
              ),
              const SizedBox(
                height: 30,
              ),
              const Text(
                "Severity",
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: Colors.white),
              ),
              const SizedBox(
                height: 5,
              ),
              Text(
                '${NumberFormat.decimalPatternDigits(decimalDigits: 2).format(percent * 100)}%',
                style: TextStyle(
                  fontSize: 14,
                  color: percent > 0.5
                      ? ColorConfig.greenSuccess
                      : percent > 0.3
                          ? Colors.orange
                          : ColorConfig.redError,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

class PFAttributesAnalysisWidget extends StatelessWidget {
  const PFAttributesAnalysisWidget({super.key, required this.resultParsedData});
  final List<FaceAnalyzerModel> resultParsedData;
  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: 20,
        horizontal: 15,
      ),
      child: Column(
        children: [
          _BodyItemWidget(
            title: "Face",
            iconPath: IconPath.face,
            leftChildren: [
              _DetailBodyItem(
                title: "Face Shape",
                value: resultParsedData
                        .where((element) => element.name == "Face Shape")
                        .firstOrNull
                        ?.outputLabel ??
                    '',
              ),
            ],
            rightChildren: [
              _DetailBodyItem(
                title: "Skin Tone",
                value: resultParsedData
                        .where((element) => element.name == "Skin Tone")
                        .firstOrNull
                        ?.outputLabel ??
                    '-',
              ),
            ],
          ),
          const Divider(
            height: 50,
          ),
          _BodyItemWidget(
            title: "Eyes",
            iconPath: IconPath.eye,
            leftChildren: [
              _DetailBodyItem(
                title: "Eye Shape",
                value: resultParsedData
                        .where((element) => element.name == "Eye Shape")
                        .firstOrNull
                        ?.outputLabel ??
                    '-',
              ),
              _DetailBodyItem(
                title: "Eye Angle",
                value: resultParsedData
                        .where((element) => element.name == "Eye Angle")
                        .firstOrNull
                        ?.outputLabel ??
                    '-',
              ),
              _DetailBodyItem(
                title: "Eyelid",
                value: resultParsedData
                        .where((element) => element.name == "Eye Lid")
                        .firstOrNull
                        ?.outputLabel ??
                    '-',
              ),
            ],
            rightChildren: [
              _DetailBodyItem(
                title: "Eye Size",
                value: resultParsedData
                        .where((element) => element.name == "Eye Size")
                        .firstOrNull
                        ?.outputLabel ??
                    '-',
              ),
              _DetailBodyItem(
                title: "Eye Distance",
                value: resultParsedData
                        .where((element) => element.name == "Eye Distance")
                        .firstOrNull
                        ?.outputLabel ??
                    '-',
              ),
              _DetailBodyItem(
                title: "Eye Color",
                valueWidget: Container(
                  height: 28,
                  color: hexToColor(resultParsedData
                          .where(
                              (element) => element.name == "Average Eye Color")
                          .firstOrNull
                          ?.outputColor ??
                      '#ffffff'),
                ),
              ),
            ],
          ),
          const Divider(
            height: 50,
          ),
          _BodyItemWidget(
            title: "Brows",
            iconPath: IconPath.brow,
            leftChildren: [
              _DetailBodyItem(
                title: "Eyebrow Shape",
                value: resultParsedData
                        .where((element) => element.name == "Eyebrow Shape")
                        .firstOrNull
                        ?.outputLabel ??
                    '-',
              ),
              _DetailBodyItem(
                title: "Eyebrow Distance",
                value: resultParsedData
                        .where((element) => element.name == "Eyebrow Distance")
                        .firstOrNull
                        ?.outputLabel ??
                    '-',
              ),
            ],
            rightChildren: [
              _DetailBodyItem(
                title: "Thickness",
                value: resultParsedData
                        .where((element) => element.name == "Thickness")
                        .firstOrNull
                        ?.outputLabel ??
                    '-',
              ),
              _DetailBodyItem(
                title: "Eyebrow color",
                valueWidget: Container(
                  height: 28,
                  color: hexToColor(resultParsedData
                          .where((element) =>
                              element.name == "Average Eyebrow Color")
                          .firstOrNull
                          ?.outputColor ??
                      '#ffffff'), //Average Eyebrow Color
                ),
              ),
            ],
          ),
          const Divider(
            height: 50,
          ),
          _BodyItemWidget(
            title: "Lips",
            iconPath: IconPath.lip,
            leftChildren: [
              _DetailBodyItem(
                title: "Lip shape",
                value: resultParsedData
                        .where((element) => element.name == "Lip")
                        .firstOrNull
                        ?.outputLabel ??
                    '-',
              ),
            ],
            rightChildren: [
              _DetailBodyItem(
                title: "Lip color",
                valueWidget: Container(
                  height: 28,
                  color: hexToColor(resultParsedData
                          .where(
                              (element) => element.name == "Average Lip Color")
                          .firstOrNull
                          ?.outputColor ??
                      '#ffffff'),
                ),
              ),
            ],
          ),
          const Divider(
            height: 50,
          ),
          _BodyItemWidget(
            title: "Cheekbones",
            iconPath: IconPath.cheekbones,
            leftChildren: [
              _DetailBodyItem(
                title: "Cheek bones",
                value: resultParsedData
                        .where((element) => element.name == "Cheeks Bones")
                        .firstOrNull
                        ?.outputLabel ??
                    '-',
              ),
            ],
          ),
          const Divider(
            height: 50,
          ),
          _BodyItemWidget(
            title: "Nose",
            iconPath: IconPath.nose,
            leftChildren: [
              _DetailBodyItem(
                title: "Nose Shape",
                value: resultParsedData
                        .where((element) => element.name == "Nose Shape")
                        .firstOrNull
                        ?.outputLabel ??
                    '-',
              ),
            ],
          ),
          const Divider(
            height: 50,
          ),
          _BodyItemWidget(
            title: "Hair",
            iconPath: IconPath.hair,
            leftChildren: [
              _DetailBodyItem(
                title: "Face Shape",
                valueWidget: Container(
                  height: 28,
                  color: const Color(0xFF473209),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _BodyItemWidget extends StatelessWidget {
  final String iconPath;
  final String title;
  final List<Widget> leftChildren;
  final List<Widget> rightChildren;

  const _BodyItemWidget({
    required this.iconPath,
    required this.title,
    this.leftChildren = const [],
    this.rightChildren = const [],
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            SvgPicture.asset(
              iconPath,
            ),
            const SizedBox(
              width: 16,
            ),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(
                  fontSize: 32,
                  color: Colors.white,
                ),
              ),
            )
          ],
        ),
        const SizedBox(
          height: 18,
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: leftChildren.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 10,
                  );
                },
                itemBuilder: (context, index) {
                  return leftChildren[index];
                },
              ),
            ),
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: MediaQuery.sizeOf(context).width * 0.4,
              ),
              child: ListView.separated(
                shrinkWrap: true,
                primary: false,
                physics: const NeverScrollableScrollPhysics(),
                padding: EdgeInsets.zero,
                itemCount: rightChildren.length,
                separatorBuilder: (context, index) {
                  return const SizedBox(
                    height: 10,
                  );
                },
                itemBuilder: (context, index) {
                  return rightChildren[index];
                },
              ),
            ),
          ],
        ),
      ],
    );
  }
}

class _DetailBodyItem extends StatelessWidget {
  final String title;
  final String? value;
  final Widget? valueWidget;

  const _DetailBodyItem({
    required this.title,
    this.value,
    this.valueWidget,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
        if (valueWidget != null) ...[
          const SizedBox(
            height: 4,
          ),
          valueWidget!,
        ],
        if (value != null) ...[
          const SizedBox(
            height: 4,
          ),
          Text(
            "• $value",
            style: const TextStyle(
              fontSize: 14,
              color: Colors.white,
            ),
          ),
        ],
      ],
    );
  }
}

class PfRecommendationsAnalysisWidget extends StatelessWidget {
  const PfRecommendationsAnalysisWidget({super.key});

  @override
  Widget build(BuildContext context) {
    return const SingleChildScrollView(
      padding: EdgeInsets.symmetric(
        vertical: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _ProductItemWidget(
            title: "Perfumes Recommendations",
          ),
          SizedBox(
            height: 30,
          ),
          _ProductItemWidget(
            title: "Look Recommendations",
            description:
                "A bold red lipstick and defined brows, mirror your strong, vibrant personality",
          ),
          SizedBox(
            height: 30,
          ),
          _ProductItemWidget(
            title: "Lip Color Recommendations",
            description: "The best lip color for you are orange shades",
          ),
          SizedBox(
            height: 30,
          ),
          _ProductItemWidget(
            title: "Accessories Recommendations",
          ),
        ],
      ),
    );
  }
}

class _ProductItemWidget extends StatelessWidget {
  final String title;
  final String? description;

  const _ProductItemWidget({
    required this.title,
    this.description,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
            horizontal: 15,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              if (description != null) ...[
                const SizedBox(
                  height: 6,
                ),
                Text(
                  description!,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(
          height: 16,
        ),
        SizedBox(
          height: 242,
          child: ListView.separated(
            itemCount: 10,
            shrinkWrap: true,
            primary: false,
            scrollDirection: Axis.horizontal,
            separatorBuilder: (context, index) {
              return const SizedBox(
                width: 10,
              );
            },
            itemBuilder: (context, index) {
              final isFirst = index == 0;
              final isEnd = index == 10 - 1;

              return Padding(
                padding: EdgeInsets.only(
                  left: isFirst ? 15 : 0,
                  right: isEnd ? 15 : 0,
                ),
                child: const PFProductItemWidget(),
              );
            },
          ),
        ),
      ],
    );
  }
}

class PFProductItemWidget extends StatelessWidget {
  const PFProductItemWidget({
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 242,
      width: 151,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Image.asset(
            ImagePath.productExample,
            height: 242 * 0.65,
            fit: BoxFit.cover,
          ),
          const SizedBox(
            height: 3,
          ),
          Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Item name Tom Ford",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Colors.white,
                      ),
                    ),
                    Text(
                      "Brand name",
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 8,
                        color: Colors.white.withOpacity(0.6),
                      ),
                    ),
                  ],
                ),
              ),
              const Text(
                "\$15",
                style: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          const SizedBox(
            height: 6,
          ),
          SvgPicture.asset(
            IconPath.fourStarsExample,
          ),
          const Spacer(),
          const Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Expanded(
                child: ButtonWidget(
                  text: "ADD TO CART",
                  backgroundColor: Colors.transparent,
                  borderColor: Colors.white,
                  height: 27,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
              SizedBox(
                width: 5,
              ),
              Expanded(
                child: ButtonWidget(
                  text: "SEE\nIMPROVEMENT",
                  backgroundColor: Colors.white,
                  height: 27,
                  style: TextStyle(
                    fontSize: 8,
                    fontWeight: FontWeight.w600,
                    color: Colors.black,
                  ),
                  padding: EdgeInsets.symmetric(
                    vertical: 0,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
