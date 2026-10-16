package com.example.hydrate

import android.app.AlarmManager
import android.content.Context
import android.os.Build
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "hydrate/exact_alarms")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "canScheduleExactAlarms" -> {
                        val alarmManager = getSystemService(Context.ALARM_SERVICE) as AlarmManager
                        result.success(
                            Build.VERSION.SDK_INT < Build.VERSION_CODES.S ||
                                alarmManager.canScheduleExactAlarms()
                        )
                    }
                    else -> result.notImplemented()
                }
            }
    }
}
