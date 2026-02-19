import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // GPS اور تمام پرمیشنز
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
  bool firstLoadDone = false; 
  Timer? timeoutTimer;

  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      await launchUrl(uri, mode: LaunchMode.platformDefault);
    }
  }

  void startTimer() {
    timeoutTimer?.cancel();
    timeoutTimer = Timer(const Duration(seconds: 20), () {
      if (!firstLoadDone && mounted) {
        setState(() { isError = true; isLoading = false; });
      }
    });
  }

  @override
  void dispose() {
    timeoutTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: PopScope(
          canPop: false,
          onPopInvoked: (didPop) async {
            if (didPop) return;
            if (isError) {
              SystemNavigator.pop();
            } else if (webViewController != null && await webViewController!.canGoBack()) {
              webViewController!.goBack();
            } else {
              SystemNavigator.pop();
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
                  mediaPlaybackRequiresUserGesture: false,
                ),
                onWebViewCreated: (c) {
                  webViewController = c;
                  startTimer();
                },
                
                // GPS ایکسیس کے لیے
                onPermissionRequest: (controller, request) async {
                  return PermissionResponse(
                    resources: request.resources,
                    action: PermissionResponseAction.GRANT,
                  );
                },

                onLoadStart: (c, u) {
                  if (!firstLoadDone) setState(() => isLoading = true);
                },
                onLoadStop: (c, u) {
                  timeoutTimer?.cancel();
                  setState(() {
                    isLoading = false;
                    isError = false;
                    firstLoadDone = true; 
                  });
                },
                onReceivedError: (c, r, e) {
                  if (!firstLoadDone) {
                    setState(() { isError = true; isLoading = false; });
                  }
                },
              ),
              
              if (isLoading && !isError) 
                const Center(child: CircularProgressIndicator(color: Colors.blueGrey)),

              if (isError)
                Container(
                  color: const Color(0xFFF1F4F8),
                  width: double.infinity,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text("NETWORK ERROR", style: TextStyle(fontSize: 28, fontWeight: FontWeight.w900, color: Colors.red)),
                      const SizedBox(height: 40),
                      Image.asset('support.png', width: 100), 
                      const SizedBox(height: 30),
                      InkWell(
                        onTap: () => _launchURL("https://wa.me/923140143585"),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 25, vertical: 12),
                          decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(40), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 10)]),
                          child: const Text("03140143585", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.blue)),
                        ),
                      ),
                      const SizedBox(height: 15),
                      TextButton.icon(
                        onPressed: () => _launchURL("https://chat.whatsapp.com/GK4u3GI1VZILxhMB8GZSnj"),
                        icon: const Icon(Icons.group, color: Colors.green),
                        label: const Text("Join Community", style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                      ),
                      const SizedBox(height: 50),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blueGrey),
                        onPressed: () {
                          setState(() { isError = false; isLoading = true; });
                          webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php")));
                          startTimer();
                        },
                        child: const Text("TRY AGAIN", style: TextStyle(color: Colors.white)),
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
