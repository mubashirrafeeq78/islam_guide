import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:location/location.dart' as loc;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
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

  // GPS کو زبردستی آن کرنے والا فنکشن
  Future<void> enableGPS() async {
    loc.Location location = loc.Location();
    bool serviceEnabled = await location.serviceEnabled();
    if (!serviceEnabled) {
      serviceEnabled = await location.requestService();
      if (!serviceEnabled) return;
    }
    await Permission.location.request();
  }

  @override
  void initState() {
    super.initState();
    enableGPS();
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
                geolocationEnabled: true,
                domStorageEnabled: true,
              ),
              onWebViewCreated: (c) => webViewController = c,
              onLoadStart: (c, u) => setState(() { isLoading = true; isError = false; }),
              onLoadStop: (c, u) => setState(() { isLoading = false; }),
              onReceivedError: (c, r, e) => setState(() { isError = true; isLoading = false; }),
              onGeolocationPermissionsShowPrompt: (c, o) async {
                return GeolocationPermissionShowPromptResponse(origin: o, allow: true, retain: true);
              },
            ),
            
            if (isLoading) const Center(child: CircularProgressIndicator(color: Colors.green)),

            // پروفیشنل ایرر اسکرین (بدصورت اینڈرائیڈ ایرر کی جگہ)
            if (isError)
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.signal_wifi_off, size: 100, color: Colors.green),
                      const SizedBox(height: 20),
                      const Text("رابطہ منقطع ہے", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                      const Padding(
                        padding: EdgeInsets.all(20),
                        child: Text("براہِ کرم اپنا انٹرنیٹ چیک کریں یا دوبارہ کوشش کریں۔", textAlign: TextAlign.center),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15)),
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
