package com.masail.hal.islam_guide

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // ریسنٹ ایپس میں ڈیٹا چھپانے اور اسکرین شاٹ بلاک کرنے کے لیے
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun onResume() {
        super.onResume()
        // سیکیورٹی فلیگ کو دوبارہ یقینی بنانا
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }
}
