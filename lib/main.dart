import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(
            url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"),
          ),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            geolocationEnabled: true, // GPS فعال
            domStorageEnabled: true,
            mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
          ),
          onWebViewCreated: (controller) => webViewController = controller,
          // یہ حصہ آپ کی PHP فائل کو لوکیشن فراہم کرے گا
          onGeolocationPermissionsShowPrompt: (controller, origin) async {
            return GeolocationPermissionShowPromptResponse(origin: origin, allow: true, retain: true);
          },
          onReceivedError: (controller, request, error) {
            setState(() { isError = true; });
          },
        ),
      ),
    );
  }
}
