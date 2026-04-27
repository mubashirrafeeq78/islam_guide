import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';
import 'dart:async';

Future<void> clearAllAppUserData() async {
  try {
    await InAppWebViewController.clearAllCache(); 
    await CookieManager.instance().deleteAllCookies();
    final webStorageManager = WebStorageManager.instance();
    await webStorageManager.android.deleteAllData();
    debugPrint("All data cleared successfully.");
  } catch (e) {
    debugPrint("Cleanup error: $e");
  }
}

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await clearAllAppUserData();
  await [Permission.microphone, Permission.camera, Permission.photos, Permission.videos, Permission.storage].request();
  runApp(const MaterialApp(debugShowCheckedModeBanner: false, home: WebViewApp()));
}

class WebViewApp extends StatefulWidget {
  const WebViewApp({super.key});
  @override
  State<WebViewApp> createState() => _WebViewAppState();
}

class _WebViewAppState extends State<WebViewApp> with SingleTickerProviderStateMixin {
  InAppWebViewController? webViewController;
  bool isError = false;
  bool isLoading = true;
  bool showBlinkingText = false;
  Timer? offlineTimer;
  late AnimationController _animationController;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(vsync: this, duration: const Duration(milliseconds: 800))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _animationController.dispose();
    offlineTimer?.cancel();
    super.dispose();
  }

  Future<bool> isReallyOffline() async {
    try {
      final result = await InternetAddress.lookup('google.com').timeout(const Duration(seconds: 3));
      return result.isEmpty || result[0].rawAddress.isEmpty;
    } catch (_) {
      return true;
    }
  }

  void startOfflineTimer() {
    if (offlineTimer == null || !offlineTimer!.isActive) {
      setState(() { showBlinkingText = true; });
      offlineTimer = Timer(const Duration(minutes: 2), () {
        if (showBlinkingText) {
          setState(() {
            isError = true;
            showBlinkingText = false;
            isLoading = false;
          });
        }
      });
    }
  }

  void resetOfflineStatus() {
    offlineTimer?.cancel();
    offlineTimer = null;
    setState(() { showBlinkingText = false; isError = false; });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            await clearAllAppUserData();
            SystemNavigator.pop();
          },
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(url: WebUri("https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php")),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  cacheEnabled: true,
                  useShouldOverrideUrlLoading: true,
                  transparentBackground: true,
                ),
                onWebViewCreated: (c) => webViewController = c,
                onLoadStart: (c, u) => setState(() { isLoading = true; }),
                onLoadStop: (c, u) {
                  setState(() { isLoading = false; });
                  resetOfflineStatus();
                },
                onReceivedError: (c, r, e) async {
                  // یہ لائن اینڈرائیڈ کا ڈیفالٹ ایرر پیج چھپانے کے لیے اہم ہے
                  if (e.description.contains("net::ERR")) {
                    c.loadData(data: "<html><body style='background-color:white;'></body></html>"); 
                  }
                  
                  bool offline = await isReallyOffline();
                  if (offline) {
                    startOfflineTimer();
                  }
                },
                onReceivedHttpError: (c, r, e) async {
                  if (await isReallyOffline()) startOfflineTimer();
                },
              ),
              
              if (isLoading && !showBlinkingText && !isError) 
                const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

              // 2 منٹ والا بلنکنگ نوٹیفکیشن
              if (showBlinkingText)
                Positioned(
                  top: 20,
                  left: 20,
                  right: 20,
                  child: FadeTransition(
                    opacity: _animationController,
                    child: Container(
                      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 15),
                      decoration: BoxDecoration(color: Colors.black87, borderRadius: BorderRadius.circular(20)),
                      child: const Text(
                        "انٹرنیٹ کنکشن منقطع ہے، دوبارہ کوشش جاری ہے...",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontSize: 12),
                      ),
                    ),
                  ),
                ),

              // آپ کی کسٹم ڈیزائن کردہ ایرر اسکرین (2 منٹ بعد)
              if (isError)
                Container(
                  color: const Color(0xFFF1F4F8),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Center(child: Icon(Icons.wifi_off, size: 80, color: Colors.redAccent)),
                      const SizedBox(height: 20),
                      const Text("انٹرنیٹ دستیاب نہیں ہے", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                        onPressed: () async {
                          if (!(await isReallyOffline())) {
                            resetOfflineStatus();
                            webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php")));
                          }
                        },
                        child: const Text("دوبارہ کوشش کریں", style: TextStyle(color: Colors.white)),
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
