package com.kidlearn.kidlearn_game

import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

class MainActivity : FlutterActivity() {
    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)
        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, "kidlearn/lock_task")
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "start" -> { try { startLockTask() } catch (_: Exception) {}; result.success(null) }
                    "stop"  -> { try { stopLockTask()  } catch (_: Exception) {}; result.success(null) }
                    else    -> result.notImplemented()
                }
            }
    }
}
