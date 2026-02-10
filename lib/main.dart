import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // ایپ شروع ہوتے ہی مائیکروفون، لوکیشن اور اسٹوریج کی پرمیشنز مانگنا
  await [
    Permission.location,
    Permission.microphone,
    Permission.storage,
    Permission.camera, // اگر تصویر کھینچ کر بھیجنی ہو
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
    final Uri whatsappUri = Uri.parse(url);
    try {
      final bool launched = await launchUrl(
        whatsappUri,
        mode: LaunchMode.externalApplication,
      );
      if (!launched) throw 'Could not launch $url';
    } catch (e) {
      await launchUrl(whatsappUri, mode: LaunchMode.platformDefault);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: WillPopScope(
          onWillPop: () async {
            if (isError) {
              SystemNavigator.pop();
              return false;
            }
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
                  useOnDownloadStart: true, // ڈاؤن لوڈنگ کے لیے ضروری
                  mediaPlaybackRequiresUserGesture: false, // آڈیو پلے بیک کے لیے
                ),
                onWebViewCreated: (c) => webViewController = c,
                
                // مائیکروفون اور کیمرہ کی ویب سائٹ کو اجازت دینا (اہم ترین حصہ)
                onPermissionRequest: (controller, request) async {
                  return PermissionRequestResponse(
                    resources: request.resources,
                    action: PermissionRequestResponseAction.GRANT,
                  );
                },

                // فائل ڈاؤن لوڈنگ کو ہینڈل کرنا
                onDownloadStartRequest: (controller, downloadRequest) async {
                  final url = downloadRequest.url;
                  if (await canLaunchUrl(url)) {
                    await launchUrl(url, mode: LaunchMode.externalApplication);
                  }
                },

                onLoadStart: (c, u) {
                  if (u.toString() != "about:blank") {
                    setState(() { isLoading = true; isError = false; });
                  }
                },
                onLoadStop: (c, u) => setState(() { isLoading = false; }),
                onReceivedError: (c, r, e) {
                  c.stopLoading();
                  c.loadUrl(urlRequest: URLRequest(url: WebUri("about:blank")));
                  setState(() { isError = true; isLoading = false; });
                },
                onGeolocationPermissionsShowPrompt: (c, o) async {
                  return GeolocationPermissionShowPromptResponse(origin: o, allow: true, retain: true);
                },
              ),
              
              if (isLoading) const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

              if (isError)
                Container(
                  color: const Color(0xFFF1F4F8),
                  width: double.infinity,
                  children: [
                    // آپ کا پرانا ایرر ڈیزائن یہاں موجود ہے...
                    Center(child: Text("LOADING ERROR", style: TextStyle(color: Colors.red))),
                    ElevatedButton(
                      onPressed: () {
                        setState(() => isError = false);
                        webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php")));
                      },
                      child: const Text("TRY AGAIN"),
                    ),
                  ],
                ),
            ],
          ),
        ),
      ),
    );
  }
}
