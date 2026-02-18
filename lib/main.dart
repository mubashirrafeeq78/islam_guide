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
  bool isLoading = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
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
              InAppWebView(
                initialUrlRequest: URLRequest(
                  url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"),
                ),
                initialSettings: InAppWebViewSettings(
                  javaScriptEnabled: true,
                  geolocationEnabled: true,
                  domStorageEnabled: true,
                  databaseEnabled: true,
                  allowFileAccessFromFileURLs: true,
                  allowUniversalAccessFromFileURLs: true,
                  mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
                  useOnDownloadStart: true, 
                  mediaPlaybackRequiresUserGesture: false,
                ),
                onWebViewCreated: (c) => webViewController = c,
                
                // پرمیشن ہینڈلر
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                },

                // ڈاؤن لوڈنگ ہینڈلر
                onDownloadStartRequest: (controller, downloadRequest) async {
                  final url = downloadRequest.url;
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },

                onLoadStart: (c, u) {
                  if (u.toString() != "about:blank") {
                    setState(() { isLoading = true; });
                  }
                },
                onLoadStop: (c, u) => setState(() { isLoading = false; }),
                
                // ایرر ہینڈلر: اب یہ ایرر اسکرین نہیں دکھائے گا
                onReceivedError: (c, r, e) {
                  // ہم نے ایرر لاجک ختم کر دی ہے تاکہ یوزر قید نہ ہو اور شور نہ مچے
                  debugPrint("Webview Error Ignored: ${e.description}");
                },
                
                onGeolocationPermissionsShowPrompt: (c, o) async {
                  return GeolocationPermissionShowPromptResponse(origin: o, allow: true, retain: true);
                },
              ),
              
              if (isLoading) const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),
            ],
          ),
        ),
      ),
    );
  }
}
