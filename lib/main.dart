import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await _askPermissions();
  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: WebViewApp(),
  ));
}

Future<void> _askPermissions() async {
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
  bool isFirstLoadDone = false; // یہ چیک کرے گا کہ کیا ایک بار کامیابی سے لوڈنگ ہو گئی

  Future<void> _launchWhatsApp() async {
    final Uri whatsappUri = Uri.parse("https://wa.me/923140143585");
    if (await canLaunchUrl(whatsappUri)) {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
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
              _retry();
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
              // ویب ویو صرف تب غائب ہوگا جب پہلی بار لوڈنگ میں مسئلہ ہو
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  useOnDownloadStart: true,
                  disableDefaultErrorPage: true, // سسٹم کا ایرر پیج بلاک
                  cacheMode: CacheMode.LOAD_DEFAULT, // کیشے کا استعمال تاکہ سلو نیٹ پر مسئلہ نہ ہو
                ),
                onWebViewCreated: (c) => webViewController = c,
                onLoadStart: (c, u) {
                  if (!isFirstLoadDone) setState(() => isLoading = true);
                },
                onLoadStop: (c, u) {
                  setState(() {
                    isLoading = false;
                    isError = false;
                    isFirstLoadDone = true; // پہلی بار لوڈنگ مکمل ہو گئی
                  });
                },
                
                onReceivedError: (c, r, e) {
                  // اگر پہلی بار لوڈنگ نہیں ہوئی صرف تب ایرر اسکرین دکھائیں
                  if (!isFirstLoadDone) {
                    setState(() {
                      isError = true;
                      isLoading = false;
                    });
                  }
                },
                
                onReceivedHttpError: (c, r, res) {
                  if (!isFirstLoadDone) {
                    setState(() {
                      isError = true;
                      isLoading = false;
                    });
                  }
                },
              ),
              
              if (isLoading && !isError) 
                const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

              // سیکیور ایرر اسکرین صرف پہلی بار فیل ہونے پر نظر آئے گی
              if (isError && !isFirstLoadDone)
                Container(
                  color: const Color(0xFFF1F4F8),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("LOADING ERROR", style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.redAccent)),
                      const SizedBox(height: 40),
                      Image.asset(
                        'support.png',
                        width: 140, height: 140,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.support_agent, size: 100, color: Colors.blueGrey),
                      ),
                      const SizedBox(height: 30),
                      const Text("HELP SUPPORT", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      const SizedBox(height: 15),
                      InkWell(
                        onTap: _launchWhatsApp,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(50), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15)]),
                          child: const Text("00923140143585", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ),
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF607D8B), padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)),
                        onPressed: _retry,
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

  void _retry() {
    setState(() {
      isError = false;
      isLoading = true;
    });
    webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php")));
  }
}
