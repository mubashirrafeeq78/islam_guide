import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _requestAllPermissions();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WebViewApp(),
  ));
}

Future<void> _requestAllPermissions() async {
  if (Platform.isAndroid) {
    await Permission.notification.request();
  }
  await [
    Permission.location,
    Permission.microphone,
    Permission.storage,
    Permission.camera,
    Permission.photos,
  ].request();
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
        child: WillPopScope(
          onWillPop: () async {
            if (isError) {
              _reloadPage();
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
              // ویب ویو کو صرف تب دکھائیں جب ایرر نہ ہو
              Opacity(
                opacity: isError ? 0.0 : 1.0, 
                child: InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"),
                  ),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
                    useOnDownloadStart: true,
                    // اینڈرائیڈ کا اپنا ایرر پیج روکنے کے لیے
                    disableDefaultErrorPage: true, 
                  ),
                  onWebViewCreated: (c) => webViewController = c,
                  onLoadStart: (c, u) => setState(() { isLoading = true; isError = false; }),
                  onLoadStop: (c, u) => setState(() { isLoading = false; }),
                  
                  // ایرر آنے پر ڈومین چھپانا اور ایرر اسکرین دکھانا
                  onReceivedError: (c, r, e) {
                    setState(() {
                      isError = true;
                      isLoading = false;
                    });
                  },
                  onReceivedHttpError: (c, r, r2) {
                    setState(() {
                      isError = true;
                      isLoading = false;
                    });
                  },
                ),
              ),
              
              // لوڈنگ انڈیکیٹر
              if (isLoading && !isError) 
                const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

              // آپ کی سیکیور ایرر اسکرین
              if (isError)
                Positioned.fill(
                  child: Container(
                    color: const Color(0xFFF1F4F8),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("سسٹم ایرر", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.red)),
                        const SizedBox(height: 50),
                        
                        // امیج شو کرنے کا درست طریقہ
                        Image.asset(
                          'support.png',
                          width: 150,
                          height: 150,
                          errorBuilder: (context, error, stackTrace) => const Icon(Icons.support_agent, size: 120, color: Colors.blueGrey),
                        ),
                        
                        const SizedBox(height: 30),
                        const Text("رابطہ برائے مدد", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                        const SizedBox(height: 20),
                        
                        GestureDetector(
                          onTap: () => launchUrl(Uri.parse("https://wa.me/923140143585")),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                            child: const Text("WhatsApp Help", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                          ),
                        ),
                        const SizedBox(height: 60),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
                          onPressed: _reloadPage,
                          child: const Text("دوبارہ کوشش کریں", style: TextStyle(color: Colors.white, fontSize: 16)),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  void _reloadPage() {
    setState(() {
      isError = false;
      isLoading = true;
    });
    webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php")));
  }
}
