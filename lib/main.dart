import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart'; // اس پیکج کو pubspec.yaml میں ڈالیں

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await [
    Permission.storage,
    Permission.photos, // نئے اینڈرائیڈ ورژن کے لیے
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
    final Uri whatsappUri = Uri.parse(url);
    try {
      await launchUrl(whatsappUri, mode: LaunchMode.externalApplication);
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
                  domStorageEnabled: true,
                  useOnDownloadStart: true, 
                  allowFileAccessFromFileURLs: true,
                  allowUniversalAccessFromFileURLs: true,
                ),
                onWebViewCreated: (controller) {
                  webViewController = controller;
                  
                  // یہ ہینڈلر ویب سائٹ سے ڈیٹا وصول کرے گا
                  controller.addJavaScriptHandler(handlerName: 'downloadImageHandler', callback: (args) async {
                    String base64String = args[0];
                    String fileName = args[1];
                    
                    // Base64 کو بائٹس میں بدلنا
                    Uint8List bytes = base64Decode(base64String.split(',').last);
                    
                    // گیلری میں محفوظ کرنا
                    final result = await ImageGallerySaver.saveImage(bytes, name: fileName);
                    
                    if (result['isSuccess']) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text("تصویر گیلری میں محفوظ کر دی گئی ہے")),
                      );
                    }
                  });
                },
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(resources: request.resources, action: PermissionResponseAction.GRANT);
                },
                onLoadStart: (c, u) => setState(() { isLoading = true; isError = false; }),
                onLoadStop: (c, u) => setState(() { isLoading = false; }),
                onReceivedError: (c, r, e) {
                  setState(() { isError = true; isLoading = false; });
                },
              ),
              
              if (isLoading) const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

              if (isError)
                Container(
                  color: const Color(0xFFF1F4F8),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("LOADING ERROR", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.red)),
                      const SizedBox(height: 50),
                      const Icon(Icons.support_agent, size: 100, color: Colors.blueGrey),
                      const SizedBox(height: 30),
                      const Text("HELP SUPPORT", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                      const SizedBox(height: 20),
                      InkWell(
                        onTap: _openWhatsAppChooser,
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                          child: const Text("00923140143585", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ),
                      ),
                      const SizedBox(height: 60),
                      ElevatedButton(
                        onPressed: () {
                          setState(() => isError = false);
                          webViewController?.reload();
                        },
                        child: const Text("TRY AGAIN"),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
