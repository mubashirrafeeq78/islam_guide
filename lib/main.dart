// اس حصے کو Stack کے اندر ریپلیس کریں
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
    // یہاں تبدیلی کی گئی ہے تاکہ ڈومین نظر نہ آئے
    onReceivedError: (c, r, e) {
      c.loadUrl(urlRequest: URLRequest(url: WebUri("about:blank"))); // ڈومین چھپانے کے لیے
      setState(() { isError = true; isLoading = false; });
    },
    onGeolocationPermissionsShowPrompt: (c, o) async {
      return GeolocationPermissionShowPromptResponse(origin: o, allow: true, retain: true);
    },
  ),

  if (isLoading) const Center(child: CircularProgressIndicator(color: Colors.green)),

  if (isError)
    Container(
      color: Colors.white,
      width: double.infinity,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.wifi_off, size: 80, color: Colors.green),
          const SizedBox(height: 20),
          const Text("انٹرنیٹ دستیاب نہیں ہے", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          // دوبارہ کوشش کا بٹن
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
            onPressed: () => webViewController?.reload(),
            child: const Text("دوبارہ کوشش کریں", style: TextStyle(color: Colors.white)),
          ),
          const SizedBox(height: 40),
          // واٹس ایپ ہیلپ سپورٹ
          const Text("Help & Support", style: TextStyle(fontSize: 14, color: Colors.grey)),
          const SizedBox(height: 10),
          InkWell(
            onTap: () => webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("https://wa.me/923140143585"))),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.whatsapp, color: Colors.green, size: 30),
                const SizedBox(width: 10),
                Text("03140143585", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
              ],
            ),
          ),
        ],
      ),
    ),
],
