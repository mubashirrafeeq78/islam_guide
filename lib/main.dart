import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:async';
import 'dart:io';

Future<void> clearAllAppUserData() async {
  try {
    await InAppWebViewController.clearAllCache(); 
    await CookieManager.instance().deleteAllCookies();
    final webStorageManager = WebStorageManager.instance();
    if (Platform.isAndroid) {
      await webStorageManager.android.deleteAllData();
    }
    debugPrint("Cleanup complete.");
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
  bool isOffline = false; 
  Timer? twoMinuteTimer;
  late AnimationController _blinkController;

  @override
  void initState() {
    super.initState();
    _blinkController = AnimationController(vsync: this, duration: const Duration(seconds: 1))..repeat(reverse: true);
  }

  @override
  void dispose() {
    _blinkController.dispose();
    twoMinuteTimer?.cancel();
    super.dispose();
  }

  void handleOfflineStatus() {
    if (twoMinuteTimer == null || !twoMinuteTimer!.isActive) {
      setState(() { isOffline = true; });
      twoMinuteTimer = Timer(const Duration(minutes: 2), () {
        if (isOffline) {
          setState(() { isError = true; isOffline = false; isLoading = false; });
        }
      });
    }
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
                  cacheEnabled: true,
                  useOnRenderProcessGone: true,
                  // خودکار ایرر پیج کو روکنے کے لیے
                  disableDefaultErrorPage: true, 
                ),
                onWebViewCreated: (c) => webViewController = c,
                onLoadStart: (c, u) => setState(() { isLoading = true; }),
                onLoadStop: (c, u) {
                  setState(() { isLoading = false; isOffline = false; isError = false; });
                  twoMinuteTimer?.cancel();
                  twoMinuteTimer = null;
                },
                onReceivedError: (c, r, e) {
                  // تمام نیٹ ورک ایررز کے کوڈز کو ہینڈل کرنا (جیسے -2, -6, -8)
                  if (e.code == -2 || e.code == -6 || e.code == -8 || e.code == -106) {
                    c.loadData(data: "<html><body style='background:white;'></body></html>");
                    handleOfflineStatus();
                  }
                },
              ),
              
              if (isLoading && !isOffline && !isError)
                const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

              if (isOffline && !isError)
                Positioned(
                  top: 50, left: 20, right: 20,
                  child: FadeTransition(
                    opacity: _blinkController,
                    child: Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(color: Colors.red.withOpacity(0.9), borderRadius: BorderRadius.circular(10)),
                      child: const Text(
                        "کنکشن منقطع ہے، دوبارہ کوشش جاری ہے...",
                        textAlign: TextAlign.center,
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                      ),
                    ),
                  ),
                ),

              if (isError)
                Container(
                  color: Colors.white,
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.signal_wifi_off, size: 70, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text("انٹرنیٹ دستیاب نہیں ہے", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        onPressed: () {
                          setState(() { isError = false; isOffline = false; isLoading = true; });
                          webViewController?.reload();
                        },
                        child: const Text("دوبارہ لوڈ کریں"),
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
