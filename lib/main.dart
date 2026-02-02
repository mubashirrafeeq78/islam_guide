import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
  runApp(const MaterialApp(
    title: "Masail ka Hal", // ایپ کا صحیح نام
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
  Widget build(BuildContext context) {
    return Scaffold(
      // یہاں سے AppBar (سبز پٹی) ختم کر دی گئی ہے
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(
                url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"),
              ),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                geolocationEnabled: true,
                useWideViewPort: true,
                loadWithOverviewMode: true,
                domStorageEnabled: true, // ویب سائٹ ڈیٹا لوڈ کرنے کے لیے ضروری
              ),
              onWebViewCreated: (controller) => webViewController = controller,
              onLoadStart: (controller, url) => setState(() { isLoading = true; isError = false; }),
              onLoadStop: (controller, url) => setState(() { isLoading = false; }),
              onReceivedError: (controller, request, error) => setState(() { isError = true; isLoading = false; }),
            ),

            if (isLoading)
              const Center(child: CircularProgressIndicator(color: Colors.green)),

            if (isError)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                      const SizedBox(height: 20),
                      const Text("انٹرنیٹ کا مسئلہ ہے", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      ElevatedButton(
                        onPressed: () => webViewController?.reload(),
                        child: const Text("دوبارہ کوشش کریں"),
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
