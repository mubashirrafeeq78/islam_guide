import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
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

  // واٹس ایپ سلیکٹر جو لازمی آپشن پوچھے گا
  Future<void> _showAppChooser() async {
    const String phone = "923140143585";
    const String url = "https://wa.me/$phone";
    
    // ہم سسٹم کو بتائیں گے کہ یہ ایک بیرونی ٹاسک ہے تاکہ وہ چوائس دکھائے
    final Uri _url = Uri.parse(url);
    try {
      await launchUrl(
        _url,
        mode: LaunchMode.externalNonBrowserApplication, // یہ براؤزر کے بجائے ایپس کو ترجیح دیتا ہے
      );
    } catch (e) {
      await launchUrl(_url, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (isError) {
              SystemChannels.platform.invokeMethod('SystemNavigator.pop');
              return false;
            }
            
            if (webViewController != null) {
              if (await webViewController!.canGoBack()) {
                webViewController!.goBack(); // اگر پیچھے پیج ہے تو پیچھے جاؤ
                return false;
              } else {
                // اگر پیچھے کوئی پیج نہیں ہے (مین ڈیش بورڈ ہے) تو ایپ بند کرو
                SystemChannels.platform.invokeMethod('SystemNavigator.pop');
                return false;
              }
            }
            return true;
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
                  useShouldOverrideUrlLoading: true,
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                ),
                onWebViewCreated: (c) => webViewController = c,
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
                      const Text("LOADING ERROR", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.red)),
                      const SizedBox(height: 50),
                      Image.asset("support.png", width: 130, height: 130, errorBuilder: (c, e, s) => const Icon(Icons.support_agent, size: 100)),
                      const SizedBox(height: 30),
                      const Text("HELP SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: _showAppChooser, // اب یہ فنکشن آپشن پوچھے گا
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Image.asset("whatsapp.png", width: 32, height: 32, errorBuilder: (c, e, s) => const Icon(Icons.chat, color: Colors.green)),
                              const SizedBox(width: 15),
                              const Text("00923140143585", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 60),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                        onPressed: () {
                          setState(() => isError = false);
                          webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php")));
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
