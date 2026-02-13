package com.masail.hal.islam_guide

import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.os.Environment
import android.webkit.URLUtil
import android.webkit.WebView
import android.view.ViewGroup
import android.view.View
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onPostResume() {
        super.onPostResume()
        
        // یہ حصہ ایپ میں ویب ویو کو تلاش کرے گا
        val rootView = window.decorView.rootView as ViewGroup
        val webView = findWebView(rootView)

        // جب ویب سائٹ پر ڈاؤن لوڈ کے بٹن پر کلک ہوگا تو یہ حصہ کام کرے گا
        webView?.setDownloadListener { url, userAgent, contentDisposition, mimetype, _ ->
            try {
                val request = DownloadManager.Request(Uri.parse(url))
                val fileName = URLUtil.guessFileName(url, contentDisposition, mimetype)

                request.setMimeType(mimetype)
                request.addRequestHeader("User-Agent", userAgent)
                request.setTitle(fileName)
                request.setDescription("تصویر محفوظ کی جا رہی ہے...")
                request.setNotificationVisibility(DownloadManager.Request.VISIBILITY_VISIBLE_NOTIFY_COMPLETED)
                request.setDestinationInExternalPublicDir(Environment.DIRECTORY_DOWNLOADS, fileName)

                val dm = getSystemService(Context.DOWNLOAD_SERVICE) as DownloadManager
                dm.enqueue(request)

                Toast.makeText(this, "ڈاؤن لوڈ شروع ہو گیا ہے...", Toast.LENGTH_SHORT).show()
            } catch (e: Exception) {
                Toast.makeText(this, "ڈاؤن لوڈ میں مسئلہ: ${e.message}", Toast.LENGTH_LONG).show()
            }
        }
    }

    // ویب ویو ڈھونڈنے کا فنکشن
    private fun findWebView(view: View): WebView? {
        if (view is WebView) {
            return view
        }
        if (view is ViewGroup) {
            for (i in 0 until view.childCount) {
                val result = findWebView(view.getChildAt(i))
                if (result != null) return result
            }
        }
        return null
    }
}
