// import 'dart:io';
import 'package:flutter/material.dart';


// yay for lambda functions?
void main() => runApp(MyApp());

void test(context) => debugPrint("back");
Row buildButtonRow(String testText, String path, BuildContext context){
        
        // // TODO: figure out what do do for exception handling
        // if(!(path.startsWith('/') || path.compareTo('pop') == 0)){
        //   debugPrintStack();
        //   debugPrint("error: buildButtonRow was not passed a valid pathname");
        //   exit(0);
        // }

        return Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  RaisedButton(
                    onPressed:(path == 'pop') ? () { Navigator.of(context).pop(); } : () { Navigator.of(context).pushNamed(path); },
                    padding: const EdgeInsets.all(8.0),
                    textColor: Colors.white,
                    color: Colors.blue,
                    child: Text(testText),
                  ),
                ]
              ),
            ),
          ],
        );
      }


class MyApp extends StatelessWidget {
  // build is the main function for a widget.
  // Like render for react.
  @override
  Widget build(BuildContext context){
      return MaterialApp(
        routes: {
          // '/': (context) => MyApp(),
          '/second' : (context) => OptionScreen(),
        },
        title: 'Flutter Demo',
        home: MainMenu(),
      );
  }

}

class MainMenu extends StatelessWidget{
  @override
  Widget build(BuildContext context){

    Widget titleSection = Container(
        padding: const EdgeInsets.all(32.0),
        child: Row(
          children:[
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    child: Text(
                      'Welcome to our rhythm game!',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 20.0,
                      ),
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
          ],
        ),
      );

    return Scaffold(
      body: ListView(
        children: <Widget>[
          titleSection,
          buildButtonRow('options', '/second', context),
        ],
      ),
    );
  }
}
class OptionScreen extends StatefulWidget{
  Options createState() => Options();
}

class Options extends State<OptionScreen>{
   double _value = 20.0;
  @override
  Widget build(BuildContext context){
    return MaterialApp(
      title: 'Flutter Demo',
      home: Scaffold(
        body: ListView(
          children: <Widget>[
            buildButtonRow('hello', '/', context),
            Text('Volume',textAlign: TextAlign.center,),
            Slider(
              value: _value,
              min: 0.0,
              max: 100.0,
              onChanged: (double value) {
                setState(() => _value = value);
              },
            ),
          ]
        ),
      ),
    );
  }
}