import 'dart:developer';

import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:webview_integrations/face_analyzer_model.dart';

class WebViewScreen extends StatefulWidget {
  const WebViewScreen({super.key});

  @override
  State<WebViewScreen> createState() => _WebViewScreenState();
}

class _WebViewScreenState extends State<WebViewScreen> {
  bool isAllowed = false;

  String? runningState = "Waiting for data...";
  String? errorState = "Waiting for data...";
  String? resultData = "Waiting for data...";
  FaceAnalyzerModel? resultDataParsed;

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
                setState(() {
                  resultDataParsed =
                      FaceAnalyzerModel.fromJson(jsonDecode(resultData!));
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
                  initialUrlRequest: URLRequest(
                      url: WebUri(
                          'https://stunning-cuchufli-58fbf4.netlify.app/')),
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
                            padding: EdgeInsets.all(15),
                            decoration: BoxDecoration(color: Colors.white),
                            child: Center(
                              child: SingleChildScrollView(
                                  child: InkWell(
                                      onTap: () {
                                        Clipboard.setData(ClipboardData(
                                            text: resultData ?? '-'));
                                      },
                                      child: Text(resultData ?? '-'))),
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
