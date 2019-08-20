package se.bocker.codestatsflutter

import com.paramsen.noise.Noise
import kotlin.math.*

/**
 * @param inputAudioFrameSize the input audio frame size
 * @param samplingFrequency the sampling frequency
 */
class Chromagram(
        private val referenceFrequency: Double = 130.81278265,
        private val bufferSize: Int = 8192,
        private val numHarmonics: Int = 2,
        private val numOctaves: Int = 2,
        private val numBinsToSearch: Int = 2,
        private val inputAudioFrameSize: Int,
        private val samplingFrequency: Int) {

    // calculate note frequencies
    private val noteFrequencies = List(12) { referenceFrequency * 2.0.pow(it/12) }
    private val noise = Noise.real().optimized().init(4096, true)
    private val window: List<Float> = List(bufferSize) { (0.54 - 0.46 * cos(2 * PI * (it / bufferSize))).toFloat()}
    private var magnitudeSpectrum = List(bufferSize/2 + 1) { 0f }
    private var downsampledInputAudioFrame = MutableList(inputAudioFrameSize / 4) { 0f }
    private val buffer = MutableList(bufferSize) { 0f }

    fun processAudioFrame(inputAudioFrame: FloatArray): FloatArray {
        downSampleFrame(inputAudioFrame)
        val downsampledAudioFrameSize = downsampledInputAudioFrame.size
        // move samples back
        for (i in 0 until (bufferSize - downsampledAudioFrameSize)) {
            buffer[i] = buffer[i + downsampledAudioFrameSize]
        }

        // add new samples to buffer
        for ((n, i) in ((bufferSize - downsampledAudioFrameSize) until bufferSize).withIndex()) {
            buffer[i] = downsampledInputAudioFrame[n]
        }



        return calculateChromagram()
    }

    private fun calculateChromagram(): FloatArray {
        calculateMagnitudeSpectrum()

        val chromagram = FloatArray(12)

        val divisorRatio = samplingFrequency / 4.0 / bufferSize
        for (n in 0 until 12) {
            var chromaSum = 0.0

            for (octave in 1..numOctaves) {
                var noteSum = 0.0

                for (harmonic in 1..numHarmonics) {
                    val centerBin = round(noteFrequencies[n] * octave * harmonic / divisorRatio)
                    val minBin = centerBin - numBinsToSearch * harmonic
                    val maxBin = centerBin + numBinsToSearch * harmonic

                    var maxVal = 0f

                    for (k in minBin.roundToInt() until maxBin.roundToInt()) {
                        maxVal = max(magnitudeSpectrum[k], maxVal)
                    }

                    noteSum += maxVal / harmonic
                }

                chromaSum += noteSum
            }

            chromagram[n] = chromaSum.toFloat()
        }
        return chromagram
    }

    private fun calculateMagnitudeSpectrum() {
        val fftIn = FloatArray(bufferSize)
        for (i in 0 until bufferSize) {
            fftIn[i] = buffer[i] * window[i]
        }
        magnitudeSpectrum = noise.fft(fftIn).asSequence().zipWithNext().map { sqrt(sqrt(it.first.pow(2) + it.second.pow(2))) }.toList()

    }

    private val b0 = 0.2929
    private val b1 = 0.5858
    private val b2 = 0.2929
    private val a1 = -0.0000
    private val a2 = 0.1716

    private fun downSampleFrame(inputAudioFrame: FloatArray) {
        val filteredFrame = MutableList(inputAudioFrameSize) { 0f }
        var x1 = 0f
        var x2 = 0f
        var y1 = 0f
        var y2 = 0f

        inputAudioFrame.forEachIndexed { i, sample ->
            filteredFrame[i] = (sample * b0 + x1 * b1 + x2 * b2 - y1 * a1 - y2 * a2).toFloat()
            x2 = x1
            x1 = sample
            y2 = y1
            y1 = filteredFrame[i]
        }

        for (i in 0 until (inputAudioFrameSize / 4)) {
            downsampledInputAudioFrame[i] = filteredFrame[i * 4]
        }
    }
}