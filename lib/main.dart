import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request(); // ایپ کھلتے ہی جی پی ایس پرمیشن مانگے گی
  runApp(const MaterialApp(
    title: "Masail ka Hal",
    home: WebViewApp(),
    debugShowCheckedModeBanner: false,
  ));
}

class WebViewApp extends StatelessWidget {
  const WebViewApp({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Masail ka Hal"), backgroundColor: Colors.green),
      body: InAppWebView(
        initialUrlRequest: URLRequest(url: WebUri("https://your-website.com")),
        initialSettings: InAppWebViewSettings(
          geolocationEnabled: true, // جی پی ایس فعال کرنے کے لیے
          javaScriptEnabled: true,
        ),
      ),
    );
  }
}
