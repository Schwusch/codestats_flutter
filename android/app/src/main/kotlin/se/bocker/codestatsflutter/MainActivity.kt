package se.bocker.codestatsflutter

import android.Manifest.permission.RECORD_AUDIO
import android.content.Intent
import android.content.pm.PackageManager.PERMISSION_GRANTED
import android.os.Build
import android.os.Bundle
import android.util.Log
import androidx.core.app.ActivityCompat
import androidx.core.content.ContextCompat
import com.paramsen.noise.Noise

import io.flutter.app.FlutterActivity
import io.flutter.plugin.common.EventChannel
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugins.GeneratedPluginRegistrant
import io.reactivex.disposables.CompositeDisposable
import io.reactivex.schedulers.Schedulers
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.launch
import kotlin.math.sqrt

class MainActivity : FlutterActivity() {
    private var intentData: String? = null
    val disposable: CompositeDisposable = CompositeDisposable()
    private var eventSink: EventChannel.EventSink? = null

    private val bands = 64
    private val size = 4096

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


        EventChannel(flutterView, "fourierStream").setStreamHandler(object : EventChannel.StreamHandler {
            override fun onListen(arguments: Any?, eventSink: EventChannel.EventSink?) {
                this@MainActivity.eventSink = eventSink
                if (requestAudio() && disposable.size() == 0) {
                    start()
                    Log.d("Fourier", "Started")
                }
            }

            override fun onCancel(arguments: Any?) {
                this@MainActivity.eventSink = null
                stop()
                Log.d("Fourier", "Stopped")
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
        val noise = Noise.real().optimized().init(size, false)


        //FFTView
        disposable.add(src.observeOn(Schedulers.newThread())
                .map {
                    for (i in 0 until it.size)
                        it[i] *= 2.0f
                    return@map it
                }
                .map { noise.fft(it, FloatArray(size + 2)) }
                .subscribe({ fft ->
                    eventSink?.let { eventSink ->
                        fft.asIterable()
                                .zipWithNext()
                                .map { sqrt(it.first * it.first + it.second * it.second) }
                                .toList()
                                .let { buckets ->
                                    val windowFactors = triang(bands + 1)
                                    val frequencies = buckets
                                            .chunked(buckets.size / bands) { it.average() }
                                            .mapIndexed { i, amp -> amp * windowFactors[i] }
                                    val loudestFreq = (RATE_HZ / (2 * bands)) * frequencies.indexOf(frequencies.max())
                                    GlobalScope.launch(Dispatchers.Main) {
                                        eventSink.success(loudestFreq)
                                    }
                                }
                    }
                }, { e ->
                    eventSink?.error("FourierError", e.message, e)
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

    /**
     * Triangular window of size N
     * @see [MATLAB reference](https://www.mathworks.com/help/signal/ref/triang.html)
     */
    private fun triang(N: Int): DoubleArray {
        val w = DoubleArray(N)

        var n = 0
        if (N % 2 == 1) {
            while (n < (N + 1) / 2) {
                w[n] = 2.0 * (n + 1) / (N + 1)
                n++
            }
            while (n < N) {
                w[n] = 2 - 2.0 * (n + 1) / (N + 1)
                n++
            }
        } else {
            while (n < N / 2) {
                w[n] = (2.0 * (n + 1) - 1) / N
                n++
            }
            while (n < N) {
                w[n] = 2 - (2.0 * (n + 1) - 1) / N
                n++
            }
        }

        return w
    }

    /**
     * Bartlett window of size N
     * Basically a triangle
     * @see [MATLAB reference](https://www.mathworks.com/help/signal/ref/bartlett.html)
     */
    private fun bartlett(N: Int): DoubleArray {
        val w = DoubleArray(N)

        var n = 0
        while (n <= (N - 1) / 2) {
            w[n] = 2.0 * n / (N - 1)
            n++
        }
        while (n < N) {
            w[n] = 2 - 2.0 * n / (N - 1)
            n++
        }

        return w
    }

    /**
     * Hanning window of size N
     * Somewhat like Parzen & Hamming window
     * @see [MATLAB reference](https://www.mathworks.com/help/signal/ref/hann.html)
     */
    private fun hann(N: Int): DoubleArray {
        val w = DoubleArray(N)

        for (n in 0 until N) {
            w[n] = 0.5 * (1 - Math.cos(2.0 * Math.PI * (n / (N - 1.0))))
        }

        return w
    }

    /**
     * Hamming window of size N
     * Somewhat like Hanning & Parzen
     * @see [MATLAB reference](https://www.mathworks.com/help/signal/ref/hamming.html)
     */
    private fun hamming(N: Int): DoubleArray {
        val w = DoubleArray(N)

        for (n in 0 until N) {
            w[n] = 0.54 - 0.46 * Math.cos(2.0 * Math.PI * (n / (N - 1.0)))
        }

        return w
    }

    /**
     * Blackman window of size N
     * @see [MATLAB reference](https://www.mathworks.com/help/signal/ref/blackman.html)
     */
    private fun blackman(N: Int): DoubleArray {
        val w = DoubleArray(N)

        for (n in 0 until N) {
            w[n] = 0.42 - 0.5 * Math.cos(2.0 * Math.PI * n.toDouble() / (N - 1)) + 0.08 * Math.cos(4.0 * Math.PI * n.toDouble() / (N - 1))
        }

        return w
    }
}
