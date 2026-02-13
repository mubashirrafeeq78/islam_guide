import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;

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
  String webUrl = "https://your-website-url.com"; // اپنی ویب سائٹ کا لنک یہاں لکھیں

  // واٹس ایپ کھولنے کا فنکشن
  Future<void> _openWhatsApp() async {
    const String url = "https://wa.me/923140143585";
    if (await canLaunchUrl(Uri.parse(url))) {
      await launchUrl(Uri.parse(url), mode: LaunchMode.externalApplication);
    }
  }

  // تصویر ڈاؤن لوڈ کرنے کا فنکشن
  Future<void> downloadImage(String url) async {
    try {
      var status = await Permission.storage.request();
      if (status.isGranted) {
        final response = await http.get(Uri.parse(url));
        final bytes = response.bodyBytes;
        final directory = await getExternalStorageDirectory();
        final fileName = url.split('/').last;
        final file = File('${directory?.path}/$fileName');
        await file.writeAsBytes(bytes);
        
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("تصویر ڈاؤن لوڈ ہو گئی ہے")),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("ڈاؤن لوڈنگ میں مسئلہ آ رہا ہے")),
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
              initialUrlRequest: URLRequest(url: WebUri(webUrl)),
              initialOptions: InAppWebViewGroupOptions(
                crossPlatform: InAppWebViewOptions(
                  useShouldOverrideUrlLoading: true,
                  useOnDownloadStart: true, // ڈاؤن لوڈنگ فعال کی گئی
                  javaScriptEnabled: true,
                ),
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
              onLoadError: (controller, url, code, message) {
                setState(() {
                  isLoading = false;
                  isError = true;
                });
              },
              // ڈاؤن لوڈنگ ہینڈلر
              onDownloadStartRequest: (controller, downloadRequest) async {
                await downloadImage(downloadRequest.url.toString());
              },
              // شیئرنگ اور دیگر لنکس ہینڈلر
              shouldOverrideUrlLoading: (controller, navigationAction) async {
                var uri = navigationAction.request.url!;
                if (!["http", "https", "file", "chrome", "data", "javascript", "about"].contains(uri.scheme)) {
                  if (await canLaunchUrl(uri)) {
                    await launchUrl(uri, mode: LaunchMode.externalApplication);
                    return NavigationActionPolicy.CANCEL;
                  }
                }
                return NavigationActionPolicy.ALLOW;
              },
            ),
            
            // لوڈنگ اسکرین
            if (isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.green)),

            // ایرر اسکرین (آپ کے اپلوڈ کردہ ائیکون کے ساتھ)
            if (isError)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('support.png', width: 100), // آپ کا آئیکن
                      const SizedBox(height: 20),
                      const Text("انٹرنیٹ کا مسئلہ ہے یا پیج لوڈ نہیں ہو رہا", style: TextStyle(fontSize: 16)),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: () => webViewController?.reload(),
                        child: const Text("دوبارہ کوشش کریں"),
                      ),
                      TextButton(
                        onPressed: _openWhatsApp,
                        child: const Text("ہیلپ اسپورٹ سے رابطہ کریں"),
                      )
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
