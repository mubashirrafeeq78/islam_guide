import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ایپ شروع ہوتے ہی تمام ضروری پرمیشنز مانگنا
  await [
    Permission.location,
    Permission.camera,
    Permission.microphone,
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
  bool firstLoadSuccess = false; // پہلی بار کامیابی سے لوڈ ہونے کا ریکارڈ
  Timer? timeoutTimer;

  // واٹس ایپ اور کمیونٹی کے لنکس کے لیے
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  // اگر 20 سیکنڈ تک کچھ لوڈ نہ ہو تو ایرر دکھائیں
  void startTimer() {
    timeoutTimer?.cancel();
    timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (!firstLoadSuccess && mounted) {
        setState(() {
          isError = true;
          isLoading = false;
        });
      }
    });
  }

  @override
  void dispose() {
    timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            if (isError) {
              SystemNavigator.pop();
            } else if (webViewController != null && await webViewController!.canGoBack()) {
              webViewController!.goBack();
            } else {
              SystemNavigator.pop();
            }
          },
          child: Stack(
            children: [
              // اصل ویب ویو
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  geolocationEnabled: true, // GPS کے لیے لازمی
                  mediaPlaybackRequiresUserGesture: false,
                  // اس سے اینڈرائیڈ کا اپنا سفید ایرر پیج غائب ہو جائے گا
                  transparentBackground: true,
                  disableDefaultErrorPage: true, 
                  useShouldOverrideUrlLoading: true,
                ),
                onWebViewCreated: (c) {
                  webViewController = c;
                  startTimer();
                },

                // GPS اور کیمرہ پرمیشن کا فکس (یہ ویب سائٹ کو ایکسیس دے گا)
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                },

                onLoadStart: (c, u) {
                  if (!firstLoadSuccess) setState(() => isLoading = true);
                },

                onLoadStop: (c, u) {
                  timeoutTimer?.cancel();
                  setState(() {
                    isLoading = false;
                    isError = false;
                    firstLoadSuccess = true;
                  });
                },

                // اگر شروع میں ہی نیٹ بند ہو یا پیج نہ ملے
                onReceivedError: (c, r, e) {
                  if (!firstLoadSuccess) {
                    setState(() {
                      isError = true;
                      isLoading = false;
                    });
                  }
                },

                // ایچ ٹی ٹی پی ایررز کے لیے (جیسے 404 یا سرور ڈاون)
                onReceivedHttpError: (c, r, e) {
                  if (!firstLoadSuccess) {
                    setState(() {
                      isError = true;
                      isLoading = false;
                    });
                  }
                },
              ),

              // لوڈنگ انڈیکیٹر
              if (isLoading && !isError)
                const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

              // آپ کی ڈیزائن کردہ پروفیشنل ایرر اسکرین
              if (isError)
                Container(
                  color: const Color(0xFFF1F4F8),
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 80, color: Colors.redAccent),
                      const SizedBox(height: 20),
                      const Text(
                        "کنکشن کا مسئلہ",
                        style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.black87),
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        "آپ کا انٹرنیٹ بند ہے یا ویب سائٹ لوڈ نہیں ہو پا رہی۔ براہ کرم اپنا نیٹ ورک چیک کریں۔",
                        textAlign: TextAlign.center,
                        style: TextStyle(fontSize: 14, color: Colors.black54),
                      ),
                      const SizedBox(height: 40),
                      Image.asset('support.png', width: 60),
                      const SizedBox(height: 10),
                      
                      // واٹس ایپ نمبر بٹن
                      InkWell(
                        onTap: () => _launchURL("https://wa.me/923140143585"),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(30),
                            boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)],
                          ),
                          child: const Text("WhatsApp: 03140143585", style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold)),
                        ),
                      ),
                      
                      const SizedBox(height: 20),
                      
                      // کمیونٹی بٹن
                      ElevatedButton.icon(
                        onPressed: () => _launchURL("https://chat.whatsapp.com/GK4u3GI1VZILxhMB8GZSnj"),
                        icon: const Icon(Icons.group, color: Colors.white),
                        label: const Text("کمیونٹی جوائن کریں"),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      ),
                      
                      const SizedBox(height: 40),
                      
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            isError = false;
                            isLoading = true;
                          });
                          webViewController?.reload();
                          startTimer();
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blueGrey,
                          padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                        ),
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
