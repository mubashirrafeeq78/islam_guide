import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Permission.location.request();
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
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Masail ka Hal"),
        backgroundColor: Colors.green,
        centerTitle: true,
      ),
      body: Stack(
        children: [
          // ویب ویو
          InAppWebView(
            initialUrlRequest: URLRequest(
              url: WebUri("https://lightslategray-pheasant-815893.hostingersite.com/dashboard.php"),
            ),
            initialSettings: InAppWebViewSettings(
              javaScriptEnabled: true,
              geolocationEnabled: true,
            ),
            onWebViewCreated: (controller) => webViewController = controller,
            onLoadStart: (controller, url) {
              setState(() {
                isLoading = true;
                isError = false;
              });
            },
            onLoadStop: (controller, url) {
              setState(() {
                isLoading = false;
              });
            },
            onReceivedError: (controller, request, error) {
              setState(() {
                isError = true;
                isLoading = false;
              });
            },
          ),

          // لوڈنگ اسکرین
          if (isLoading)
            const Center(child: CircularProgressIndicator(color: Colors.green)),

          // خوبصورت ایرر اسکرین
          if (isError)
            Container(
              color: Colors.white,
              child: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      "انٹرنیٹ کنکشن موجود نہیں ہے",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text("براہ کرم اپنا انٹرنیٹ چیک کریں اور دوبارہ کوشش کریں"),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                      onPressed: () {
                        webViewController?.reload();
                      },
                      child: const Text("دوبارہ کوشش کریں", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}
