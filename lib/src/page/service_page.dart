import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class ServicePage extends StatelessWidget {
  String url;
  ServicePage({@required this.url});

  @override
  Widget build(BuildContext context) {
    print(url);
    return WebView(
      initialUrl: 'https://kr.investing.com' + url,
      javascriptMode: JavascriptMode.unrestricted,
    );
  }
}
