import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

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

  Future<bool> isReallyOffline() async {
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isEmpty || result[0].rawAddress.isEmpty;
    } on SocketException catch (_) {
      return true;
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
                  clearCache: false, 
                  cacheEnabled: true,
                  allowFileAccessFromFileURLs: true,
                  allowUniversalAccessFromFileURLs: true,
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  useOnDownloadStart: true, 
                  mediaPlaybackRequiresUserGesture: false,
                  // اضافی سیفٹی: اگر پیج لوڈ ہونے میں بہت دیر لگے تو اسے روک دے
                  useShouldInterceptRequest: true,
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
                    setState(() { isLoading = true; isError = false; });
                  }
                },
                onLoadStop: (c, u) => setState(() { isLoading = false; }),

                // یہ وہ حصہ ہے جو اسکرین شاٹ والے ایرر پیج کو روکے گا
                onReceivedError: (c, r, e) async {
                  // 1. فوراً لوڈنگ روکیں تاکہ ڈیفالٹ ایرر پیج نہ بن پائے
                  await c.stopLoading();
                  // 2. فوراً خالی صفحہ لوڈ کریں تاکہ ڈومین چھپ جائے
                  await c.loadUrl(urlRequest: URLRequest(url: WebUri("about:blank")));
                  
                  // اب تسلی سے چیک کریں کہ آف لائن ہے یا صرف سلو ہے
                  bool offline = await isReallyOffline();
                  
                  setState(() {
                    isLoading = false;
                    // اگر واقعی آف لائن ہے تو ہماری کسٹم ایرر اسکرین دکھائیں
                    // اگر صرف سلو تھا، تب بھی ہم نے ڈومین چھپا دیا ہے، یوزر دوبارہ کوشش کر سکتا ہے
                    isError = true; 
                  });
                },
                
                // HTTP ایررز (جیسے 404 یا 500) کے لیے بھی یہی لاجک
                onReceivedHttpError: (c, r, e) async {
                  await c.stopLoading();
                  await c.loadUrl(urlRequest: URLRequest(url: WebUri("about:blank")));
                  setState(() { isError = true; isLoading = false; });
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
                        "کنکشن کا مسئلہ", 
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.black87)
                      ),
                      const SizedBox(height: 10),
                      const Text("انٹرنیٹ سلو ہے یا بند ہے۔ براہ کرم دوبارہ کوشش کریں۔"),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                        onPressed: () async {
                          setState(() { isError = false; isLoading = true; });
                          webViewController?.loadUrl(
                            urlRequest: URLRequest(url: WebUri("https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php"))
                          );
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
