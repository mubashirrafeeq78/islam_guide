import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await [Permission.camera, Permission.microphone, Permission.storage].request();
  runApp(const MaterialApp(
    home: NoorAppHome(),
    debugShowCheckedModeBanner: false,
  ));
}

class NoorAppHome extends StatefulWidget {
  const NoorAppHome({super.key});

  @override
  State<NoorAppHome> createState() => _NoorAppHomeState();
}

class _NoorAppHomeState extends State<NoorAppHome> with WidgetsBindingObserver {
  InAppWebViewController? webViewController;
  bool isInitialLoading = true;
  bool showNoInternetScreen = false; 
  final String _appUrl = "https://lavenderblush-eagle-882875.hostingersite.com/dashboard.php";

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      webViewController?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_appUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                cacheEnabled: true,
                domStorageEnabled: true,
                useOnRenderProcessGone: true,
                disableDefaultErrorPage: true, // سسٹم کا ایرر پیج بلاک
              ),
              onWebViewCreated: (controller) => webViewController = controller,
              
              onLoadStart: (controller, url) {
                // لوڈنگ شروع ہوتے ہی ایرر اسکرین ہٹا دیں
                if (showNoInternetScreen) {
                  setState(() => showNoInternetScreen = false);
                }
              },
              
              onLoadStop: (controller, url) {
                setState(() {
                  isInitialLoading = false;
                  showNoInternetScreen = false;
                });
              },

              onReceivedError: (controller, request, error) {
                // اگر مین پیج لوڈ نہ ہو سکے تو کسٹم اسکرین دکھائیں
                if (request.isForMainFrame ?? false) {
                  setState(() {
                    isInitialLoading = false;
                    showNoInternetScreen = true; 
                  });
                }
              },
            ),
            
            // 1. پہلی بار اوپننگ لوڈنگ (صرف اسٹارٹ میں)
            if (isInitialLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF006400)),
                ),
              ),

            // 2. کسٹم "No Internet" اسکرین (ڈومین کو چھپانے کے لیے)
            if (showNoInternetScreen)
              Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // یہاں غلطی ٹھیک کر دی گئی ہے
                  children: [
                    const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      "No Internet Connection",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 40),
                      child: Text(
                        "Please check your connection and try again.",
                        textAlign: TextAlign.center,
                      ),
                    ),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF006400),
                        padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                      ),
                      onPressed: () {
                        setState(() {
                          showNoInternetScreen = false;
                          isInitialLoading = true;
                        });
                        webViewController?.reload();
                      },
                      child: const Text("Retry", style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    );
  }
}
