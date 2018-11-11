import 'dart:async';
import 'dart:io';
import 'dart:typed_data';


import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'package:audioplayer/audioplayer.dart';
import 'package:http/http.dart';
import 'package:path_provider/path_provider.dart';

typedef void OnError(Exception exception);

const kUrl = "http://www.rxlabz.com/labz/audio2.mp3";
const kUrl2 = "http://www.rxlabz.com/labz/audio.mp3";

enum PlayerState { stopped, playing, paused }

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with TickerProviderStateMixin {
  AnimationController _controller;
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
      await audioPlayer.play(localFilePath, isLocal: true);
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
        return localFilePath = file.path;
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
    {
      _controller = AnimationController(
          duration: const Duration(milliseconds: 200), vsync: this);

      _controller2 = AnimationController(
          duration: const Duration(milliseconds: 200), vsync: this);

      _controller.forward();
      _controller2.forward();

      initAudioPlayer();
      playSong();

    }
  }

  @override
  Widget build(BuildContext context) {
    final title = 'test';
     
    return MaterialApp(
        title: title,
        home: Scaffold(
            appBar: AppBar(
              title: Text(title),
            ),

            bottomSheet: 
            Text("Score: $score",
              textScaleFactor: 3.0,
              textAlign: TextAlign.center,
            ),
            



            body: new Center(
                child: Row(
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
            ))));
  }
}
