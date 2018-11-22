import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'settings_controller.dart';
import 'audiotap_input.dart';
import 'dart:io';
import 'dart:typed_data';

import 'package:audioplayer/audioplayer.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

typedef void OnError(Exception exception);

const kUrl = "http://www.rxlabz.com/labz/audio2.mp3";
const kUrl2 = "http://www.rxlabz.com/labz/audio.mp3";

enum PlayerState { stopped, playing, paused }

class Beat {
  int millisFromStart;
  int hitBand;
  Beat(this.millisFromStart, this.hitBand);
}

class Song {
  double bpm;
  List<Beat> beats;
  Song(this.bpm, this.beats);
}

class BeatWidgetAnimationContainer {
  Widget widget;
  Beat beat;
  AnimationController controller;
  BeatWidgetAnimationContainer(this.beat, this.controller, Animation animation) {
  widget = SlideTransition(
    position: animation,
      child: AnimatedOpacity(
        opacity: 1.0,
          duration: Duration(milliseconds: 500),
          child: BeatWidget(),
        ),
    );
  }
}

class AnimatedBeats {
  Song song;
  _TestScreenState parent;
  final Function(List<Widget>) updateGameState;
  List<BeatWidgetAnimationContainer> beatWidgets = [];
  Stream<Tap> tapTriggerStream;
  Stream<Beat> bmapStream;

  AnimatedBeats(this.song, this.updateGameState, this.parent) {
    tapTriggerStream = AudiotapInput.tapStream?.where((Tap t) => t.stats.peakDelta >= AudiotapInput.threshold);
    tapTriggerStream.listen(tapHandler);

    bmapStream = genbmapStream(song.beats);
    var beatHandler = (Beat b) {
      var controller = AnimationController(
          duration: const Duration(milliseconds: 2000),
          vsync: parent,
        );
      var animationListener = (status) {
        if (status == AnimationStatus.completed) {
          beatWidgets.removeAt(0).controller?.dispose();
        }
      };
      var animation = Tween(begin: Offset(4.0, 0.0), end: Offset(-3.0, 0.0)).animate(controller)..addStatusListener(animationListener);
      beatWidgets.add(BeatWidgetAnimationContainer(b, controller, animation));
      controller.forward();
      updateGameState(beatWidgets.map<Widget>((container) => container.widget).toList());
    };
    bmapStream.listen(beatHandler);
  }

  void tapHandler(Tap t) {
    for (int idx in Iterable<int>.generate(beatWidgets.length, (i) => i)) {
      if ((beatWidgets[idx].beat.millisFromStart - t.timestamp).abs() < 500) {
        beatWidgets[idx].controller?.reset();
        beatWidgets.removeAt(idx).controller?.dispose();
        parent.score += 30;
        break;
      }
    }
    updateGameState(beatWidgets.map<Widget>((container) => container.widget).toList());
  }

  Stream<Beat> genbmapStream(List<Beat> bmap) async* {
    Stopwatch timer = Stopwatch();
    timer.start();
    AudiotapInput.timer.reset();
    AudiotapInput.timer.start();
    //tapTriggerStream = tapTriggerStream ?? AudiotapInput.tapStream?

    for (Beat b in bmap) {
      await Future.delayed(Duration(milliseconds: b.millisFromStart - timer.elapsedMilliseconds - 1500));
      yield b;
    }
  }
}

class BeatWidget extends StatelessWidget {
  final double opac = 1.0;

