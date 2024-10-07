package com.google.mediapipe.examples.gesturerecognizer

import android.annotation.SuppressLint
import android.content.Context
import android.graphics.Bitmap
import android.graphics.Matrix
import android.os.SystemClock
import android.util.Log
import androidx.camera.core.*
import androidx.camera.lifecycle.ProcessCameraProvider
import androidx.core.content.ContextCompat
import com.google.mediapipe.framework.image.BitmapImageBuilder
import com.google.mediapipe.framework.image.MPImage
import com.google.mediapipe.tasks.core.BaseOptions
import com.google.mediapipe.tasks.core.BaseOptions.Delegate
import com.google.mediapipe.tasks.vision.core.RunningMode
import com.google.mediapipe.tasks.vision.gesturerecognizer.GestureRecognizer
import com.google.mediapipe.tasks.vision.gesturerecognizer.GestureRecognizerResult
import java.util.concurrent.ExecutorService
import java.util.concurrent.Executors

class GestureRecognizerHelper(
    var minHandDetectionConfidence: Float = DEFAULT_HAND_DETECTION_CONFIDENCE,
    var minHandTrackingConfidence: Float = DEFAULT_HAND_TRACKING_CONFIDENCE,
    var minHandPresenceConfidence: Float = DEFAULT_HAND_PRESENCE_CONFIDENCE,
    var currentDelegate: Int = DELEGATE_CPU,
    var runningMode: RunningMode = RunningMode.LIVE_STREAM,
    val context: Context,
    val gestureRecognizerListener: GestureRecognizerListener? = null
) {
    // MediaPipe Gesture Recognizer
    private var gestureRecognizer: GestureRecognizer? = null

    // CameraX variables
    private var cameraProvider: ProcessCameraProvider? = null
    private lateinit var cameraExecutor: ExecutorService
    private var imageAnalyzer: ImageAnalysis? = null

    init {
        setupGestureRecognizer()
    }

    fun clearGestureRecognizer() {
        gestureRecognizer?.close()
        gestureRecognizer = null
    }

    // Initialize the Gesture Recognizer
    private fun setupGestureRecognizer() {
        val baseOptionBuilder = BaseOptions.builder()
            .setModelAssetPath(MP_RECOGNIZER_TASK)

        when (currentDelegate) {
            DELEGATE_CPU -> baseOptionBuilder.setDelegate(Delegate.CPU)
            DELEGATE_GPU -> baseOptionBuilder.setDelegate(Delegate.GPU)
        }

        try {
            val baseOptions = baseOptionBuilder.build()
            val optionsBuilder = GestureRecognizer.GestureRecognizerOptions.builder()
                .setBaseOptions(baseOptions)
                .setMinHandDetectionConfidence(minHandDetectionConfidence)
                .setMinTrackingConfidence(minHandTrackingConfidence)
                .setMinHandPresenceConfidence(minHandPresenceConfidence)
                .setRunningMode(runningMode)

            if (runningMode == RunningMode.LIVE_STREAM) {
                optionsBuilder
                    .setResultListener(this::returnLivestreamResult)
                    .setErrorListener(this::returnLivestreamError)
            }
            val options = optionsBuilder.build()
            gestureRecognizer = GestureRecognizer.createFromOptions(context, options)
        } catch (e: Exception) {
            gestureRecognizerListener?.onError(
                "Gesture recognizer failed to initialize. See error logs for details."
            )
            Log.e(TAG, "MediaPipe Gesture Recognizer failed to load. Error: ${e.message}")
        }
    }

    // Start the camera and set up the analyzer to process each frame
    @SuppressLint("UnsafeOptInUsageError")
    fun startGestureRecognition() {
        cameraExecutor = Executors.newSingleThreadExecutor()
        val cameraProviderFuture = ProcessCameraProvider.getInstance(context)
        cameraProviderFuture.addListener({
            // CameraProvider
            cameraProvider = cameraProviderFuture.get()

            // Preview
            val preview = Preview.Builder().build()

            // Select camera (front-facing)
            val cameraSelector = CameraSelector.DEFAULT_FRONT_CAMERA

            // ImageAnalysis
            imageAnalyzer = ImageAnalysis.Builder()
                .setBackpressureStrategy(ImageAnalysis.STRATEGY_KEEP_ONLY_LATEST)
                .build()
                .also {
                    it.setAnalyzer(cameraExecutor, { imageProxy ->
                        recognizeLiveStream(imageProxy)
                    })
                }

            try {
                // Unbind use cases before rebinding
                cameraProvider?.unbindAll()

                // Bind use cases to camera
                cameraProvider?.bindToLifecycle(
                    context as androidx.lifecycle.LifecycleOwner,
                    cameraSelector,
                    preview,
                    imageAnalyzer
                )
            } catch (exc: Exception) {
                Log.e(TAG, "Use case binding failed", exc)
            }
        }, ContextCompat.getMainExecutor(context))
    }

    // Stop the camera and gesture recognizer
    fun stopGestureRecognition() {
        cameraProvider?.unbindAll()
        cameraExecutor.shutdown()
        gestureRecognizer?.close()
        gestureRecognizer = null
    }

    // Convert ImageProxy to MPImage and feed it to GestureRecognizer
    @SuppressLint("UnsafeOptInUsageError")
    private fun recognizeLiveStream(imageProxy: ImageProxy) {
        val frameTime = SystemClock.uptimeMillis()

        val rotationDegrees = imageProxy.imageInfo.rotationDegrees
        val bitmap = imageProxyToBitmap(imageProxy)

        val rotatedBitmap = rotateBitmap(bitmap, rotationDegrees.toFloat())

        // Convert the bitmap to MPImage
        val mpImage = BitmapImageBuilder(rotatedBitmap).build()

        // Perform gesture recognition
        gestureRecognizer?.recognizeAsync(mpImage, frameTime)

        imageProxy.close()
    }

    // Convert ImageProxy to Bitmap
    private fun imageProxyToBitmap(imageProxy: ImageProxy): Bitmap {
        val yBuffer = imageProxy.planes[0].buffer // Y
        val uBuffer = imageProxy.planes[1].buffer // U
        val vBuffer = imageProxy.planes[2].buffer // V

        val ySize = yBuffer.remaining()
        val uSize = uBuffer.remaining()
        val vSize = vBuffer.remaining()

        val nv21 = ByteArray(ySize + uSize + vSize)

        // U and V are swapped
        yBuffer.get(nv21, 0, ySize)
        vBuffer.get(nv21, ySize, vSize)
        uBuffer.get(nv21, ySize + vSize, uSize)

        val yuvImage = android.graphics.YuvImage(
            nv21,
            android.graphics.ImageFormat.NV21,
            imageProxy.width,
            imageProxy.height,
            null
        )

        val out = java.io.ByteArrayOutputStream()
        yuvImage.compressToJpeg(
            android.graphics.Rect(0, 0, yuvImage.width, yuvImage.height),
            100,
            out
        )
        val imageBytes = out.toByteArray()
        return android.graphics.BitmapFactory.decodeByteArray(imageBytes, 0, imageBytes.size)
    }

    // Rotate and flip the bitmap as needed
    private fun rotateBitmap(bitmap: Bitmap, rotationDegrees: Float): Bitmap {
        val matrix = Matrix()
        matrix.postRotate(rotationDegrees)
        // Mirror the image if using the front camera
        matrix.postScale(-1f, 1f, bitmap.width / 2f, bitmap.height / 2f)
        return Bitmap.createBitmap(bitmap, 0, 0, bitmap.width, bitmap.height, matrix, true)
    }

    // Return the recognition result to the listener
    private fun returnLivestreamResult(
        result: GestureRecognizerResult,
        input: MPImage
    ) {
        val finishTimeMs = SystemClock.uptimeMillis()
        val inferenceTime = finishTimeMs - result.timestampMs()

        gestureRecognizerListener?.onResults(
            ResultBundle(
                listOf(result),
                inferenceTime,
                input.height,
                input.width
            )
        )
    }

    // Handle errors during recognition
    private fun returnLivestreamError(error: RuntimeException) {
        gestureRecognizerListener?.onError(
            error.message ?: "An unknown error has occurred"
        )
    }

    companion object {
        val TAG = "GestureRecognizerHelper"
        private const val MP_RECOGNIZER_TASK = "gesture_recognizer.task"

        const val DELEGATE_CPU = 0
        const val DELEGATE_GPU = 1
        const val DEFAULT_HAND_DETECTION_CONFIDENCE = 0.5F
        const val DEFAULT_HAND_TRACKING_CONFIDENCE = 0.5F
        const val DEFAULT_HAND_PRESENCE_CONFIDENCE = 0.5F
        const val OTHER_ERROR = 0
        const val GPU_ERROR = 1
    }

    data class ResultBundle(
        val results: List<GestureRecognizerResult>,
        val inferenceTime: Long,
        val inputImageHeight: Int,
        val inputImageWidth: Int,
    )

    interface GestureRecognizerListener {
        fun onError(error: String, errorCode: Int = OTHER_ERROR)
        fun onResults(resultBundle: ResultBundle)
    }
}
