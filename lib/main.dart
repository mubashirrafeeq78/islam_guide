Import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ایپ شروع ہوتے ہی تمام ضروری پرمیشنز مانگنا
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

  Future<void> _openWhatsAppChooser() async {
    const String url = "https://wa.me/923140143585";
    
