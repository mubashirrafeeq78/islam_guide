import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ضروری پرمیشنز مانگنا
  await [
    Permission.location,
    Permission.microphone,
    Permission.storage,
    Permission.camera,
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
  double progress = 0;

  // واٹس ایپ یا سپورٹ کے لیے فنکشن
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("لنک کھولنے میں دشواری ہو رہی ہے")),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri("https://your-website-url.com")), // یہاں اپنی ویب سائٹ کا لنک لکھیں
              initialSettings: InAppWebViewSettings(
                useOnDownloadStart: true,
                javaScriptEnabled: true,
                useOnLoadResource: true,
                allowFileAccessFromFileURLs: true,
                allowUniversalAccessFromFileURLs: true,
              ),
              onWebViewCreated: (controller) {
                webViewController = controller;
              },
              onLoadStart: (controller, url) {
                setState(() {
                  isLoading = true;
                  isError = false;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  isLoading = false;
                });
              },
              onReceivedError: (controller, request, error) {
                setState(() {
                  isError = true;
                  isLoading = false;
                });
              },
              onProgressChanged: (controller, progressValue) {
                setState(() {
                  progress = progressValue / 100;
                });
              },
              // ڈاؤن لوڈنگ کا اہم حصہ
              onDownloadStartRequest: (controller, downloadRequest) async {
                print("Downloading: ${downloadRequest.url}");
                // ڈاؤن لوڈ کرنے کے لیے سسٹم براؤزر یا ڈاؤن لوڈر کا استعمال
                await _launchURL(downloadRequest.url.toString());
              },
            ),
            
            // لوڈنگ بار
            if (isLoading)
              LinearProgressIndicator(value: progress, color: Colors.green),

            // کسٹم ایرر اسکرین - آپ کا بتایا ہوا ائیکون یہاں استعمال ہوگا
            if (isError)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('support.png', width: 100, height: 100), // آپ کا اپلوڈ کردہ ائیکون
                      const SizedBox(height: 20),
                      const Text("انٹرنیٹ کا مسئلہ ہے یا پیج لوڈ نہیں ہو رہا", 
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () => webViewController?.reload(),
                        child: const Text("دوبارہ کوشش کریں"),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
      // ہیلپ اسپورٹ بٹن جو آپ نے اسکرین شاٹ میں دکھایا
      floatingActionButton: FloatingActionButton(
        onPressed: () => _launchURL("https://wa.me/923140143585"),
        backgroundColor: Colors.transparent,
        elevation: 0,
        child: Image.asset('support.png'), // سپورٹ ائیکون
      ),
    );
  }
}
