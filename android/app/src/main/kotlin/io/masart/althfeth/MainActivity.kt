package io.masart.althfeth

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel
import android.content.Intent
import android.net.Uri

class MainActivity: FlutterActivity() {
    private val CHANNEL = "com.example.app/whatsapp"

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "openWhatsApp" -> {
                        val phone = call.argument<String>("phone")
                        val message = call.argument<String>("message")
                        
                        if (phone != null && message != null) {
                            openWhatsApp(phone, message)
                            result.success(true)
                        } else {
                            result.error("INVALID_ARGS", "Phone or message is null", null)
                        }
                    }
                    else -> result.notImplemented()
                }
            }
    }

    private fun openWhatsApp(phone: String, message: String) {
        try {
            // ✅ الطريقة 1: استخدام Intent مع whatsapp:// مباشرة
            val intent = Intent()
            intent.action = Intent.ACTION_VIEW
            intent.data = Uri.parse("whatsapp://send?phone=$phone&text=${Uri.encode(message)}")
            startActivity(intent)
        } catch (e1: Exception) {
            try {
                // ✅ الطريقة 2: استخدام Intent مع whatsapp:// بدون رسالة
                val intent = Intent()
                intent.action = Intent.ACTION_VIEW
                intent.data = Uri.parse("whatsapp://send?phone=$phone")
                startActivity(intent)
            } catch (e2: Exception) {
                try {
                    // ✅ الطريقة 3: فتح WhatsApp مباشرة بدون رسالة
                    val intent = Intent()
                    intent.action = Intent.ACTION_VIEW
                    intent.setPackage("com.whatsapp")
                    intent.data = Uri.parse("https://wa.me/$phone")
                    startActivity(intent)
                } catch (e3: Exception) {
                    try {
                        // ✅ الطريقة 4: فتح في المتصفح الافتراضي
                        val intent = Intent()
                        intent.action = Intent.ACTION_VIEW
                        intent.data = Uri.parse("https://wa.me/$phone")
                        startActivity(intent)
                    } catch (e4: Exception) {
                        e4.printStackTrace()
                    }
                }
            }
        }
    }
}
