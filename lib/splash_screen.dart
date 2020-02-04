import 'dart:async';

import 'package:flutter/material.dart';
import 'package:nima/nima_actor.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    startTimer();
    super.initState();
  }

  @override
  Widget build(BuildContext context) => Container(
        color: Colors.blue,
        child: Stack(
          children: <Widget>[
            NimaActor(
              'assets/animations/Ape.nma',
              animation: 'Idle',
              fit: BoxFit.contain,
            )
          ],
        ),
      );

  startTimer() async {
    return Timer(Duration(seconds: 5),
        () => Navigator.of(context).pushReplacementNamed('/init'));
  }
}
