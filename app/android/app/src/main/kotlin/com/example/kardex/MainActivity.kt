package com.example.kardex

import android.app.AppOpsManager
import android.app.usage.UsageStatsManager
import android.content.Context
import android.content.Intent
import android.os.Process
import android.provider.Settings
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import java.util.concurrent.TimeUnit

class MainActivity : FlutterActivity() {
    private val channel = "kardex/usage"
    private val mappedPackages = setOf(
        "com.spotify.music",
        "in.startv.hotstar",
        "com.netflix.mediaclient",
        "com.google.android.apps.docs",
        "com.google.android.youtube",
        "com.openai.chatgpt"
    )

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, channel).setMethodCallHandler { call, result ->
            when (call.method) {
                "hasUsageAccess" -> result.success(hasUsageAccess())
                "requestUsageAccess" -> {
                    startActivity(Intent(Settings.ACTION_USAGE_ACCESS_SETTINGS))
                    result.success(true)
                }
                "queryUsage" -> {
                    val days = (call.argument<Int>("days") ?: 30).coerceIn(1, 60)
                    result.success(queryUsage(days))
                }
                else -> result.notImplemented()
            }
        }
    }

    private fun hasUsageAccess(): Boolean {
        val appOps = getSystemService(Context.APP_OPS_SERVICE) as AppOpsManager
        return appOps.checkOpNoThrow(
            AppOpsManager.OPSTR_GET_USAGE_STATS, Process.myUid(), packageName
        ) == AppOpsManager.MODE_ALLOWED
    }

    private fun queryUsage(days: Int): List<Map<String, Any>> {
        if (!hasUsageAccess()) return emptyList()
        val end = System.currentTimeMillis()
        val start = end - TimeUnit.DAYS.toMillis(days.toLong())
        val manager = getSystemService(Context.USAGE_STATS_SERVICE) as UsageStatsManager
        val launches = mutableMapOf<String, Int>()
        val events = manager.queryEvents(start, end)
        val event = android.app.usage.UsageEvents.Event()
        while (events.hasNextEvent()) {
            events.getNextEvent(event)
            if (event.eventType == android.app.usage.UsageEvents.Event.MOVE_TO_FOREGROUND) {
                launches[event.packageName] = (launches[event.packageName] ?: 0) + 1
            }
        }
        return manager.queryUsageStats(UsageStatsManager.INTERVAL_DAILY, start, end)
            .filter { it.totalTimeInForeground > 0 && mappedPackages.contains(it.packageName) }
            .map {
                mapOf(
                    "android_package" to it.packageName,
                    "usage_minutes" to (it.totalTimeInForeground / 60000.0),
                    "last_used_at" to it.lastTimeUsed,
                    "launch_count" to (launches[it.packageName] ?: 0)
                )
            }
    }
}
