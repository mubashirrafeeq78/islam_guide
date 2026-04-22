import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ایپ شروع ہونے سے پہلے ضروری پرمیشنز چیک کرنا
  await _requestInitialPermissions();

  runApp(const MaterialApp(
    debugShowCheckedModeBanner: false,
    home: NoorAppWebView(),
  ));
}

// کیمرہ اور میڈیا پرمیشنز مانگنے کا فنکشن
Future<void> _requestInitialPermissions() async {
  await [
    Permission.camera,
    Permission.photos,
    Permission.microphone,
  ].request();
}

class NoorAppWebView extends StatefulWidget {
  const NoorAppWebView({super.key});

  @override
  State<NoorAppWebView> createState() => _NoorAppWebViewState();
}

class _NoorAppWebViewState extends State<NoorAppWebView> {
  InAppWebViewController? webViewController;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // اوپر سے اسٹیٹس بار کو صاف رکھنے کے لیے SafeArea
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri("https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php"),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            useOnDownloadStart: false, // ڈاؤن لوڈنگ سختی سے بند ہے
            allowsInlineMediaPlayback: true,
            safeBrowsingEnabled: true,
            // میڈیا اپ لوڈنگ اور کیمرہ کے لیے ضروری سیٹنگ
            allowFileAccessFromFileURLs: true,
            allowUniversalAccessFromFileURLs: true,
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          // ویب سائٹ کے اندر پرمیشن کی درخواستوں کو ہینڈل کرنا (کیمرہ/مائیک)
          onPermissionRequest: (controller, request) async {
            return PermissionResponse(
              resources: request.resources,
              action: PermissionResponseAction.GRANT,
            );
          },
          // واٹس ایپ اور بیرونی لنکس کو ہینڈل کرنا
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            var uri = navigationAction.request.url!;
            if (!["http", "https", "file", "chrome", "data", "javascript"].contains(uri.scheme)) {
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri, mode: LaunchMode.externalApplication);
                return NavigationActionPolicy.CANCEL;
              }
            }
            return NavigationActionPolicy.ALLOW;
          },
        ),
      ),
    );
  }
}
