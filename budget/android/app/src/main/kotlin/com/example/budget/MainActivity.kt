package com.budget.tracker_app

import androidx.annotation.NonNull
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity: FlutterFragmentActivity() {
    private val CHANNEL = "com.budget.tracker_app/finvu"

    override fun configureFlutterEngine(@NonNull flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            when (call.method) {
                "initialize" -> {
                    // TODO: Initialize Finvu SDK
                    result.success(null)
                }
                "connect" -> {
                    // TODO: Start Finvu connection flow
                    result.success(null)
                }
                "fetchTransactions" -> {
                    // TODO: Fetch transactions from Finvu
                    result.success(listOf<Any>())
                }
                else -> {
                    result.notImplemented()
                }
            }
        }
    }
}
