import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:webview_flutter/webview_flutter.dart';

void main() => runApp(const MaterialApp(home: SafeArea(child: AppBody()), debugShowCheckedModeBanner: false));

class AppBody extends StatefulWidget {
  const AppBody({super.key});
  @override State<AppBody> createState() => _AppBodyState();
}

class _AppBodyState extends State<AppBody> {
  late final WebViewController controller;
  bool isLoading = true;
  bool hasError = false;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(NavigationDelegate(
        onPageStarted: (url) => setState(() { isLoading = true; hasError = false; }),
        onPageFinished: (url) => setState(() { isLoading = false; }),
        onWebResourceError: (error) => setState(() => hasError = true),
      ))
      ..loadRequest(Uri.parse('https://lightslategray-pheasant-815893.hostingersite.com/dashboard.html'));
  }

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvoked: (didPop) async {
        if (didPop) return;
        // iFrame ہسٹری چیک کرنے کا خفیہ جاوا اسکرپٹ طریقہ
        final Object result = await controller.runJavaScriptReturningResult("window.history.length > 1");
        if (result.toString() == 'true') {
          controller.runJavaScript("window.history.back();");
        } else {
          SystemChannels.platform.invokeMethod('SystemNavigator.pop');
        }
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            if (!hasError) WebViewWidget(controller: controller),
            if (isLoading) const Center(child: CircularProgressIndicator(color: Colors.green)),
            if (hasError) _buildErrorUI(),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorUI() {
    return Container(
      color: Colors.white,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.wifi_off_rounded, size: 80, color: Colors.green),
            const SizedBox(height: 20),
            const Text("انٹرنیٹ موجود نہیں ہے", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            const SizedBox(height: 30),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.green, foregroundColor: Colors.white),
              onPressed: () => controller.reload(),
              child: const Text("دوبارہ کوشش کریں"),
            )
          ],
        ),
      ),
    );
  }
}
