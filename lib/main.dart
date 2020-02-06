import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:go_historian/screen_model.dart';
import 'package:provider/provider.dart';
import 'package:go_historian/widgets.dart';
import 'package:go_historian/main_model.dart';

ScreenModel screenModel = ScreenModel();

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    //синглтон с размерами экрана
    screenModel.width = MediaQuery.of(context).size.width;
    screenModel.height = MediaQuery.of(context).size.height;
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'История',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: MyHomePage(),
      routes: {
        '/init': (context) => MyApp(),
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage>
    with SingleTickerProviderStateMixin {
  static const chan_event = EventChannel('event');

  StreamSubscription subscription;
  AnimationController _animProgressCtrl;
  Animation<double> animation;

  @override
  void initState() {
    subscription = chan_event.receiveBroadcastStream().listen(onProgress);

    _animProgressCtrl = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 1000));
    animation = Tween(begin: 0.0, end: 1.0).animate(_animProgressCtrl)
      ..addListener(() {
        setState(() {});
      });

    super.initState();
  }

  void onProgress(dynamic percent) {
    _animProgressCtrl.animateTo(percent);
  }

  @override
  void dispose() {
    subscription.cancel();
    _animProgressCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider<MainModel>(
      create: (context) => MainModel(),
      child: Scaffold(
        appBar: AppBar(
          title: Text('Выборка'),
        ),
        body: Center(
          child: Column(
            children: <Widget>[
              serverExpanded(context),
              Expanded(
                flex: 5,
                child: Row(
                  children: <Widget>[
                    tagsExpanded(context),
                    timesExpanded(context),
                  ],
                ),
              ),
              intervalExpanded(context, animation),
              fetchBtn(context),
            ],
          ),
        ),
      ));
}
