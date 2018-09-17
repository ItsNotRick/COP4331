// import 'dart:io';
import 'package:flutter/material.dart';


// yay for lambda functions?
void main() => runApp(MyApp());

void test(context) => debugPrint("back");
//                  RaisedButton(
//                    onPressed:(path == 'pop') ? () { Navigator.of(context).pop(); } : () { Navigator.of(context).pushNamed(path); },
//                    padding: const EdgeInsets.all(8.0),
//                    textColor: Colors.white,
//                    color: Colors.blue,
//                    child: Text(testText),
//                  ),

class MyApp extends StatelessWidget {
  // build is the main function for a widget.
  // Like render for react.
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
   double _threshold = 20.0;
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
                'Volume',
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
              RaisedButton(
                onPressed:() {
                  Navigator.pop(
                    context
                  );
                },
                padding: const EdgeInsets.all(8.0),
                textColor: Colors.white,
                color: Colors.blue,
                child: Text('Return'),
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
      //appBar: AppBar(
      //title: Text("Settings"),
      //),
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