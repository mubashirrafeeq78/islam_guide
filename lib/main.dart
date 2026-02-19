import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ایپ شروع ہوتے ہی تمام ضروری پرمیشنز بشمول لوکیشن مانگنا
  await [
    Permission.location,
    Permission.locationWhenInUse,
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
  bool isFirstLoadAttempt = true; 
  Timer? timeoutTimer;

  // لنکس کھولنے کا فنکشن (واٹس ایپ اور کمیونٹی کے لیے)
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  void startInitialTimeout() {
    timeoutTimer?.cancel();
    timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (isFirstLoadAttempt && isLoading && mounted) {
        setState(() { isError = true; isLoading = false; });
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
                  geolocationEnabled: true, // GPS کے لیے لازمی
                  mediaPlaybackRequiresUserGesture: false,
                  allowFileAccessFromFileURLs: true,
                  javaScriptCanOpenWindowsAutomatically: true,
                ),
                onWebViewCreated: (c) {
                  webViewController = c;
                  startInitialTimeout();
                },
                // GPS اور دیگر پرمیشنز کا مستقل حل
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                },
                onLoadStart: (c, u) {
                  if (isFirstLoadAttempt) setState(() { isLoading = true; });
                },
                onLoadStop: (c, u) {
                  timeoutTimer?.cancel();
                  setState(() {
                    isLoading = false;
                    isError = false;
                    isFirstLoadAttempt = false; 
                  });
                },
                onReceivedError: (c, r, e) {
                  if (isFirstLoadAttempt) {
                    setState(() { isError = true; isLoading = false; });
                  }
                },
              ),
              
              if (isLoading && !isError) 
                const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

              // خوبصورت ڈیزائنڈ ایرر اسکرین
              if (isError)
                Container(
                  color: const Color(0xFFF8FAFC),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("کنکشن کا مسئلہ", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.redAccent, fontFamily: 'sans-serif')),
                      const SizedBox(height: 30),
                      Image.asset('support.png', width: 80), 
                      const SizedBox(height: 20),
                      const Text("ہیلپ سپورٹ کے لیے رابطہ کریں", style: TextStyle(fontSize: 14, color: Colors.blueGrey)),
                      const SizedBox(height: 20),
                      
                      // واٹس ایپ نمبر بٹن
                      InkWell(
                        onTap: () => _launchURL("https://wa.me/923140143585"),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)]),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset('whatsapp.png', width: 20),
                              const SizedBox(width: 10),
                              const Text("03140143585", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blue)),
                            ],
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 15),

                      // واٹس ایپ کمیونٹی بٹن
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white, shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))),
                        onPressed: () => _launchURL("https://chat.whatsapp.com/GK4u3GI1VZILxhMB8GZSnj"),
                        icon: const Icon(Icons.group, size: 20),
                        label: const Text("جوائن واٹس ایپ کمیونٹی"),
                      ),

                      const SizedBox(height: 50),
                      
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10))),
                        onPressed: () {
                          setState(() { isError = false; isLoading = true; isFirstLoadAttempt = true; });
                          webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php")));
                          startInitialTimeout();
                        },
                        child: const Text("دوبارہ کوشش کریں", style: TextStyle(color: Colors.white, fontSize: 16)),
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
  
