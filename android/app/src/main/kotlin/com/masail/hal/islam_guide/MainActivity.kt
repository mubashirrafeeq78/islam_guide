package com.masail.hal.islam_guide

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // ریسنٹ ایپس میں اسکرین کو بلر/کالا کرنے کے لیے
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun onResume() {
        super.onResume()
        // جب بھی یوزر ایپ پر واپس آئے، یہ سسٹم کو ریفریش سگنل بھیجتا ہے
        // فلٹر کا انجن خود بخود ویجیٹس کو ری بلڈ کرے گا
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
