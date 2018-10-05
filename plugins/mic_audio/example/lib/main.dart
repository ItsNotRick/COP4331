import 'package:flutter/material.dart';
import 'dart:typed_data';
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:mic_audio/mic_audio.dart';

void main() => runApp(new MyApp());

class MyApp extends StatefulWidget {
  @override
  _MyAppState createState() => new _MyAppState();
}

class _MyAppState extends State<MyApp> {
  String _platformVersion = 'Unknown';
  bool _micInitialized = false;

  @override
  void initState() {
    super.initState();
    initPlatformState();
    initMicAudio();
  }

  Future<void> initMicAudio() async {
    bool succ = true;
    try {
      succ = await MicAudio.initialize();
    } catch (e) {
      succ = false;
    }

    if (!mounted) return;

    setState(() {
      _micInitialized = succ;
    });
  }

  // Platform messages are asynchronous, so we initialize in an async method.
  Future<void> initPlatformState() async {
    String platformVersion;
    // Platform messages may fail, so we use a try/catch PlatformException.
    try {
      platformVersion = await MicAudio.platformVersion;
    } on PlatformException {
      platformVersion = 'Failed to get platform version.';
    }

    // If the widget was removed from the tree while the asynchronous platform
    // message was in flight, we want to discard the reply rather than calling
    // setState to update our non-existent appearance.
    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      home: new Scaffold(
        appBar: new AppBar(
          title: const Text('Plugin example app'),
        ),
        body: new Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
              Text('Running on: $_platformVersion\n'),
              Text('Intialized? $_micInitialized\n'),
              StreamBuilder(
                stream: MicAudio.micAudioStream,
                builder: (BuildContext context, AsyncSnapshot<Uint8List> snapshot) {
                  if (snapshot.hasData) return Text('${snapshot.data}\n');
                  return Text('NO DATA\n');
                }
              ),
            ]
          ),
        ),
      ),
    );
  }
}