  Widget build(BuildContext context) {
    return RaisedButton(
                  //icon: new Icon(Icons.add_circle),
                  child: Text('asdf'),
                  textColor: Colors.white,
                  color: Colors.red,
                  onPressed: () {},
                  //iconSize: 100.0,
                );
  }
}

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with TickerProviderStateMixin {
  AnimationController _controller;
  Animation<Offset> animation;
  Animation<double> disappear;
  Stream<Tap> micInStream;
  Stream<Tap> tapTriggerStream;
  Stream<Beat> bmapStream;
  List<Widget> beatWidgets = <Widget> [];
  AnimatedBeats animatedBeatsContainer;
  int beatWidgetsIndex = 0;
  Song testSong;

  double _threshold = 10.0;
  String streamExists = "not called";
  bool _delet =false;

  AnimationController _controller2;
  int score = 1;
  bool _visible = true;


  ////////////////////
  // Audio Controls //
  ////////////////////

  Duration duration;
  Duration position;

  AudioPlayer audioPlayer;

  String localFilePath;

  PlayerState playerState = PlayerState.stopped;

  get isPlaying => playerState == PlayerState.playing;
  get isPaused => playerState == PlayerState.paused;

  get durationText =>
      duration != null ? duration.toString().split('.').first : '';
  get positionText =>
      position != null ? position.toString().split('.').first : '';

  bool isMuted = false;

  StreamSubscription _positionSubscription;
  StreamSubscription _audioPlayerStateSubscription;

  @override
  void dispose() {
    _positionSubscription.cancel();
    _audioPlayerStateSubscription.cancel();
    audioPlayer.stop();
    super.dispose();
  }

  void initAudioPlayer() {
    audioPlayer = new AudioPlayer();
    _positionSubscription = audioPlayer.onAudioPositionChanged.listen(
            (p) => setState(() => position = p)
    );
    _audioPlayerStateSubscription = audioPlayer.onPlayerStateChanged.listen((s) {
      if (s == AudioPlayerState.PLAYING) {
        setState(() => duration = audioPlayer.duration);
      } else if (s == AudioPlayerState.STOPPED) {
        onComplete();
        setState(() {
          position = duration;
        });
      }
    }, onError: (msg) {
      setState(() {
        playerState = PlayerState.stopped;
        duration = new Duration(seconds: 0);
        position = new Duration(seconds: 0);
      });
    });
  }

  Future play() async {
    await audioPlayer.play(kUrl);
    setState(() {
      playerState = PlayerState.playing;
    });
  }

  Future _playLocal() async {
    if(localFilePath == null)
      print('local file path is null');
    else
    {
      audioPlayer.play(localFilePath, isLocal: true);
      setState(() => playerState = PlayerState.playing);
    }
  }

  Future pause() async {
    await audioPlayer.pause();
    setState(() => playerState = PlayerState.paused);
  }

  Future stop() async {
    await audioPlayer.stop();
    setState(() {
      playerState = PlayerState.stopped;
      position = new Duration();
    });
  }

  Future mute(bool muted) async {
    await audioPlayer.mute(muted);
    setState(() {
      isMuted = muted;
    });
  }

  void onComplete() {
    setState(() => playerState = PlayerState.stopped);
  }

  Future<Uint8List> _loadFileBytes(String url, {OnError onError}) async {
    Uint8List bytes;
    try {
      bytes = await readBytes(url);
    } on ClientException {
      rethrow;
    }
    return bytes;
  }

  Future playSong() async{
    await _loadFile();
    _playLocal();
  }

  Future _loadFile() async{

    final file = new File('${(await getTemporaryDirectory()).path}/music.mp3');
    await file.writeAsBytes((await (DefaultAssetBundle.of(context)).load("songs/TestSong.mp3")).buffer.asUint8List());
    if (await file.exists())
    {
      String value = file.path;
      print('The file does exist at: $value');
      setState(() {
        localFilePath = file.path;
      });
    }
    else
      print('The file didn\'t exist');

  }

  ////////////////
  // The Widget //
  ////////////////

  initState() {
    super.initState();
    
      _controller = AnimationController(
          duration: const Duration(milliseconds: 200), vsync: this);

      _controller2 = AnimationController(
          duration: const Duration(milliseconds: 200), vsync: this);

      _controller.forward();
      _controller2.forward();

      List<Beat> bmap = List<Beat>.generate(94, (i) => Beat(3000 + 438*i /* - (i%2)*250*/, 500));
      testSong = Song(120.0, bmap);
      
      animatedBeatsContainer = AnimatedBeats(testSong, (List<Widget> wL) {setState(() => beatWidgets = wL);}, this);

      initAudioInputController().then((success) => streamExists = (success) ? "succ" : "fail");

      initAudioPlayer();
      playSong();

    
    _controller.forward();
  }

  _TestScreenState() {
    

  }

  Future<bool> initAudioInputController() async {
    micInStream = AudiotapInput.initialize(await SettingsController.getThreshold());
    tapTriggerStream = AudiotapInput.tapStream?.where((Tap t) => t.stats.peakDelta >= AudiotapInput.threshold);
    var tapHandler = (Tap t) =>
      setState(() {
        //_controller?.reset();
        //_controller?.forward();
      });
    tapTriggerStream?.listen(tapHandler);
    return tapTriggerStream != null;
  }

  @override
  Widget build(BuildContext context) {
    final title = 'test';

    return MaterialApp(
        title: title,
        home: Scaffold(
            appBar: AppBar(
              title: Text("$streamExists  ${AudiotapInput.threshold}   ${AudiotapInput.timer.elapsedMilliseconds}"),
            ),

            bottomSheet:
            Text("Score: $score",
              textScaleFactor: 3.0,
              textAlign: TextAlign.center,
            ),

            body: new Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: <Widget> [
                    Text("V <- tap when the middle reaches here!"),
                    Center(child: Row(children: beatWidgets)),//animationStream()),
                    Center(child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[

                //should music initialization go here?
                ScaleTransition(
                    scale: CurvedAnimation(
                        parent: _controller,
                        curve: Interval(0.5, 1.0, curve: Curves.easeIn)),
                    child: AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 200),
                      child: IconButton(
                          icon: new Icon(Icons.trip_origin),
                          color: Colors.red,
                          iconSize: 150.0,
                          onPressed: () {
                            setState(() {
                              //_visible = !_visible;
                              score++;
                              _controller.reset();
                              _controller.forward();
                            });
                          }),
                    )),
                ScaleTransition(
                    scale: CurvedAnimation(
                        parent: _controller2,
                        curve: Interval(0.5, 1.0, curve: Curves.linear)),
                    child: AnimatedOpacity(
                      opacity: _visible ? 1.0 : 0.0,
                      duration: Duration(milliseconds: 5000),
                      child: IconButton(
                          icon: new Icon(Icons.trip_origin),
                          color: Colors.red,
                          iconSize: 150.0,
                          onPressed: () {
                            setState(() {
                              //_visible = !_visible;
                              score++;
                              _controller2.reset();
                              _controller2.forward();
                            });
                          }),
                    ))
              ],
            ))]))));
  }
}
