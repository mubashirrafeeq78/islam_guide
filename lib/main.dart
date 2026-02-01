import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ایپ کھلتے ہی GPS پرمیشن مانگے گی
  await Permission.location.request();
  
  runApp(const MaterialApp(
    title: "Masail ka Hal",
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // اگر آپ اوپر والی پٹی (AppBar) ختم کرنا چاہیں تو نیچے والی لائن ڈیلیٹ کر دیں
      appBar: AppBar(
        title: const Text("Masail ka Hal"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,      // ویب سائٹ چلانے کے لیے ضروری
            geolocationEnabled: true,    // GPS لوکیشن کے لیے
            useOnDownloadStart: true,    // ڈاؤن لوڈنگ سپورٹ کے لیے
            displayZoomControls: false,  // بہتر ڈسپلے کے لیے
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          onGeolocationPermissionsShowPrompt: (controller, origin) async {
            return GeolocationPermissionShowPromptResponse(origin: origin, allow: true, retain: true);
          },
        ),
      ),
    );
  }
}
