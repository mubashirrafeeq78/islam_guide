import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MaterialApp(home: WebViewPage(), debugShowCheckedModeBanner: false));

class WebViewPage extends StatefulWidget {
  const WebViewPage({super.key});
  @override
  State<WebViewPage> createState() => _WebViewPageState();
}

class _WebViewPageState extends State<WebViewPage> {
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..loadRequest(Uri.parse('https://2092-files.hstgr.io/splash_screen.html')); 
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(body: SafeArea(child: WebViewWidget(controller: controller)));
  }
}
