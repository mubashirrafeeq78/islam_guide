import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // صرف ضروری پرمیشنز (ریکارڈنگ اور میڈیا)
  await [
    Permission.microphone,
    Permission.camera,
    Permission.photos,
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
  bool isLoading = true; // صرف پہلی لوڈنگ کے لیے
  bool hasLoadedOnce = false; // ٹریک کرنے کے لیے کہ کیا ایک بار لوڈ ہو چکا ہے

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            if (webViewController != null && await webViewController!.canGoBack()) {
              webViewController!.goBack();
            } else {
              SystemNavigator.pop();
            }
          },
          child: Stack(
            children: [
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php"),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  geolocationEnabled: false, // لوکیشن بند کر دی گئی ہے
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  allowFileAccessFromFileURLs: true,
                  allowUniversalAccessFromFileURLs: true,
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  useOnDownloadStart: false, // ڈاؤن لوڈنگ مکمل بند
                  mediaPlaybackRequiresUserGesture: false,
                ),
                onWebViewCreated: (c) => webViewController = c,
                
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                },

                onLoadStart: (c, u) {
                  // اگر ابھی تک ایک بار بھی لوڈ نہیں ہوا، تو لوڈنگ دکھائیں
                  if (!hasLoadedOnce) {
                    setState(() {
                      isLoading = true;
                    });
                  }
                },
                
                onLoadStop: (c, u) {
                  setState(() {
                    isLoading = false;
                    hasLoadedOnce = true; // اب یہ دوبارہ ٹرو نہیں ہوگا
                  });
                },
                
                onReceivedError: (c, r, e) {
                  // ایرر آنے پر کچھ نہیں کرنا، بس لوڈنگ روک دینی ہے اگر وہ پہلی بار تھی
                  if (!hasLoadedOnce) {
                    // یہاں ہم کچھ نہیں کریں گے تاکہ سرکل گھومتا رہے یا پچھلا ڈیٹا رہے
                  }
                },
              ),
              
              // لوڈنگ سرکل صرف تب دکھے گا جب ایپ پہلی بار لوڈ ہو رہی ہو
              if (isLoading && !hasLoadedOnce) 
                const Center(
                  child: CircularProgressIndicator(
                    color: Colors.blueGrey,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
