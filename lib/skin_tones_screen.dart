import 'dart:convert';
import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:http/http.dart' as http;
import 'package:webview_integrations/skin_tone_model.dart';
import 'package:webview_integrations/skin_tone_product_model.dart';
import 'package:webview_integrations/tone_tab_parsing.dart';
import 'package:webview_integrations/tone_type_model.dart';

class SkinToneFinderScreen extends StatefulWidget {
  const SkinToneFinderScreen({super.key});

  @override
  State<SkinToneFinderScreen> createState() => _SkinToneFinderScreenState();
}

class _SkinToneFinderScreenState extends State<SkinToneFinderScreen> {
  bool isAllowed = false;

  String? runningState = "Waiting for data...";
  String? errorState = "Waiting for data...";
  String? resultData = "Waiting for data...";
  int? selectedIndex;
  Map<String, String> hexColorTone = {
    "cooler": "A37772",
    "lighter": "DF9F86",
    "perfect fit": "B7775E",
    "warmer": "CB8B5E",
    "darker": "8F4F36"
  };
  String selectedTone = "perfect fit";
  SkinToneModel skinToneModel = SkinToneModel();
  ToneTypeModel toneTypeModel = ToneTypeModel();
  SkinToneProductModel skinToneProductModel = SkinToneProductModel();
  InAppWebViewController? webViewController;
  bool isLoadingProductt = true;
  ToneTab? _selectedToneTab;

