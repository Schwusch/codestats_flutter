package se.bocker.codestatsflutter

/**
 * @author Joren Six
 * An implementation of the YIN pitch tracking algorithm.
 * See [the YIN paper.](http://recherche.ircam.fr/equipes/pcm/cheveign/ps/2002_JASA_YIN_proof.pdf)
 *
 * Implementation originally based on [aubio](http://aubio.org)
 *
 *
 * Updated by Emlyn O'Regan to work in the PitchDetect sample project for Android.
 * I removed all the realtime features (which are tied in with javax libraries, not good for Dalvik), and
 * modified Yin to be called with a byte buffer to be analyzed using the getPitch() method. So
 * just create yourself a Yin, then call getPitch(bytes) when you're ready.
 *
 * Also converted it to use an array of Shorts instead of Floats.
 *
 * Original implementation is here: http://tarsos.0110.be/artikels/lees/YIN_Pitch_Tracker_in_JAVA
 */
object Yin
{
    private const val sampleRate = RATE_HZ
    /**
     * The YIN threshold value (see paper)
     */
    private const val threshold = 0.15

    /**
     * Implements step 4 of the YIN paper
     */
    private fun absoluteThreshold(yinBuffer: FloatArray): Int {
        //Uses another loop construct
        //than the AUBIO implementation
        var tau = 1
        while (tau < yinBuffer.size) {
            if (yinBuffer[tau] < threshold) {
                while (tau + 1 < yinBuffer.size && yinBuffer[tau + 1] < yinBuffer[tau])
                    tau++
                return tau
            }
            tau++
        }
        //no pitch found
        return -1
    }

    /**
     * Implements step 5 of the YIN paper. It refines the estimated tau value
     * using parabolic interpolation. This is needed to detect higher
     * frequencies more precisely.
     *
     * @param tauEstimate
     * the estimated tau value.
     * @return a better, more precise tau value.
     */
    private fun parabolicInterpolation(tauEstimate: Int, yinBuffer: FloatArray): Float {
        val s0: Float
        val s1: Float
        val s2: Float
        val x0 = if (tauEstimate < 1) tauEstimate else tauEstimate - 1
        val x2 = if (tauEstimate + 1 < yinBuffer.size) tauEstimate + 1 else tauEstimate
        if (x0 == tauEstimate)
            return (if (yinBuffer[tauEstimate] <= yinBuffer[x2]) tauEstimate else x2).toFloat()
        if (x2 == tauEstimate)
            return (if (yinBuffer[tauEstimate] <= yinBuffer[x0]) tauEstimate else x0).toFloat()
        s0 = yinBuffer[x0]
        s1 = yinBuffer[tauEstimate]
        s2 = yinBuffer[x2]
        //fixed AUBIO implementation, thanks to Karl Helgason:
        //(2.0f * s1 - s2 - s0) was incorrectly multiplied with -1
        return tauEstimate + 0.5f * (s2 - s0) / (2.0f * s1 - s2 - s0)
    }

    /**
     * The main flow of the YIN algorithm. Returns a pitch value in Hz or -1 if
     * no pitch is detected using the current values of the input buffer.
     *
     * @return a pitch value in Hz or -1 if no pitch is detected.
     */
    fun getPitch(aInputBuffer: FloatArray): Float {
        val yinBuffer = FloatArray(aInputBuffer.size / 2)

        var tauEstimate = -1
        var pitchInHertz = -1f

        /*
         * Implements the difference function as described
         * in step 2 of the YIN paper
         */
        var j: Int
        var tau: Int = 0
        var delta: Float
        while (tau < yinBuffer.size) {
            yinBuffer[tau] = 0f
            tau++
        }
        tau = 1
        while (tau < yinBuffer.size) {
            j = 0
            while (j < yinBuffer.size) {
                delta = aInputBuffer[j].toFloat() - aInputBuffer[j + tau].toFloat()
                yinBuffer[tau] += delta * delta
                j++
            }
            tau++
        }

        /*
         * The cumulative mean normalized difference function
         * as described in step 3 of the YIN paper
         *
         * yinBuffer[0] == yinBuffer[1] = 1
         *
         *
         */
        yinBuffer[0] = 1f
        //Very small optimization in comparison with AUBIO
        //start the running sum with the correct value:
        //the first value of the yinBuffer
        var runningSum = yinBuffer[1]
        //yinBuffer[1] is always 1
        yinBuffer[1] = 1f
        //now start at tau = 2
        tau = 2
        while (tau < yinBuffer.size) {
            runningSum += yinBuffer[tau]
            yinBuffer[tau] *= tau / runningSum
            tau++
        }

        //step 4
        tauEstimate = absoluteThreshold(yinBuffer)

        //step 5
        if (tauEstimate != -1) {
            val betterTau = parabolicInterpolation(tauEstimate, yinBuffer)

            //step 6
            //TODO Implement optimization for the YIN algorithm.
            //0.77% => 0.5% error rate,
            //using the data of the YIN paper
            //bestLocalEstimate()

            //conversion to Hz
            pitchInHertz = sampleRate / betterTau
        }

        return pitchInHertz
    }
}