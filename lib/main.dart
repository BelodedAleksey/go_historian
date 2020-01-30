import 'dart:async';
import 'dart:ffi';

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'История',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  static const chan_test = MethodChannel('test');
  static const event_test = EventChannel('event');
  StreamSubscription subscription;
  AnimationController _animProgressCtrl;
  Animation<double> animation;
  var str;
  TextEditingController ctrl;
  TextEditingController _ctrlServer;
  TextEditingController _ctrlInterval;

  List<TextEditingController> _ctrlTags;
  List<TextEditingController> _ctrlFirstTimes;
  List<TextEditingController> _ctrlLastTimes;

  @override
  void initState() {
    subscription = event_test.receiveBroadcastStream().listen(onData);

    _animProgressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    animation = Tween(begin: 0.0, end: 1.0).animate(_animProgressCtrl)
      ..addListener(() {
        setState(() {});
      });

    ctrl = TextEditingController();
    _ctrlServer = TextEditingController();
    _ctrlInterval = TextEditingController();

    _ctrlTags =
        List<TextEditingController>.generate(1, (i) => TextEditingController());
    _ctrlFirstTimes =
        List<TextEditingController>.generate(1, (i) => TextEditingController());
    _ctrlLastTimes =
        List<TextEditingController>.generate(1, (i) => TextEditingController());
    super.initState();
  }

  void onData(dynamic percent) {
    print("In dart: " + percent);
    _animProgressCtrl.animateTo(percent / 100);
    print("Dart event!");
  }

  @override
  void dispose() {
    subscription.cancel();

    _animProgressCtrl.dispose();
    ctrl.dispose();
    _ctrlServer.dispose();
    _ctrlInterval.dispose();

    _ctrlTags.forEach((_ctrl) {
      _ctrl.dispose();
    });
    _ctrlFirstTimes.forEach((_ctrl) {
      _ctrl.dispose();
    });
    _ctrlLastTimes.forEach((_ctrl) {
      _ctrl.dispose();
    });

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Выборка'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Expanded(
              child: Container(
                color: Colors.brown,
                child: Row(children: [
                  Text(
                    "Сервер: ",
                    style: TextStyle(fontSize: 70.0),
                  ),
                  Container(
                    width: 300,
                    child: TextField(
                      controller: _ctrlServer,
                    ),
                  ),
                ]),
              ),
            ),
            Expanded(
              flex: 5,
              child: Row(
                children: <Widget>[
                  Expanded(
                    child: Container(
                      color: Colors.amberAccent,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 300,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _ctrlTags.length,
                              itemBuilder: (ctx, i) {
                                return Container(
                                  width: 400,
                                  child: TextField(
                                    controller: _ctrlTags[i],
                                  ),
                                );
                              },
                            ),
                          ),
                          MaterialButton(
                            color: Colors.green,
                            child: Text("Добавить тэг"),
                            onPressed: () {
                              TextEditingController _ctrl =
                                  TextEditingController();
                              _ctrlTags.add(_ctrl);
                              setState(() {});
                            },
                          )
                        ],
                      ),
                    ),
                  ),
                  Expanded(
                    child: Container(
                      color: Colors.blue,
                      child: Column(
                        children: <Widget>[
                          SizedBox(
                            height: 400,
                            child: ListView.builder(
                              shrinkWrap: true,
                              itemCount: _ctrlFirstTimes.length,
                              itemBuilder: (ctx, i) {
                                return Row(
                                  children: <Widget>[
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      width: 200,
                                      child: TextField(
                                        controller: _ctrlFirstTimes[i],
                                      ),
                                    ),
                                    Text(" : "),
                                    Container(
                                      padding: EdgeInsets.all(5),
                                      width: 200,
                                      child: TextField(
                                        controller: _ctrlLastTimes[i],
                                      ),
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                          MaterialButton(
                            color: Colors.green,
                            child: Text("Добавить время"),
                            onPressed: () {
                              TextEditingController _ctrlFirst =
                                  TextEditingController();
                              TextEditingController _ctrlLast =
                                  TextEditingController();
                              _ctrlFirstTimes.add(_ctrlFirst);
                              _ctrlLastTimes.add(_ctrlLast);
                              setState(() {});
                            },
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
            Expanded(
              child: Container(
                color: Colors.cyanAccent,
                child: Row(
                  children: <Widget>[
                    Text(
                      "Интервал: ",
                      style: TextStyle(fontSize: 70.0),
                    ),
                    Container(
                      width: 300,
                      child: TextField(
                        controller: _ctrlInterval,
                      ),
                    ),
                    SizedBox(
                      height: 50,
                      width: 500,
                      child: LinearProgressIndicator(
                        backgroundColor: Colors.yellowAccent,
                        valueColor:
                            AlwaysStoppedAnimation<Color>(Colors.lightBlue),
                        value: animation.value,
                      ),
                    ),
                  ],
                ),
              ),
            ),
            MaterialButton(
              color: Colors.redAccent,
              child: Text(
                "Сделать запрос",
              ),
              onPressed: () {
                List<String> args = [];
                args.add(_ctrlServer.text);
                args.add(_ctrlInterval.text);
                _ctrlTags.forEach((_ctrl) {
                  args.add(_ctrl.text);
                });
                args.add("\nF\n");
                _ctrlFirstTimes.forEach((_ctrl) {
                  args.add(_ctrl.text);
                });
                args.add("\nL\n");
                _ctrlLastTimes.forEach((_ctrl) {
                  args.add(_ctrl.text);
                });
                chan_test.invokeMethod('onTest', args);
              },
            )
          ],
        ),
      ),
    );
  }
}
