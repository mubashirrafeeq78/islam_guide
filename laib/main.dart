import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MaterialApp(
      debugShowCheckedModeBanner: false, 
      home: Scaffold(body: SafeArea(child: SecureBrowser())),
    ));

class SecureBrowser extends StatefulWidget {
  const SecureBrowser({super.key});
  @override
  State<SecureBrowser> createState() => _SecureBrowserState();
}

class _SecureBrowserState extends State<SecureBrowser> {
  late final WebViewController controller;
  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(Colors.white)
      ..loadRequest(Uri.parse('https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php'));
  }
  @override
  Widget build(BuildContext context) {
    return WebViewWidget(controller: controller);
  }
}
