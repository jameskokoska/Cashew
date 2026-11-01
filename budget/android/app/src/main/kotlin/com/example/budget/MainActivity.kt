package com.budget.tracker_app

import android.Manifest
import android.content.BroadcastReceiver
import android.content.Context
import android.content.Intent
import android.content.IntentFilter
import android.content.pm.PackageManager
import android.os.Build
import android.os.Handler
import android.os.Looper
import android.provider.Telephony
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import io.flutter.embedding.android.FlutterFragmentActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterFragmentActivity() {
    private val smsChannel = "cashew/sms"
    private val smsEventsChannel = "cashew/sms_events"
    private val smsPermissionRequest = 4471

    private var pendingPermissionResult: MethodChannel.Result? = null
    private var smsReceiver: BroadcastReceiver? = null
    private val mainHandler = Handler(Looper.getMainLooper())

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, smsChannel)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "hasPermission" -> result.success(hasSmsPermission())
                    "requestPermission" -> {
                        if (hasSmsPermission()) {
                            result.success(true)
                        } else {
                            pendingPermissionResult?.success(false)
                            pendingPermissionResult = result
                            ActivityCompat.requestPermissions(
                                this,
                                arrayOf(Manifest.permission.READ_SMS, Manifest.permission.RECEIVE_SMS),
                                smsPermissionRequest
                            )
                        }
                    }
                    "getMessages" -> {
                        if (!hasSmsPermission()) {
                            result.error("NO_PERMISSION", "SMS permission not granted", null)
                            return@setMethodCallHandler
                        }
                        val since = (call.argument<Number>("since") ?: 0).toLong()
                        val until = (call.argument<Number>("until") ?: Long.MAX_VALUE).toLong()
                        val limit = (call.argument<Number>("limit") ?: 5000).toInt()
                        Thread {
                            try {
                                val messages = readInbox(since, until, limit)
                                mainHandler.post { result.success(messages) }
                            } catch (e: Exception) {
                                mainHandler.post { result.error("READ_FAILED", e.message, null) }
                            }
                        }.start()
                    }
                    else -> result.notImplemented()
                }
            }

        EventChannel(flutterEngine.dartExecutor.binaryMessenger, smsEventsChannel)
            .setStreamHandler(object : EventChannel.StreamHandler {
                override fun onListen(arguments: Any?, events: EventChannel.EventSink) {
                    registerSmsReceiver(events)
                }

                override fun onCancel(arguments: Any?) {
                    unregisterSmsReceiver()
                }
            })
    }

    private fun hasSmsPermission(): Boolean =
        ContextCompat.checkSelfPermission(this, Manifest.permission.READ_SMS) ==
            PackageManager.PERMISSION_GRANTED

    private fun readInbox(since: Long, until: Long, limit: Int): List<Map<String, Any?>> {
        val out = ArrayList<Map<String, Any?>>()
        val projection = arrayOf(
            Telephony.Sms._ID,
            Telephony.Sms.ADDRESS,
            Telephony.Sms.BODY,
            Telephony.Sms.DATE
        )
        contentResolver.query(
            Telephony.Sms.Inbox.CONTENT_URI,
            projection,
            "${Telephony.Sms.DATE} > ? AND ${Telephony.Sms.DATE} <= ?",
            arrayOf(since.toString(), until.toString()),
            "${Telephony.Sms.DATE} ASC"
        )?.use { cursor ->
            val idIdx = cursor.getColumnIndexOrThrow(Telephony.Sms._ID)
            val addressIdx = cursor.getColumnIndexOrThrow(Telephony.Sms.ADDRESS)
            val bodyIdx = cursor.getColumnIndexOrThrow(Telephony.Sms.BODY)
            val dateIdx = cursor.getColumnIndexOrThrow(Telephony.Sms.DATE)
            while (cursor.moveToNext() && out.size < limit) {
                out.add(
                    mapOf(
                        "id" to cursor.getLong(idIdx).toString(),
                        "address" to cursor.getString(addressIdx),
                        "body" to cursor.getString(bodyIdx),
                        "date" to cursor.getLong(dateIdx)
                    )
                )
            }
        }
        return out
    }

    private fun registerSmsReceiver(events: EventChannel.EventSink) {
        unregisterSmsReceiver()
        if (!hasSmsPermission()) return
        val receiver = object : BroadcastReceiver() {
            override fun onReceive(context: Context?, intent: Intent?) {
                if (intent?.action != Telephony.Sms.Intents.SMS_RECEIVED_ACTION) return
                val parts = Telephony.Sms.Intents.getMessagesFromIntent(intent) ?: return
                // Long SMS arrive in several parts; join them per sender.
                val bySender = LinkedHashMap<String, StringBuilder>()
                var timestamp = System.currentTimeMillis()
                for (part in parts) {
                    val address = part.originatingAddress ?: ""
                    bySender.getOrPut(address) { StringBuilder() }.append(part.messageBody ?: "")
                    timestamp = part.timestampMillis
                }
                for ((address, body) in bySender) {
                    events.success(
                        mapOf(
                            "id" to null,
                            "address" to address,
                            "body" to body.toString(),
                            "date" to timestamp
                        )
                    )
                }
            }
        }
        val filter = IntentFilter(Telephony.Sms.Intents.SMS_RECEIVED_ACTION)
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            registerReceiver(receiver, filter, Context.RECEIVER_EXPORTED)
        } else {
            registerReceiver(receiver, filter)
        }
        smsReceiver = receiver
    }

    private fun unregisterSmsReceiver() {
        smsReceiver?.let {
            try {
                unregisterReceiver(it)
            } catch (_: Exception) {
            }
        }
        smsReceiver = null
    }

    override fun onRequestPermissionsResult(
        requestCode: Int,
        permissions: Array<out String>,
        grantResults: IntArray
    ) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == smsPermissionRequest) {
            pendingPermissionResult?.success(hasSmsPermission())
            pendingPermissionResult = null
        }
    }

    override fun onDestroy() {
        unregisterSmsReceiver()
        super.onDestroy()
    }
}
