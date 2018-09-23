// import 'dart:io';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

// yay for lambda functions?
void main() => runApp(MyApp());

void test(context) => debugPrint("back");
     

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context){
      return MaterialApp(
        title: 'Flutter Demo',
        initialRoute: '/',
        routes: {
          '/' : (context) => MainMenu(),
          '/options' : (context) => OptionsMenu(),
          '/game' : (context) => GameScreen(),
        },
      );
  }

}

class MainMenu extends StatelessWidget{
  @override
  Widget build(BuildContext context){

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
        )
      )
    );

    return Scaffold(
      body: ListView(
        children: <Widget> [
          titleSection,
          RaisedButton(
            onPressed:() {
              Navigator.pushNamed(
                context,
                '/game'
              );
            },
            padding: const EdgeInsets.all(8.0),
            textColor: Colors.white,
            color: Colors.blue,
            child: Text('Game'),
          ),
          RaisedButton(
            onPressed:() {
              Navigator.pushNamed(
                context,
                '/options'
              );
            },
            padding: const EdgeInsets.all(8.0),
            textColor: Colors.white,
            color: Colors.blue,
            child: Text('Options'),
          ),
        ],
      ),
    );
  }
}
class OptionsMenu extends StatefulWidget{
  Options createState() => Options();
}

class Options extends State<OptionsMenu>{
  double _threshold = 50.0;
  double _volume = 50.0;

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

  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget> [
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
                },
              ),
              Text(
                'Volume: ${_volume.round()}'
              ),
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
                onPressed:() async {
                  final prefs = await SharedPreferences.getInstance();
                  prefs.setDouble('threshold', _threshold);
                  prefs.setDouble('volume', _volume);
                  Navigator.pop(
                    context
                  );
                },
                padding: const EdgeInsets.all(8.0),
                textColor: Colors.white,
                color: Colors.blue,
                child: Text('Save and Return'),
              ),
            ]
          ),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget> [
            Text(
              'game screen :^)'
            ),
          ]),
      ),
    );
  }
}
