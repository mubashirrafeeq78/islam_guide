package com.masail.hal.islam_guide

import android.os.Bundle
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        // ریسنٹ ایپس میں ڈیٹا چھپانے کے لیے
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
    }

    override fun onResume() {
        super.onResume()
        // سیکیورٹی برقرار رکھنے کے لیے فلیگ دوبارہ سیٹ کریں
        window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        
        // یہ لائن فلٹر انجن کو ریفریش کرنے میں مدد دیتی ہے
        // جب ایپ دوبارہ اوپن ہوگی تو یہ ویب ویو کو دوبارہ لوڈ کرنے کا سگنل دے گی
        flutterEngine?.navigationControlSurface?.onUserLeaveHint()
    }

    // یہ فنکشن ایمرجنسی میں کام آتا ہے
    override fun onUserLeaveHint() {
        super.onUserLeaveHint()
        // جب یوزر ہوم بٹن دبائے گا، تو یہ ایپ کی میموری کو تازہ کر دے گا
    }
}
