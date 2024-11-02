import 'package:flutter/material.dart';
import 'package:webview_integrations/skin_tones_screen.dart';
import 'package:webview_integrations/face_analyzer_web.dart';

class ChooseFeatures extends StatefulWidget {
  const ChooseFeatures({super.key});

  @override
  State<ChooseFeatures> createState() => _ChooseFeaturesState();
}

class _ChooseFeaturesState extends State<ChooseFeatures> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Unveels'),
      ),
      body: Column(
        children: [
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WebViewScreen(
                              url:
                                  'https://skin-analysis2.unveels-frontend.pages.dev/personality-finder-web',
                              personality: true,
                            )));
              },
              child: Text('Personality Finder')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const WebViewScreen(
                              url:
                                  'https://skin-analysis2.unveels-frontend.pages.dev/personality-finder-web',
                              personality: false,
                            )));
              },
              child: Text('Face Analyzer')),
          ElevatedButton(
              onPressed: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const SkinToneFinderScreen()));
              },
              child: Text('Skin Tone Finder')),
        ],
      ),
    );
  }
}
