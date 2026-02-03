import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
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
          onPopInvokedWithResult: (didPop, result) async {
            if (didPop) return;
            if (webViewController != null && await webViewController!.canGoBack()) {
              webViewController!.goBack();
            } else {
              if (context.mounted) Navigator.of(context).pop();
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
                  geolocationEnabled: true,
                  domStorageEnabled: true,
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                ),
                onWebViewCreated: (c) => webViewController = c,
                onLoadStart: (c, u) => setState(() { isLoading = true; isError = false; }),
                onLoadStop: (c, u) => setState(() { isLoading = false; }),
                onReceivedError: (c, r, e) {
                  c.loadUrl(urlRequest: URLRequest(url: WebUri("about:blank")));
                  setState(() { isError = true; isLoading = false; });
                },
                onGeolocationPermissionsShowPrompt: (c, o) async {
                  return GeolocationPermissionShowPromptResponse(origin: o, allow: true, retain: true);
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
                      const Text(
                        "LOADING ERROR",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.black, color: Colors.red, letterSpacing: 1.2),
                      ),
                      const SizedBox(height: 40),
                      Container(
                        padding: const EdgeInsets.all(15),
                        decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                        child: const Icon(Icons.sync, size: 60, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 30),
                      const Icon(Icons.support_agent, size: 100, color: Colors.blueGrey),
                      const SizedBox(height: 40),
                      const Text("HELP SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey, letterSpacing: 1)),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: () => webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("https://wa.me/923140143585"))),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(30), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(Icons.chat, color: Colors.green, size: 28),
                              const SizedBox(width: 10),
                              const Text("00923140143585", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20))),
                        onPressed: () => webViewController?.reload(),
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
