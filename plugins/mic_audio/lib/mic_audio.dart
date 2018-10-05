import 'dart:async';
import 'dart:typed_data';
import 'package:flutter/services.dart';

class MicAudio {
  static const MethodChannel _channel =
      const MethodChannel('micAudio');

  static const EventChannel _eventChannel =
      const EventChannel('micAudioStream');

  static Future<String> get platformVersion async {
    final String version = await _channel.invokeMethod('getPlatformVersion');
    return version;
  }

  static Stream<Uint8List> _micAudioStream;

  static Future<double> get reading async {
    final double reading = await _channel.invokeMethod('getMicAudio');
    return reading;
  }

  static Stream<Uint8List> get micAudioStream {
    _micAudioStream ??= _eventChannel.receiveBroadcastStream().map<Uint8List>((value) => value);
    return _micAudioStream;
  }

  static Future<bool> initialize() async {
    bool ready = await _channel.invokeMethod('initializeMicAudio');
    return ready;
  }
}
