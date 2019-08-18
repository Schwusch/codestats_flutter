package se.bocker.codestatsflutter

import android.Manifest.permission.RECORD_AUDIO
import android.content.Intent
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlin.math.log2
import kotlin.math.pow
import kotlin.math.round

class MainActivity : FlutterActivity() {
    private var intentData: String? = null
    val disposable: CompositeDisposable = CompositeDisposable()
    private var eventSink: EventChannel.EventSink? = null


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
                "startFourier" -> {
                    if (disposable.size() == 0 && requestAudio()) {
                        start()
                        Log.d("Fourier", "Started")
                    }
                }
            }
        }


        EventChannel(flutterView, "fourierStream").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
                this@MainActivity.eventSink = eventSink
            }

            override fun onCancel(arguments: Any?) {
                this@MainActivity.eventSink = null
            }

        })
    }

    override fun onNewIntent(intent: Intent?) {
        super.onNewIntent(intent)
        if (Intent.ACTION_VIEW == intent?.action) {
            intentData = intent.data?.lastPathSegment
        }
    }

    /**
     * Dispose microphone subscriptions
     */
    private fun stop() {
        disposable.clear()
    }


    /**
     * Subscribe to microphone
     */
    private fun start() {
        val src = AudioSource().stream()

        disposable.add(src.observeOn(Schedulers.newThread())
                .map(Yin::getPitch)
                .subscribe({ freq ->
                    val note = round(12 * log2(freq / (440 * (2.0.pow(-4.75))))).toInt() % 12
                    GlobalScope.launch(Dispatchers.Main) {
                        eventSink?.success(note)
                    }

                }, { e ->
                    GlobalScope.launch(Dispatchers.Main) {
                        eventSink?.error("FourierError", e.message, e)
                    }
                    Log.e("Fourier", e.message)
                }))
    }

    private fun requestAudio(): Boolean {
        if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.M && ContextCompat.checkSelfPermission(this, RECORD_AUDIO) != PERMISSION_GRANTED) {
            Log.d("Request", "Requesting permissions")

            ActivityCompat.requestPermissions(this,
                    arrayOf(RECORD_AUDIO),
                    1337)
            return false
        }

        return true
    }

    override fun onRequestPermissionsResult(requestCode: Int, permissions: Array<out String>, grantResults: IntArray) {
        super.onRequestPermissionsResult(requestCode, permissions, grantResults)
        if (requestCode == 1337) {
            if (grantResults.firstOrNull() == PERMISSION_GRANTED) {
                Log.d("Permissions", "Permission granted")
                start()
            } else {
                Log.d("Permissions", "Permission denied")
            }
        }
    }
}
