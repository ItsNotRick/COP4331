import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';

class TestScreen extends StatefulWidget {
  @override
  _TestScreenState createState() => _TestScreenState();
}

class _TestScreenState extends State<TestScreen> with TickerProviderStateMixin {
  AnimationController _controller;
  AnimationController _controller2;

  bool _visible = true;
  initState() {
    super.initState();
    {
      _controller = AnimationController(
          duration: const Duration(milliseconds: 200), vsync: this);

      _controller2 = AnimationController(
          duration: const Duration(milliseconds: 200), vsync: this);

      _controller.forward();
      _controller2.forward();
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
            bottomNavigationBar: FloatingActionButton(
                child: Text("push"),
                onPressed: () {
                  setState(() {});
                }),
            body: new Center(
                child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
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
                          iconSize: 200.0,
                          onPressed: () {
                            setState(() {
                              //_visible = !_visible;
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
                          iconSize: 200.0,
                          onPressed: () {
                            setState(() {
                              //_visible = !_visible;
                              _controller2.reset();
                              _controller2.forward();
                            });
                          }),
                    ))
              ],
            ))));
  }
}
