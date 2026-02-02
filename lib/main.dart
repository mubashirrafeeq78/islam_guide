import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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
  bool isError = false;
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
  }

  // ایپ کھلتے ہی لوکیشن پرمیشن اور GPS مانگنے کے لیے
  Future<void> _checkPermissions() async {
    await Permission.location.request();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                geolocationEnabled: true, // ویب سائٹ کے لیے GPS فعال
                domStorageEnabled: true,
                mixedContentMode: MixedContentMode.MIXED_CONTENT_ALWAYS_ALLOW,
              ),
              onWebViewCreated: (controller) => webViewController = controller,
              onLoadStart: (controller, url) => setState(() { isLoading = true; isError = false; }),
              onLoadStop: (controller, url) => setState(() { isLoading = false; }),
              onReceivedError: (controller, request, error) => setState(() { isError = true; isLoading = false; }),
              
              // یہ وہ فنکشن ہے جو براؤزر کی طرح لوکیشن پاپ اپ دکھائے گا
              onGeolocationPermissionsShowPrompt: (controller, origin) async {
                return GeolocationPermissionShowPromptResponse(origin: origin, allow: true, retain: true);
              },
            ),

            if (isLoading) const Center(child: CircularProgressIndicator(color: Colors.green)),

            // پروفیشنل کسٹم ایرر اسکرین
            if (isError)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 80, color: Colors.green),
                      const SizedBox(height: 20),
                      const Text("انٹرنیٹ دستیاب نہیں ہے", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                      const SizedBox(height: 30),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => webViewController?.reload(),
                        child: const Text("دوبارہ کوشش کریں", style: TextStyle(color: Colors.white)),
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
