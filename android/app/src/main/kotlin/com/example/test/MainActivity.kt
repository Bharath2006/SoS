package com.example.test
import android.Manifest
import android.content.Intent
import android.content.pm.PackageManager
import android.net.Uri
import android.os.Bundle
import android.telephony.SmsManager
import android.util.Log
import android.widget.Toast
import androidx.annotation.NonNull
import androidx.core.app.ActivityCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    private val CHANNEL = "sms_sender_channel"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "sendSMS" -> {
                    val phones = call.argument<List<String>>("phones")
                    val message = call.argument<String>("message")
                    sendSMS(phones, message)
                    result.success(null)
                }
                "sendWhatsApp" -> {
                    val phones = call.argument<List<String>>("phones")
                    val message = call.argument<String>("message")
                    sendWhatsApp(phones, message)
                    result.success(null)
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }

    private fun sendSMS(phones: List<String>?, message: String?) {
        if (phones == null || message == null) return

        for (phone in phones) {
            // Check if SMS permission is granted
            if (ActivityCompat.checkSelfPermission(this, Manifest.permission.SEND_SMS) != PackageManager.PERMISSION_GRANTED) {
                // Request permission if not granted
                ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.SEND_SMS), 1)
                return
            }

            // If permission is granted, send SMS directly
            try {
                val smsManager = SmsManager.getDefault()
                smsManager.sendTextMessage(phone, null, message, null, null)
                Toast.makeText(this, "SMS sent to $phone", Toast.LENGTH_SHORT).show()
            } catch (e: Exception) {
                Log.e("SMS_ERROR", "Error sending SMS: ${e.message}")
            }
        }
    }

    private fun sendWhatsApp(phones: List<String>?, message: String?) {
        if (phones == null || message == null) return

        for (phone in phones) {
            val url = "https://wa.me/$phone?text=${Uri.encode(message)}"
            val intent = Intent(Intent.ACTION_VIEW)
            intent.data = Uri.parse(url)
            startActivity(intent)
        }
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                // Permission granted
                Toast.makeText(this, "SMS permission granted.", Toast.LENGTH_SHORT).show()
            } else {
                // Permission denied
                Toast.makeText(this, "SMS permission is required to send messages.", Toast.LENGTH_SHORT).show()
            }
        }
    }
}
