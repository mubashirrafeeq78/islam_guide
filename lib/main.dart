import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io'; // نیٹ ورک چیک کرنے کے لیے

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

  await [
    Permission.microphone,
    Permission.camera,
    Permission.photos,
    Permission.videos,
    Permission.storage,
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

  // انٹرنیٹ کا مکمل خاتمہ چیک کرنے کا فنکشن
  Future<bool> isReallyOffline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isEmpty || result[0].rawAddress.isEmpty;
    } on SocketException catch (_) {
      return true; // مکمل طور پر آف لائن ہے
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
                initialUrlRequest: URLRequest(
                  url: WebUri("https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php"),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  clearCache: false, // کیشے ختم نہیں کریں گے تاکہ سلو نیٹ پر ایپ چلتی رہے
                  cacheEnabled: true,
                  allowFileAccessFromFileURLs: true,
                  allowUniversalAccessFromFileURLs: true,
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  useOnDownloadStart: true, 
                  mediaPlaybackRequiresUserGesture: false,
                ),
                onWebViewCreated: (c) => webViewController = c,
                
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                },

                onLoadStart: (c, u) {
                  if (u.toString() != "about:blank") {
                    setState(() { isLoading = true; });
                  }
                },
                onLoadStop: (c, u) => setState(() { isLoading = false; }),
                
                onReceivedError: (c, r, e) async {
                  // جب کوئی ایرر آئے تو پہلے چیک کریں کہ کیا واقعی انٹرنیٹ بند ہے؟
                  bool offline = await isReallyOffline();
                  
                  if (offline) {
                    // صرف تب ایرر دکھائیں جب انٹرنیٹ بالکل نہ ہو
                    c.stopLoading();
                    c.loadUrl(urlRequest: URLRequest(url: WebUri("about:blank")));
                    setState(() { isError = true; isLoading = false; });
                  } else {
                    // اگر انٹرنیٹ سلو ہے یا کوئی اور چھوٹا مسئلہ ہے تو ایپ کو چلنے دیں، ایرر نہ دکھائیں
                    debugPrint("Slow internet or minor error, keeping the app alive.");
                  }
                },
              ),
              
              if (isLoading) const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

              if (isError)
                Container(
                  color: const Color(0xFFF1F4F8),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 80, color: Colors.redAccent),
                      const SizedBox(height: 20),
                      const Text(
                        "No Internet Connection", 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)
                      ),
                      const SizedBox(height: 10),
                      const Text("Please check your data or Wi-Fi."),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                        onPressed: () async {
                          if (!(await isReallyOffline())) {
                            setState(() { isError = false; isLoading = true; });
                            webViewController?.loadUrl(
                              urlRequest: URLRequest(url: WebUri("https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php"))
                            );
                          }
                        },
                        child: const Text("Try Again", style: TextStyle(color: Colors.white)),
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
