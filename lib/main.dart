import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  InAppWebViewController? webViewController;
  final String _appUrl = "https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php";

  @override
  void initState() {
    super.initState();
    // ایپ کی حالت (Background/Foreground) پر نظر رکھنے کے لیے
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  // جب بھی ایپ دوبارہ سامنے آئے گی، یہ فنکشن چلے گا
  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      // ویب سائٹ کو فوری ری لوڈ کریں تاکہ پن (PIN) دوبارہ مانگا جائے
      webViewController?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(_appUrl)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            // سیکیورٹی کے لیے کیشے کو کنٹرول کرنا
            cacheEnabled: false, 
            clearCache: true,
            // فائل ڈاؤن لوڈنگ کو روکنے کے لیے (اگر ضرورت ہو)
            useOnDownloadStart: true,
            allowsBackForwardNavigationGestures: false,
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onLoadStop: (controller, url) async {
            // صفحہ لوڈ ہونے کے بعد اگر آپ کچھ اضافی سیکیورٹی لگانا چاہیں
          },
        ),
      ),
    );
  }
}
