package com.example.device_info_app

import android.Manifest
import android.content.pm.PackageManager
import android.os.Build
import android.os.Bundle
import android.telephony.TelephonyManager
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterActivity() {
    private val CHANNEL = "device_info"
    private val REQUEST_CODE = 1

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            if (call.method == "getDeviceInfo") {
                if (ContextCompat.checkSelfPermission(this, Manifest.permission.READ_PHONE_STATE) == PackageManager.PERMISSION_GRANTED) {
                    val deviceInfo = getDeviceInfo()
                    if (deviceInfo != null) {
                        result.success(deviceInfo)
                    } else {
                        result.error("UNAVAILABLE", "Device info not available.", null)
                    }
                } else {
                    ActivityCompat.requestPermissions(this, arrayOf(Manifest.permission.READ_PHONE_STATE), REQUEST_CODE)
                }
            } else {
                result.notImplemented()
            }
        }
    }

    @RequiresApi(Build.VERSION_CODES.O)
    private fun getDeviceInfo(): Map<String, String>? {
        val telephonyManager = getSystemService(TELEPHONY_SERVICE) as TelephonyManager
        val deviceInfo = mutableMapOf<String, String>()
        deviceInfo["imei"] = telephonyManager.imei
        deviceInfo["serial"] = Build.getSerial()
        deviceInfo["brand"] = Build.BRAND
        deviceInfo["model"] = Build.MODEL
        deviceInfo["os_version"] = Build.VERSION.RELEASE
        return deviceInfo
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        if (requestCode == REQUEST_CODE) {
            if (grantResults.isNotEmpty() && grantResults[0] == PackageManager.PERMISSION_GRANTED) {
                val deviceInfo = getDeviceInfo()
                MethodChannel(flutterEngine!!.dartExecutor.binaryMessenger, CHANNEL).invokeMethod("getDeviceInfo", deviceInfo)
            }
        }
    }
}
