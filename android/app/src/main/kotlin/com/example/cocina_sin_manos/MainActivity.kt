package com.example.cocina_sin_manos

import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import com.google.mediapipe.tasks.vision.gesturerecognizer.GestureRecognizer

class MainActivity : FlutterActivity(), GestureRecognizerHelper.GestureRecognizerListener {
    private lateinit var gestureRecognizerHelper: GestureRecognizerHelper
    private val CHANNEL = "gesture_recognition_channel"

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Initialize GestureRecognizerHelper
        gestureRecognizerHelper = GestureRecognizerHelper(
            context = this,
            gestureRecognizerListener = this
        )

        // Set up MethodChannel
        MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL).setMethodCallHandler { call, result ->
            when (call.method) {
                "startGestureRecognition" -> {
                    gestureRecognizerHelper.startGestureRecognition()
                    result.success("Gesture recognition started")
                }
                "stopGestureRecognition" -> {
                    gestureRecognizerHelper.stopGestureRecognition()
                    result.success("Gesture recognition stopped")
                }
                else -> result.notImplemented()
            }
        }
    }

    override fun onResults(resultBundle: GestureRecognizerHelper.ResultBundle) {
        val gestures = resultBundle.results[0].gestures()
        if (gestures.isNotEmpty()) {
            val topGesture = gestures[0][0] // Get the most probable gesture
            val gestureName = topGesture.categoryName
            // Send the gesture name back to Flutter
            runOnUiThread {
                MethodChannel(flutterEngine?.dartExecutor?.binaryMessenger, CHANNEL)
                    .invokeMethod("onGestureDetected", gestureName)
            }
        }
    }

    override fun onError(error: String, errorCode: Int) {
        // Handle errors
        Log.e(TAG, "Error: $error")
    }
}
