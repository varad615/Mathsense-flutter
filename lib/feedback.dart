import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class FeedbackPage extends StatefulWidget {
  const FeedbackPage({super.key});

  @override
  FeedbackPageState createState() => FeedbackPageState();
}

class FeedbackPageState extends State<FeedbackPage> {
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();

    // Initialize WebViewController
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            print('Page started loading: $url');
          },
          onPageFinished: (String url) {
            print('Page finished loading: $url');
          },
          onWebResourceError: (WebResourceError error) {
            print('''Error: ${error.description}''');
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://na01.safelinks.protection.outlook.com/?url=https%3A%2F%2Fdocs.google.com%2Fforms%2Fd%2Fe%2F1FAIpQLSecF2DgwUPt9KeroUh2-ByrZ_YKDbT2Sm-p5tD1xdVlPs9sRw%2Fviewform%3Fusp%3Dsf_link&data=05%7C02%7C%7C729ac9ab79d84ec3a27d08dcb9444eb0%7C84df9e7fe9f640afb435aaaaaaaaaaaa%7C1%7C0%7C638588950227379762%7CUnknown%7CTWFpbGZsb3d8eyJWIjoiMC4wLjAwMDAiLCJQIjoiV2luMzIiLCJBTiI6Ik1haWwiLCJXVCI6Mn0%3D%7C0%7C%7C%7C&sdata=EdmWVuC354%2FIay3EA0cfo1U8auCYZrJAxHLh2PQQ3i0%3D&reserved=0'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Feedback'),
      ),
      body: WebViewWidget(controller: _controller),
    );
  }
}
