import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'dart:io';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ایپ کھلتے ہی نوٹیفیکیشن اور دیگر ضروری پرمیشنز مانگنا
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

  // واٹس ایپ پر براہ راست بھیجنے کا فنکشن
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
              // ویب ویو: اگر ایرر ہو تو اسے مکمل غائب کر دو تاکہ ڈومین نہ دکھے
              if (!isError)
                InAppWebView(
                  initialUrlRequest: URLRequest(
                    url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"),
                  ),
                  initialSettings: InAppWebViewSettings(
                    javaScriptEnabled: true,
                    domStorageEnabled: true,
                    useOnDownloadStart: true,
                    disableDefaultErrorPage: true, // اینڈرائیڈ کا اپنا ایرر پیج بلاک کریں
                  ),
                  onWebViewCreated: (c) => webViewController = c,
                  onLoadStart: (c, u) => setState(() { isLoading = true; isError = false; }),
                  onLoadStop: (c, u) => setState(() { isLoading = false; }),
                  
                  // کسی بھی قسم کے ایرر پر کسٹم اسکرین ٹرگر کریں
                  onReceivedError: (c, r, e) {
                    setState(() {
                      isError = true;
                      isLoading = false;
                    });
                  },
                  onReceivedHttpError: (c, r, res) {
                    setState(() {
                      isError = true;
                      isLoading = false;
                    });
                  },
                ),
              
              // لوڈنگ پروگریس
              if (isLoading && !isError) 
                const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

              // آپ کی کسٹم ایرر اسکرین (تصویر کے عین مطابق)
              if (isError)
                Container(
                  color: const Color(0xFFF1F4F8),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        "LOADING ERROR", 
                        style: TextStyle(fontSize: 26, fontWeight: FontWeight.w900, color: Colors.redAccent, letterSpacing: 1.2)
                      ),
                      const SizedBox(height: 40),
                      
                      // سپورٹ امیج (جو آپ نے اپ لوڈ کی ہے)
                      Image.asset(
                        'support.png',
                        width: 140,
                        height: 140,
                        errorBuilder: (context, error, stackTrace) => const Icon(Icons.support_agent, size: 100, color: Colors.blueGrey),
                      ),
                      
                      const SizedBox(height: 30),
                      const Text(
                        "HELP SUPPORT", 
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: Colors.blueGrey)
                      ),
                      const SizedBox(height: 15),
                      
                      // واٹس ایپ بٹن ڈیزائن
                      InkWell(
                        onTap: _launchWhatsApp,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                          decoration: BoxDecoration(
                            color: Colors.white, 
                            borderRadius: BorderRadius.circular(50),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 15, offset: Offset(0, 5))]
                          ),
                          child: const Text(
                            "00923140143585", 
                            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)
                          ),
                        ),
                      ),
                      
                      const SizedBox(height: 50),
                      
                      // دوبارہ کوشش کا بٹن
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF607D8B),
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25))
                        ),
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
