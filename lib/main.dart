import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MaterialApp(home: SafeArea(child: AppBody()), debugShowCheckedModeBanner: false));

class AppBody extends StatefulWidget {
  const AppBody({super.key});
  @override
  State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {
  late final WebViewController controller;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) => setState(() => isLoading = true),
          onPageFinished: (url) => setState(() => isLoading = false),
        ),
      )
      ..loadRequest(Uri.parse('https://lightslategray-pheasant-815893.hostingersite.com/dashboard.html'));
  }

  @override
  Widget build(BuildContext context) {
    // PopScope بیک بٹن کو کنٹرول کرتا ہے
    return PopScope(
      canPop: false, // خود بخود بند ہونے سے روکتا ہے
      onPopInvoked: (didPop) async {
        if (didPop) return;
        if (await controller.canGoBack()) {
          controller.goBack(); // اگر ہسٹری ہے تو پیچھے جائے گا
        } else {
          // اگر ڈیش بورڈ پر ہے اور پیچھے کچھ نہیں، تو ایپ بند ہو جائے گی
          if (context.mounted) Navigator.of(context).pop(); 
        }
      },
      child: Scaffold(
        body: Stack(
          children: [
            WebViewWidget(controller: controller),
            if (isLoading) const Center(child: CircularProgressIndicator(color: Colors.green)),
          ],
        ),
      ),
    );
  }
}
