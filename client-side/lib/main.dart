// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mic_audio/mic_audio.dart';
import 'package:flutter/services.dart';
import 'package:flutter/animation.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:typed_data';
import './animation.dart';
import './audiotap_input.dart';

// yay for lambda functions?
void main() => runApp(MyApp());

void test(context) => debugPrint("back");

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      initialRoute: '/',
      routes: {
        '/': (context) => MainMenu(),
        '/options': (context) => OptionsMenu(),
        '/game': (context) => GameScreen(),
        '/test': (context) => TestScreen(),
      },
    );
  }
}

class MainMenu extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    Widget titleSection = Container(
        padding: const EdgeInsets.all(32.0),
        child: Center(
            child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'Welcome to our rhythm game!',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 20.0,
              ),
            ),
            Text(
              'By Patrick, Matt, Yash, and Chris',
              style: TextStyle(
                color: Colors.grey[500],
              ),
            ),
          ],
        )));

    return Scaffold(
      body: ListView(
        children: <Widget>[
          titleSection,
          RaisedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/game');
            },
            padding: const EdgeInsets.all(8.0),
            textColor: Colors.white,
            color: Colors.blue,
            child: Text('Game'),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/options');
            },
            padding: const EdgeInsets.all(8.0),
            textColor: Colors.white,
            color: Colors.blue,
            child: Text('Options'),
          ),
          RaisedButton(
            onPressed: () {
              Navigator.pushNamed(context, '/test');
            },
            padding: const EdgeInsets.all(8.0),
            textColor: Colors.white,
            color: Colors.blue,
            child: Text('test'),
          ),
        ],
      ),
    );
  }
}

class OptionsMenu extends StatefulWidget {
  Options createState() => Options();
}

class Options extends State<OptionsMenu> {
  double _threshold = 50.0;
  double _volume = 50.0;
  Stream<Tap> micInStream;
  String _platformVersion = "Unknown";
  var _backgroundColor = Colors.white;

  @override
  void initState() {
    super.initState();
    initPlatformState();
  }

  Options() {
    setThreshold();
    setVolume();
  }

  setThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _threshold = prefs.getDouble('threshold') ?? 50.0;
    });
  }

  setVolume() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _volume = prefs.getDouble('volume') ?? 50.0;
    });
  }

  Future<void> initPlatformState() async {
    String platformVersion = "asdf";
    try {
      micInStream = AudiotapInput.initialize(_threshold);
    } catch (e) {
      platformVersion = "Platform error: $e";
    }

    if (!mounted) return;

    setState(() {
      _platformVersion = platformVersion;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        backgroundColor: _backgroundColor,
        body: Center(
          child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                StreamBuilder(
                    stream: AudiotapInput.tapStream?.where((Tap t) => t.stats.peakDelta >= _threshold),//AudiotapInput.mapTimeStamps(AudiotapInput.rawAudioStream),
                    builder: (BuildContext context,
                      AsyncSnapshot<Tap> snapshot) {
                      if (snapshot.hasData) {
                        return Text('Time: ${snapshot.data.timestamp} Loudness: ${snapshot.data.stats.peakDelta}');
                      }
                      return Text('');
                    }),
                StreamBuilder(
                  stream: AudiotapInput.rawAudioStream,
                  builder: (BuildContext context,
                    AsyncSnapshot<Uint8List> snapshot) {
                    if (snapshot.hasData) {
                      var sum = 0.0;
                      var prev = 127.5;
                      var jump = 0.0;
                      for (var audio in snapshot.data) {
                        if (audio != -1) sum += audio;
                        jump = (audio - prev) > jump ? audio - prev : jump;
                        prev = audio + .0;
                      }
                      var avg = sum / snapshot.data.length;
                      var sAvg = avg.toStringAsFixed(3);
                      if (jump > _threshold)
                        return Text(
                          '*****************************\nJUMP: ${jump} AUDIO: $sAvg');
                      return Text('JUMP: ${jump} AUDIO: $sAvg');
                    }
                    return Text('NO DATA');
                  }),
                Text(
                  '$_platformVersion',
                ),
                Text(
                  'Threshold: ${_threshold.round()}',
                ),
                Slider(
                  value: _threshold,
                  min: 0.0,
                  max: 100.0,
                  onChanged: (double value) {
                    setState(() {
                      _threshold = value;
                    });
                    AudiotapInput.threshold = value;
                  },
                ),
                Text('Volume: ${_volume.round()}'),
                Slider(
                  value: _volume,
                  min: 0.0,
                  max: 100.0,
                  onChanged: (double value) {
                    setState(() {
                      _volume = value;
                    });
                  },
                ),
                RaisedButton(
                  onPressed: () async {
                    final prefs = await SharedPreferences.getInstance();
                    prefs.setDouble('threshold', _threshold);
                    prefs.setDouble('volume', _volume);
                    Navigator.pop(context);
                  },
                  padding: const EdgeInsets.all(8.0),
                  textColor: Colors.white,
                  color: Colors.blue,
                  child: Text('Save and Return'),
                ),
              ]),
        ),
      ),
    );
  }
}

class GameScreen extends StatefulWidget {
  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  final items = List<String>.generate(20, (i) => "BeatMap $i");

  @override
  Widget build(BuildContext context) {
    Widget listView = ListView.builder(
      itemCount: items.length,
      itemBuilder: (context, index) {
        return InkWell(
            onTap: () => debugPrint("woo"),
            child: Container(
                padding: EdgeInsets.all(20.0), child: Text(items[index])));
      },
    );

    final title = 'Long List';

    return MaterialApp(
      title: title,
      home: Scaffold(
        appBar: AppBar(
          title: Text(title),
        ),
        body: listView,
      ),
    );
  }
}