  List<String> tabList = ["", ""];
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
    initData();
    super.initState();
  }

  initData() async {
    await getToneType();
    await getSkinTone();
  }

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

  getToneType() async {
    try {
      Uri fullUrl = Uri.parse(
          'https://magento-1231949-4398885.cloudwaysapps.com/en/rest/V1/products/attributes/tone_type');
      var res = await http.get(fullUrl, headers: {
        "Authorization": "Bearer hb2vxjo1ayu0agrkr97eprrl5rccqotc"
      });
      log(res.body, name: 'GET TONE');
      if (res.statusCode == 200) {
        setState(() {
          toneTypeModel = ToneTypeModel.fromJson(jsonDecode(res.body));
        });
      } else {
        log(res.statusCode.toString());
      }
    } catch (e) {
      log(e.toString(), name: 'GET TONE ERROR');
    }
  }

  getSkinTone() async {
    try {
      Uri fullUrl = Uri.parse(
          'https://magento-1231949-4398885.cloudwaysapps.com/en/rest/V1/products/attributes/skin_tone');
      var res = await http.get(fullUrl, headers: {
        "Authorization": "Bearer hb2vxjo1ayu0agrkr97eprrl5rccqotc"
      });
      log(res.body, name: 'GET SKIN TONE');
      if (res.statusCode == 200) {
        setState(() {
          skinToneModel = SkinToneModel.fromJson(jsonDecode(res.body));
        });
      } else {
        log(res.statusCode.toString());
      }
    } catch (e) {
      log(e.toString(), name: 'GET SKIN TONE ERROR');
    }
  }

  getProduct(String skinId, String toneTypeId) async {
    try {
      setState(() {
        isLoadingProductt = true;
        selectedIndex = null;
      });
      Uri fullUrl = Uri.parse(
          'https://magento-1231949-4398885.cloudwaysapps.com/rest/V1/products?searchCriteria[filter_groups][0][filters][0][field]=category_id&searchCriteria[filter_groups][0][filters][0][value]=451&searchCriteria[filter_groups][0][filters][0][condition_type]=eq&searchCriteria[filter_groups][1][filters][0][field]=type_id&searchCriteria[filter_groups][1][filters][0][value]=simple&searchCriteria[filter_groups][1][filters][0][condition_type]=eq&searchCriteria[filter_groups][2][filters][0][field]=skin_tone&searchCriteria[filter_groups][2][filters][0][value]=$skinId&searchCriteria[filter_groups][2][filters][0][condition_type]=eq&searchCriteria[filter_groups][3][filters][0][field]=tone_type&searchCriteria[filter_groups][3][filters][0][value]=$toneTypeId&searchCriteria[filter_groups][3][filters][0][condition_type]=finset');
      var res = await http.get(fullUrl, headers: {
        "Authorization": "Bearer hb2vxjo1ayu0agrkr97eprrl5rccqotc"
      });
      log(res.body, name: 'GET SKIN TONE PRODUCT');
      if (res.statusCode == 200) {
        setState(() {
          skinToneProductModel =
              SkinToneProductModel.fromJson(jsonDecode(res.body));
        });
      } else {
        log(res.statusCode.toString());
      }

      setState(() {
        isLoadingProductt = false;
      });
    } catch (e) {
      log(e.toString(), name: 'GET SKIN TONE PRODUCT ERROR');
      setState(() {
        isLoadingProductt = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: !isAllowed
          ? CircularProgressIndicator()
          : Stack(
              children: [
                InAppWebView(
                  initialUrlRequest: URLRequest(
                      url: WebUri(
                          'https://skin-analysis2.unveels-frontend.pages.dev/skin-tone-finder-web')),
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

                          getProduct(
                              skinToneModel.options!
                                      .where((e) =>
                                          e.label.toString().toLowerCase() ==
                                          jsonDecode(resultData!)["skinType"]
                                              .toString()
                                              .split(' ')[0]
                                              .toLowerCase())
                                      .first
                                      .value ??
                                  '',
                              toneTypeModel.options
                                      ?.where((e) =>
                                          e.label?.toLowerCase() ==
                                          selectedTone.toLowerCase())
                                      .first
                                      .value ??
                                  '');
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
                        ? Align(
                            alignment: Alignment.bottomCenter,
                            child: Container(
                              padding: EdgeInsets.all(15),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.end,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                      horizontal: 0,
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            Expanded(
                                              child: _ToneTabItemWidget(
                                                tab: ToneTab.values.first,
                                                isSelected: _selectedToneTab ==
                                                    ToneTab.values.first,
                                                onTap: (value) {
                                                  if (value !=
                                                      _selectedToneTab) {
                                                    setState(() {
                                                      _selectedToneTab = value;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 25,
                                              child: VerticalDivider(),
                                            ),
                                            Expanded(
                                              child: _ToneTabItemWidget(
                                                tab: ToneTab.values.last,
                                                isSelected: _selectedToneTab ==
                                                    ToneTab.values.last,
                                                onTap: (value) {
                                                  if (value !=
                                                      _selectedToneTab) {
                                                    setState(() {
                                                      _selectedToneTab = value;
                                                    });
                                                  }
                                                },
                                              ),
                                            ),
                                          ],
                                        ),
                                        const Divider(),
                                      ],
                                    ),
                                  ),
                                  InkWell(
                                      onTap: () {
                                        getProduct(
                                            "6679",
                                            toneTypeModel.options
                                                    ?.where((e) =>
                                                        e.label
                                                            ?.toLowerCase() ==
                                                        selectedTone
                                                            .toLowerCase())
                                                    .first
                                                    .value ??
                                                '');
                                      },
                                      child: Container(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: 10, vertical: 5),
                                        decoration: BoxDecoration(
                                            color: Colors.transparent,
                                            border:
                                                Border.all(color: Colors.white),
                                            borderRadius:
                                                BorderRadius.circular(25)),
                                        child: Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            Container(
                                              decoration: BoxDecoration(
                                                  shape: BoxShape.circle,
                                                  color: hexToColor(
                                                      jsonDecode(resultData!)[
                                                              "hexColor"] ??
                                                          '#FFFFFF')),
                                              height: 17,
                                              width: 17,
                                            ),
                                            SizedBox(
                                              width: 5,
                                            ),
                                            Text(
                                              '${jsonDecode(resultData!)["skinType"]} - ${skinToneModel.options!.where((e) => e.label.toString().toLowerCase() == jsonDecode(resultData!)["skinType"].toString().split(' ')[0].toLowerCase()).first.value} ',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  color: Colors.white),
                                            ),
                                          ],
                                        ),
                                      )),
                                  SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                      height: 50,
                                      child: ListView.builder(
                                        itemCount:
                                            toneTypeModel.options?.length ?? 0,
                                        shrinkWrap: true,
                                        scrollDirection: Axis.horizontal,
                                        itemBuilder: (context, index) {
                                          return InkWell(
                                            onTap: () {
                                              setState(() {
                                                selectedTone = (toneTypeModel
                                                            .options?[index]
                                                            .label ??
                                                        '-')
                                                    .toLowerCase();
                                                getProduct(
                                                    skinToneModel.options!
                                                            .where((e) =>
                                                                e.label
                                                                    .toString()
                                                                    .toLowerCase() ==
                                                                jsonDecode(resultData!)[
                                                                        "skinType"]
                                                                    .toString()
                                                                    .split(
                                                                        ' ')[0]
                                                                    .toLowerCase())
                                                            .first
                                                            .value ??
                                                        '',
                                                    toneTypeModel.options
                                                            ?.where((e) =>
                                                                e.label
                                                                    ?.toLowerCase() ==
                                                                selectedTone
                                                                    .toLowerCase())
                                                            .first
                                                            .value ??
                                                        '');
                                              });
                                            },
                                            child: AnimatedContainer(
                                              margin: EdgeInsets.symmetric(
                                                  vertical: selectedTone ==
                                                          (toneTypeModel
                                                                      .options?[
                                                                          index]
                                                                      .label ??
                                                                  '-')
                                                              .toLowerCase()
                                                      ? 10
                                                      : 15),
                                              duration:
                                                  Duration(milliseconds: 500),
                                              padding: EdgeInsets.symmetric(
                                                  horizontal: 5),
                                              decoration: BoxDecoration(
                                                  color: hexToColor(hexColorTone[
                                                          (toneTypeModel
                                                                      .options?[
                                                                          index]
                                                                      .label ??
                                                                  '-')
                                                              .toLowerCase()] ??
                                                      '#FFFFFF')),
                                              child: Center(
                                                child: Text(
                                                  toneTypeModel.options?[index]
                                                          .label ??
                                                      '-',
                                                  style: TextStyle(
                                                      color: Colors.white,
                                                      fontSize: 11,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                              ),
                                            ),
                                          );
                                        },
                                      )),
                                  SizedBox(
                                    height: 5,
                                  ),
                                  Container(
                                    height: 160,
                                    width: MediaQuery.of(context).size.width,
                                    child: isLoadingProductt
                                        ? Center(
                                            child: CircularProgressIndicator(
                                              valueColor:
                                                  AlwaysStoppedAnimation<Color>(
                                                      Colors.white),
                                            ),
                                          )
                                        : ListView.builder(
                                            shrinkWrap: true,
                                            physics:
                                                AlwaysScrollableScrollPhysics(),
                                            scrollDirection: Axis.horizontal,
                                            itemCount:
                                                skinToneProductModel.totalCount,
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () async {
                                                  await webViewController
                                                      ?.evaluateJavascript(
                                                          source: """
                window.flutter_inappwebview.callHandler('flutterDataHandler', '${skinToneProductModel.items?[index].customAttributes.where((e) => e.attributeCode == "hexacode").first.value ?? '#FFFFFF'}');
              """);
                                                  setState(() {
                                                    selectedIndex = index;
                                                  });
                                                },
                                                child: Container(
                                                  margin: EdgeInsets.only(
                                                      right: 10),
                                                  decoration: BoxDecoration(
                                                      border: Border.all(
                                                          width: 2,
                                                          color: selectedIndex ==
                                                                  index
                                                              ? Colors.yellow
                                                              : Colors
                                                                  .transparent)),
                                                  padding: EdgeInsets.all(5),
                                                  width: 150,
                                                  child: Column(
                                                    children: [
                                                      CachedNetworkImage(
                                                        width: 150,
                                                        height: 100,
                                                        imageUrl:
                                                            "https://magento-1231949-4398885.cloudwaysapps.com${skinToneProductModel.items?[index].mediaGalleryEntries?[0].file}",
                                                        placeholder:
                                                            (context, url) {
                                                          return Container(
                                                            color: Colors.white,
                                                            child: Center(
                                                                child: SizedBox(
                                                                    height: 25,
                                                                    width: 25,
                                                                    child:
                                                                        CircularProgressIndicator())),
                                                          );
                                                        },
                                                        errorWidget: (context,
                                                            url, error) {
                                                          return Container(
                                                            color: Colors.white,
                                                            child: Icon(
                                                                Icons.error),
                                                          );
                                                        },
                                                      ),
                                                      Text(
                                                        skinToneProductModel
                                                                .items?[index]
                                                                .name ??
                                                            '-',
                                                        style: TextStyle(
                                                            fontSize: 10,
                                                            color:
                                                                Colors.white),
                                                      ),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Text(
                                                            "${skinToneProductModel.items?[index].price ?? '-'}",
                                                            style: TextStyle(
                                                                fontSize: 9,
                                                                color: Colors
                                                                    .white),
                                                          )
                                                        ],
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  )
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

class _ToneTabItemWidget extends StatelessWidget {
  final ToneTab tab;
  final bool isSelected;
  final Function(ToneTab value) onTap;

  const _ToneTabItemWidget({
    required this.tab,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(tab);
      },
      child: Padding(
        padding: const EdgeInsets.symmetric(
          vertical: 6,
        ),
        child: Center(
          child: Text(
            tab.title,
            style: TextStyle(
              fontSize: 18,
              color: isSelected ? Colors.white : Colors.white.withOpacity(0.7),
            ),
          ),
        ),
      ),
    );
  }
}

class _SkinToneItemWidget extends StatelessWidget {
  final String title;
  final Color color;
  final bool isSelected;
  final Function(String value) onTap;

  const _SkinToneItemWidget({
    required this.title,
    required this.color,
    required this.isSelected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(title);
      },
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(
              vertical: 5,
              horizontal: 8,
            ),
            decoration: BoxDecoration(
              border: Border.all(
                color: isSelected ? Colors.white : Colors.transparent,
              ),
              borderRadius: BorderRadius.circular(99),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 12,
                  height: 12,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: color,
                  ),
                ),
                const SizedBox(
                  width: 5,
                ),
                Padding(
                  padding: const EdgeInsets.only(
                    top: 1,
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      color: Colors.white,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _MatchedToneItemWidget extends StatelessWidget {
  final String title;
  final Color color;
  final bool isSelected;
  final Function(String value) onTap;
  final double width;

  const _MatchedToneItemWidget({
    required this.title,
    required this.color,
    required this.isSelected,
    required this.onTap,
    required this.width,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        onTap(title);
      },
      child: Container(
        height: isSelected ? 40 : 26,
        width: width,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color,
          border: Border.all(
            color: isSelected ? Colors.white : Colors.transparent,
          ),
        ),
        child: Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: 14,
            color: Colors.white,
          ),
        ),
      ),
    );
  }
}
