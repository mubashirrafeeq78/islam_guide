import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'dart:io';
import 'dart:async';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WebViewApp(),
  ));
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});
  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> with SingleTickerProviderStateMixin {
  InAppWebViewController? webViewController;
  bool isOffline = false;
  bool isLoading = true;
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    // بلنکنگ اینیمیشن کے لیے کنٹرولر
    _blinkController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1),
    )..repeat(reverse: true);

    // ہر 5 سیکنڈ بعد انٹرنیٹ چیک کرنے کا ٹائمر تاکہ خود بخود نوٹیفیکیشن غائب/ظاہر ہو
    Timer.periodic(const Duration(seconds: 5), (timer) async {
      checkConnectivity();
    });
  }

  Future<void> checkConnectivity() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        if (isOffline) setState(() => isOffline = false);
      }
    } on SocketException catch (_) {
      if (!isOffline) setState(() => isOffline = true);
    }
  }

  @override
  void dispose() {
    _blinkController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // آپ کا مین پروجیکٹ (ویب ویو) جو ہمیشہ کھلا رہے گا
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php"),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                domStorageEnabled: true,
                cacheEnabled: true,
              ),
              onWebViewCreated: (c) => webViewController = c,
              onLoadStart: (c, u) => setState(() => isLoading = true),
              onLoadStop: (c, u) => setState(() => isLoading = false),
              onReceivedError: (c, r, e) => checkConnectivity(),
            ),

            // لوڈنگ انڈیکیٹر
            if (isLoading) const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

            // بلنکنگ نوٹیفیکیشن (صرف مکمل انٹرنیٹ بند ہونے پر نظر آئے گا)
            if (isOffline)
              Positioned(
                top: 20,
                left: 20,
                right: 20,
                child: FadeTransition(
                  opacity: _blinkController,
                  child: Container(
                    padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                    decoration: BoxDecoration(
                      color: Colors.red.withOpacity(0.8),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(Icons.wifi_off, color: Colors.white, size: 18),
                        SizedBox(width: 10),
                        Text(
                          "No Internet Connection",
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 14),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
