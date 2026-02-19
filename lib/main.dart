import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await [
    Permission.location,
    Permission.microphone,
    Permission.storage,
    Permission.camera,
  ].request();
  
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

class _WebViewAppState extends State<WebViewApp> {
  InAppWebViewController? webViewController;
  bool isError = false;
  bool isLoading = true;
  bool isFirstLoadAttempt = true; // یہ صرف پہلی لوڈنگ پر نظر رکھے گا
  Timer? timeoutTimer;

  Future<void> _openWhatsApp() async {
    final Uri whatsappUri = Uri.parse("https://wa.me/923140143585");
    if (!await launchUrl(whatsappUri, mode: LaunchMode.externalApplication)) {
      await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
    }
  }

  void startInitialTimeout() {
    timeoutTimer?.cancel();
    // صرف پہلی دفعہ 20 سیکنڈ کا انتظار کریں گے
    timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (isFirstLoadAttempt && isLoading && mounted) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            if (isError) {
              SystemNavigator.pop();
            } else if (webViewController != null && await webViewController!.canGoBack()) {
              webViewController!.goBack();
            } else {
              SystemNavigator.pop();
            }
          },
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  mediaPlaybackRequiresUserGesture: false,
                ),
                onWebViewCreated: (c) {
                  webViewController = c;
                  startInitialTimeout();
                },
                onLoadStart: (c, u) {
                  if (isFirstLoadAttempt) {
                    setState(() { isLoading = true; });
                  }
                },
                onLoadStop: (c, u) {
                  // جیسے ہی پہلی دفعہ لوڈنگ کامیاب ہوئی، تمام پابندیاں ختم
                  timeoutTimer?.cancel();
                  setState(() {
                    isLoading = false;
                    isError = false;
                    isFirstLoadAttempt = false; 
                  });
                },
                onReceivedError: (c, r, e) {
                  // اگر پہلی دفعہ لوڈنگ میں ایرر آئے تو سکرین دکھائیں
                  if (isFirstLoadAttempt) {
                    setState(() {
                      isError = true;
                      isLoading = false;
                    });
                  }
                  // پہلی دفعہ کے بعد کوئی ایرر ہینڈل نہیں ہوگا (خاموشی)
                },
              ),
              
              if (isLoading && !isError) 
                const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

              // آپ کی ڈیزائن کردہ پروفیشنل ایرر اسکرین (صرف پہلی دفعہ کے لیے)
              if (isError)
                Container(
                  color: const Color(0xFFF1F4F8),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("NETWORK ERROR", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.red)),
                      const SizedBox(height: 50),
                      Image.asset('support.png', width: 100), // آپ کا آئیکن
                      const SizedBox(height: 30),
                      const Text("HELP SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: _openWhatsApp,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('whatsapp.png', width: 25), // واٹس ایپ آئیکن
                              const SizedBox(width: 10),
                              const Text("03140143585", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                        onPressed: () {
                          setState(() {
                            isError = false;
                            isLoading = true;
                            isFirstLoadAttempt = true; // دوبارہ کوشش پر اسے ری سیٹ کریں
                          });
                          webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php")));
                          startInitialTimeout();
                        },
                        child: const Text("TRY AGAIN", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
