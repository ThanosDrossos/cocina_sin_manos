// This file contains the platform channel code for the gesture recognition plugin.
import 'dart:async';
import 'package:flutter/services.dart';

class GestureRecognitionChannel {
  static const MethodChannel _channel = MethodChannel('gesture_recognition_channel');

  static final StreamController<String> _gestureStreamController = StreamController.broadcast();

  static Stream<String> get onGestureDetected => _gestureStreamController.stream;

  static void init() {
    _channel.setMethodCallHandler((call) async {
      if (call.method == 'onGestureDetected') {
        String gestureName = call.arguments;
        _gestureStreamController.add(gestureName);
      }
    });
  }

  static Future<void> startGestureRecognition() async {
    await _channel.invokeMethod('startGestureRecognition');
  }

  static Future<void> stopGestureRecognition() async {
    await _channel.invokeMethod('stopGestureRecognition');
  }
}
