import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ایپ لوڈ ہونے سے پہلے ہر قسم کا ڈیٹا، کیشے اور کوکیز صاف کرنا
  try {
    await InAppWebViewController.clearAllCache(); 
    await CookieManager.instance().deleteAllCookies();
    final webStorageManager = WebStorageManager.instance();
    await webStorageManager.android.deleteAllData(); 
  } catch (e) {
    debugPrint("Cleanup error: $e");
  }

  // پرمیشنز
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PopScope(
          canPop: false, 
          onPopInvokedWithResult: (didPop, result) {
            if (didPop) return;
            SystemNavigator.pop();
          },
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  geolocationEnabled: false,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  clearCache: true, 
                  cacheEnabled: false,
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

                onDownloadStartRequest: (controller, downloadRequest) async {
                  final url = downloadRequest.url;
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },

                onLoadStart: (c, u) {
                  if (u.toString() != "about:blank") {
                    setState(() { isLoading = true; isError = false; });
                  }
                },
                onLoadStop: (c, u) => setState(() { isLoading = false; }),
                onReceivedError: (c, r, e) {
                  c.stopLoading();
                  c.loadUrl(urlRequest: URLRequest(url: WebUri("about:blank")));
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
                      const Icon(Icons.error_outline, size: 80, color: Colors.redAccent),
                      const SizedBox(height: 20),
                      const Text(
                        "LOADING ERROR", 
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.w900, color: Colors.black54)
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "Please check your internet connection.", 
                        style: TextStyle(color: Colors.grey)
                      ),
                      const SizedBox(height: 40),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
                        onPressed: () {
                          setState(() {
                            isError = false;
                            isLoading = true;
                          });
                          webViewController?.loadUrl(
                            urlRequest: URLRequest(url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"))
                          );
                        },
                        child: const Text("TRY AGAIN", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
