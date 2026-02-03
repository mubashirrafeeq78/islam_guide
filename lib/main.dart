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
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                        onPressed: () => webViewController?.reload(),
                        child: const Text("دوبارہ کوشش کریں", style: TextStyle(color: Colors.white)),
                      ),
                      const SizedBox(height: 40),
                      const Text("Help & Support", style: TextStyle(fontSize: 14, color: Colors.grey)),
                      const SizedBox(height: 10),
                      InkWell(
                        onTap: () => webViewController?.loadUrl(urlRequest: URLRequest(url: WebUri("https://wa.me/923140143585"))),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            const Icon(Icons.chat, color: Colors.green, size: 30), // واٹس ایپ کی جگہ چیٹ آئیکون
                            const SizedBox(width: 10),
                            Text("03140143585", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.green.shade800)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
