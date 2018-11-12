import 'package:mic_audio/mic_audio.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:flutter/services.dart';

class TapStats {
  final double avgVol;
  final double peakVol;
  final double peakDelta;
  const TapStats(this.avgVol, this.peakVol, this.peakDelta);
}

class Tap {
  final TapStats stats;
  final int timestamp;
  const Tap(this.stats, this.timestamp);
}

class AudiotapInput {
  static Stopwatch timer = Stopwatch();
  static Stream<Tap> _tapStream;
  static Stream<Uint8List> rawAudioStream;
  static bool initialized = false;
  static bool _streaming = false;
  static double threshold = 5.0;

  static Stream<Tap> initialize (double thresh) {
    threshold = thresh;
    //timer.reset();
    //timer.start();

    //while (initialized != true)
    //{
      MicAudio.initialize().then((init) {
        initialized = init;
        if (initialized == true) {
          rawAudioStream = MicAudio.micAudioStream;
          _tapStream = mapTimeStamps(rawAudioStream);
          //MicAudio.micAudioStream.listen(onData);
        }
      });
    //}
    return _tapStream;
  }

  static TapStats _genTapStats(Uint8List xs) {
    var sum = 0.0;
    var prev = 127.5;
    var max = 0.0;
    var jump = 0.0;

    for (int sample in xs) {
      if (sample != -1) sum += sample;
      if (sample > max) max = sample + .0;
      jump = (sample - prev) > jump ? sample - prev : jump;
      prev = sample + 0.0;
    }
    return TapStats(sum / xs.last, max, jump);
  }

  static Stream<Tap> get tapStream {
    _tapStream ??= initialize(threshold);
    return _tapStream;
  }

  static Stream<Tap> mapTimeStamps (Stream<Uint8List> micInput) {
    return micInput.map(
      (Uint8List xs) => Tap(_genTapStats(xs), timer.elapsedMilliseconds)
    );
  }
}