import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() {
  runApp(const MaterialApp(
    home: NoorAppHome(),
    debugShowCheckedModeBanner: false,
  ));
}

class NoorAppHome extends StatefulWidget {
  const NoorAppHome({super.key});

  @override
  State<NoorAppHome> createState() => _NoorAppHomeState();
}

class _NoorAppHomeState extends State<NoorAppHome> with WidgetsBindingObserver {
  late final WebViewController _controller;
  final String _appUrl = "https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php";

  @override
  void initState() {
    super.initState();
    // ایپ کی لائف سائیکل پر نظر رکھنے کے لیے آبزرور کا آغاز
    WidgetsBinding.instance.addObserver(this);

    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setBackgroundColor(const Color(0x00000000))
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {},
          onPageFinished: (String url) {},
          onWebResourceError: (WebResourceError error) {},
        ),
      )
      ..loadRequest(Uri.parse(_appUrl));
  }

  @override
  void dispose() {
    // آبزرور کو ختم کرنا
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // یہ فنکشن چیک کرتا ہے کہ ایپ کی حالت کب بدلی
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // جیسے ہی ایپ دوبارہ اوپن ہوگی، ڈومین خود بخود ری لوڈ ہو جائے گا
      // اس سے ویب سائٹ دوبارہ سیکیورٹی پن مانگے گی
      _controller.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // اوپر کا حصہ (Status Bar) کو محفوظ رکھنے کے لیے SafeArea
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
