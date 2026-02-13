package com.masail.hal.islam_guide

import android.app.DownloadManager
import android.content.Context
import android.net.Uri
import android.os.Environment
import android.webkit.URLUtil
import android.webkit.WebView
import android.webkit.WebViewClient
import android.view.ViewGroup
import android.view.View
import android.widget.Toast
import io.flutter.embedding.android.FlutterActivity

class MainActivity: FlutterActivity() {

    override fun onPostResume() {
        super.onPostResume()
        val rootView = window.decorView.rootView as ViewGroup
        val webView = findWebView(rootView)

        // ڈاؤن لوڈ کو ہینڈل کرنا تاکہ براؤزر نہ کھلے
        webView?.setDownloadListener { url, userAgent, contentDisposition, mimetype, _ ->
            downloadFile(url, userAgent, contentDisposition, mimetype)
        }

        // اگر لنک تصویر کا ہے تو اسے ایپ کے اندر ہی روک کر ڈاؤن لوڈ کرنا
        webView?.webViewClient = object : WebViewClient() {
            override fun shouldOverrideUrlLoading(view: WebView?, url: String?): Boolean {
                if (url != null && (url.endsWith(".jpg") || url.endsWith(".png") || url.endsWith(".jpeg"))) {
                    downloadFile(url, "", "", "image/jpeg")
                    return true // اس کا مطلب ہے براؤزر میں نہیں کھلے گا
                }
                return false
            }
        }
    }

    private fun downloadFile(url: String, userAgent: String, contentDisposition: String, mimetype: String) {
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

    private fun findWebView(view: View): WebView? {
        if (view is WebView) return view
        if (view is ViewGroup) {
            for (i in 0 until view.childCount) {
                val result = findWebView(view.getChildAt(i))
                if (result != null) return result
            }
        }
        return null
    }
}
