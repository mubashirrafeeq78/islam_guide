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
  bool isInitialLoading = true; // صرف پہلی بار لوڈنگ دکھانے کے لیے
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
      body: SafeArea(
        child: Stack(
          children: [
            InAppWebView(
              initialUrlRequest: URLRequest(url: WebUri(_appUrl)),
              initialSettings: InAppWebViewSettings(
                javaScriptEnabled: true,
                cacheEnabled: true, // ڈیٹا محفوظ رکھنے کے لیے
                domStorageEnabled: true,
                mediaPlaybackRequiresUserGesture: false,
                allowsInlineMediaPlayback: true,
                // اینڈرائیڈ کا اپنا ایرر پیج بلاک کرنے کے لیے
                useOnRenderProcessGone: true,
              ),
              onWebViewCreated: (controller) => webViewController = controller,
              
              onLoadStart: (controller, url) {
                // ہم یہاں isLoading کو دوبارہ true نہیں کریں گے تاکہ پیج کے دوران لوڈنگ نہ آئے
              },
              
              onLoadStop: (controller, url) {
                setState(() {
                  isInitialLoading = false; // جیسے ہی پہلی بار لوڈ ہوا، لوڈنگ ختم
                });
              },

              onReceivedError: (controller, request, error) {
                // انٹرنیٹ مکمل بند ہو یا سگنل کم ہوں، یہ لائن کسی بھی ایرر کو اسکرین پر آنے نہیں دے گی
                // یوزر کو وہی نظر آئے گا جو پہلے سے اسکرین پر موجود تھا
                return; 
              },

              onReceivedHttpError: (controller, request, errorResponse) {
                // سرور کی طرف سے آنے والے ایررز کو بھی بلاک کر دیا گیا ہے
                return;
              },

              androidOnPermissionRequest: (controller, origin, resources) async {
                return PermissionRequestResponse(
                  resources: resources,
                  action: PermissionRequestResponseAction.GRANT,
                );
              },
            ),
            
            // صرف پہلی بار ایپ کھلتے وقت کا لوڈنگ انڈیکیٹر
            if (isInitialLoading)
              Container(
                color: Colors.white,
                child: const Center(
                  child: CircularProgressIndicator(
                    color: Color(0xFF006400),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
