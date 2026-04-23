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
                setState(() {
                  showNoInternetScreen = false;
                });
              },
              onLoadStop: (controller, url) {
                setState(() {
                  isInitialLoading = false;
                  showNoInternetScreen = false;
                });
              },
              onReceivedError: (controller, request, error) {
                // صرف مین پیج کے ایرر پر کسٹم اسکرین دکھائیں
                if (request.isForMainFrame ?? false) {
                  setState(() {
                    isInitialLoading = false;
                    showNoInternetScreen = true; 
                  });
                }
              },
            ),
            
            if (isInitialLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(color: Color(0xFF006400)),
                ),
              ),

            if (showNoInternetScreen)
              Container(
                color: Colors.white,
                width: double.infinity,
                height: double.infinity,
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center, // یہاں درستگی کر دی گئی ہے
                  children: [
                    const Icon(Icons.wifi_off, size: 80, color: Colors.grey),
                    const SizedBox(height: 20),
                    const Text(
                      "No Internet Connection",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 10),
                    const Text("Please check your connection and try again."),
                    const SizedBox(height: 30),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF006400)),
                      onPressed: () => webViewController?.reload(),
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
