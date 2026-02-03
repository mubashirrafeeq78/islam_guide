import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

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

  // واٹس ایپ کھولنے کا فنکشن
  void _openWhatsApp() async {
    final Uri url = Uri.parse("https://wa.me/923140143585");
    if (!await launchUrl(url, mode: LaunchMode.externalApplication)) {
      debugPrint("WhatsApp could not be opened");
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
            if (isError) {
              setState(() => isError = false);
              webViewController?.reload();
              return;
            }
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
                ),
                onWebViewCreated: (c) => webViewController = c,
                onLoadStart: (c, u) {
                  if (u.toString() != "about:blank") {
                    setState(() { isLoading = true; isError = false; });
                  }
                },
                onLoadStop: (c, u) => setState(() { isLoading = false; }),
                onReceivedError: (c, r, e) {
                  c.stopLoading(); // اسکرین کو غائب ہونے سے روکنے کے لیے
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
                      const Text(
                        "LOADING ERROR",
                        style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.red),
                      ),
                      const SizedBox(height: 50),
                      
                      // ہیلپ سپورٹ ائیکون (براہ راست روٹ سے)
                      Image.asset("support.png", width: 140, height: 140, 
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.support_agent, size: 100, color: Colors.blueGrey)),
                      
                      const SizedBox(height: 30),
                      const Text("HELP SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      const SizedBox(height: 20),

                      // واٹس ایپ بٹن
                      InkWell(
                        onTap: _openWhatsApp,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(40),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              // واٹس ایپ ائیکون (براہ راست روٹ سے)
                              Image.asset("whatsapp.png", width: 32, height: 32,
                                errorBuilder: (context, error, stackTrace) => const Icon(Icons.chat, color: Colors.green)),
                              const SizedBox(width: 15),
                              const Text(
                                "00923140143585", 
                                style: TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: Colors.blue) // نیلا کلر
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30))
                        ),
                        onPressed: () {
                          setState(() => isError = false);
                          webViewController?.reload();
                        },
                        child: const Text("TRY AGAIN", style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
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
