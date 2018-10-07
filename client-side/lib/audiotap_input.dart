import 'package:mic_audio/mic_audio.dart';
import 'dart:typed_data';
import 'dart:async';
import 'package:tuple/tuple.dart';
import 'package:flutter/services.dart';


class AudiotapInput {
  static Stopwatch timer = Stopwatch();
  static bool initialized = false;
  static bool _streaming = false;
  static double threshold = 5.0;

  static Stream<int> audiotapStream() async* {
  Uint8List curr;
  double sum = 0.0;
  double avg = 0.0;
  double prev = 127.5;
  double maxSlope = 0.0;
  _streaming = true;
  timer.reset();
  timer.start();

  while (_streaming && audioStream != null) {
    if (! await audioStream.isEmpty) {
      curr = await audioStream.last;
      sum = 0.0;
      for (var audio in curr) {
        if (audio != -1) sum += audio;
          maxSlope = (audio - prev) > maxSlope ? audio - prev : maxSlope;
          prev = audio + .0;
        }
        avg = sum / curr.length;
        prev = avg;
        if (maxSlope > threshold) yield timer.elapsedMilliseconds;
      }
    }
  }

  static initialize (double thresh) async {
    threshold = thresh;
    MicAudio.initialize().then((init) {
      initialized = init;
      if (initialized == true) {
        MicAudio.micAudioStream.listen(onData);
      }
    });
  }
}