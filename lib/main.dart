import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // لوکیشن کی پرمیشنز کو شروع میں ہی پکا کر لیں
  await [
    Permission.location,
    Permission.locationWhenInUse,
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

  // واٹس ایپ سلیکٹر کا سب سے طاقتور طریقہ
  Future<void> _openWhatsAppChooser() async {
    const String url = "https://wa.me/923140143585";
    final Uri whatsappUri = Uri.parse(url);

    try {
      // یہاں ہم جان بوجھ کر 'externalApplication' استعمال کر رہے ہیں تاکہ سسٹم چوائس دکھائے
      final bool launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) {
        throw 'Could not launch $url';
      }
    } catch (e) {
      // اگر وہ کام نہ کرے تو متبادل طریقہ
      await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
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
              SystemNavigator.pop();
              return false;
            }
            if (webViewController != null && await webViewController!.canGoBack()) {
              webViewController!.goBack();
              return false;
            } else {
              SystemNavigator.pop();
              return false;
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
                  geolocationEnabled: true, // جی پی ایس کے لیے اہم
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  allowFileAccessFromFileURLs: true,
                  allowUniversalAccessFromFileURLs: true,
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
                // یہ وہ حصہ ہے جو ویب سائٹ کو جی پی ایس دیتا ہے
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
                      const Text("LOADING ERROR", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.red)),
                      const SizedBox(height: 50),
                      Image.asset("support.png", width: 130, height: 130, errorBuilder: (c, e, s) => const Icon(Icons.support_agent, size: 100)),
                      const SizedBox(height: 30),
                      const Text("HELP SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: _openWhatsAppChooser,
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
