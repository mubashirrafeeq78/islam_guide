import 'package:flutter/material.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:permission_handler/permission_handler.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // کیمرہ، مائیکروفون اور اسٹوریج کی پرمیشنز شروع میں ہی مانگنا
  await [
    Permission.camera,
    Permission.microphone,
    Permission.storage,
  ].request();

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
    // صرف تب ری لوڈ کریں جب ایپ مکمل طور پر دوبارہ سامنے آئے (Resumed)
    // اور میڈیا پکنگ کے دوران ہونے والے پوز (Inactive) کو نظر انداز کرے
    if (state == AppLifecycleState.resumed) {
      webViewController?.reload();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: InAppWebView(
          initialUrlRequest: URLRequest(url: WebUri(_appUrl)),
          initialSettings: InAppWebViewSettings(
            javaScriptEnabled: true,
            cacheEnabled: false,
            clearCache: true,
            // میڈیا اور کیمرہ پرمیشنز کو ویب ویو کے اندر الاؤ کرنا
            mediaPlaybackRequiresUserGesture: false,
            allowsInlineMediaPlayback: true,
          ),
          onWebViewCreated: (controller) {
            webViewController = controller;
          },
          // یہ حصہ ویب سائٹ کے اندر پرمیشنز (کیمرہ وغیرہ) کو ہینڈل کرے گا
          androidOnPermissionRequest: (controller, origin, resources) async {
            return PermissionRequestResponse(
              resources: resources,
              action: PermissionRequestResponseAction.GRANT,
            );
          },
        ),
      ),
    );
  }
}
