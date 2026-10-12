package com.knowticed.plus

import android.os.Build
import android.view.WindowManager
import io.flutter.embedding.android.FlutterActivity
import io.flutter.embedding.engine.FlutterEngine
import io.flutter.plugin.common.MethodChannel

/**
 * File Name: MainActivity.kt
 * Purpose: Hosts the Flutter engine and handles the `screen_capture` channel
 *          behind the Settings > Take Screen Shot switch.
 * Updated: 26/8/2026
 *
 * FLAG_SECURE is the real thing on Android: with it set the system refuses to
 * take a screenshot at all, screen recordings and casts capture black, and the
 * app window is left out of the recents thumbnail. Nothing else is needed and
 * no detection callback is wired here — a blocked screenshot never happens, so
 * there is nothing to report back.
 */
class MainActivity : FlutterActivity() {

    private companion object {
        const val CHANNEL = "knowticed_plus/screen_capture"
    }

    /** Mirrors the last value Dart sent, so onResume can re-assert it. */
    private var screenshotAllowed = true

    override fun configureFlutterEngine(flutterEngine: FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL)
            .setMethodCallHandler { call, result ->
                when (call.method) {
                    "setAllowed" -> {
                        val allowed = call.argument<Boolean>("allowed") ?: true
                        screenshotAllowed = allowed
                        runOnUiThread { applySecureFlag(allowed) }
                        // Android always honours FLAG_SECURE, so "blocked" is
                        // simply the inverse of the switch.
                        result.success(!allowed)
                    }
                    else -> result.notImplemented()
                }
            }
    }

    override fun onResume() {
        super.onResume()
        // A recreated activity (rotation, process death, back from a share
        // sheet) starts with a fresh window that has no flags on it.
        applySecureFlag(screenshotAllowed)
    }

    /**
     * Adds or clears FLAG_SECURE on the activity window.
     *
     * @param allowed true = screenshots permitted, false = blocked.
     */
    private fun applySecureFlag(allowed: Boolean) {
        if (allowed) {
            window.clearFlags(WindowManager.LayoutParams.FLAG_SECURE)
        } else {
            window.addFlags(WindowManager.LayoutParams.FLAG_SECURE)
        }

        // Android 13+ keeps a separate switch for the recents/app-switcher
        // preview. FLAG_SECURE already hides it, but setting this explicitly
        // keeps the two consistent if the flag is ever relaxed.
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.TIRAMISU) {
            setRecentsScreenshotEnabled(allowed)
        }
    }
}
