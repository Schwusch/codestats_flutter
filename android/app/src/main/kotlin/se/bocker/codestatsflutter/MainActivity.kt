package se.bocker.codestatsflutter

import android.content.Intent
import android.os.Bundle
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.flutter.embedding.android.FlutterActivity

class MainActivity : FlutterActivity() {
    private var intentData: String? = null

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        GeneratedPluginRegistrant.registerWith(this)

        if (Intent.ACTION_VIEW == intent.action) {
            intentData = intent.data?.lastPathSegment
        }

        MethodChannel(flutterView, "app.channel.shared.data").setMethodCallHandler { methodCall, result ->
            when (methodCall.method) {
                "getIntentLastPathSegment" -> {
                    result.success(intentData)
                    intentData = null
                }
            }
        }
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        if (Intent.ACTION_VIEW == intent?.action) {
            intentData = intent.data?.lastPathSegment
        }
    }
}
