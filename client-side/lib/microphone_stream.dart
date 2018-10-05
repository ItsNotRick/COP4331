import 'package:flutter/services.dart';
import 'dart:async';

class Microphone {
  static const MethodChannel _channel =
  const MethodChannel('microphone');

  static const EventChannel _eventChannel = const EventChannel('microphoneStream');

  static Stream<double> _microphoneStream;

  static Future<double> get reading async {
    final double reading = await _channel.invokeMethod('getMicrophone');
    return reading;
  }
  static Stream<double> get microphoneStream {
    _microphoneStream ??= _eventChannel.receiveBroadcastStream();
    return _microphoneStream;
  }

  static Future<bool> initialize() async {
    bool ready = await _channel.invokeMethod('initializeMicrophone');
  }
}