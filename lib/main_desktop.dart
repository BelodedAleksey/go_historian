import 'package:flutter/foundation.dart'
    show debugDefaultTargetPlatformOverride;
import 'package:flutter/material.dart';
import 'package:go_historian/file_picker_demo.dart';
import 'package:go_historian/splash_screen.dart';
import 'package:go_historian/main.dart';

void main() {
  debugDefaultTargetPlatformOverride = TargetPlatform.fuchsia;

  runApp(MaterialApp(
    debugShowCheckedModeBanner: false,
    home: SplashScreen(),
    routes: {
      '/init': (context) => MyApp(),
      '/test': (context) => FilePickerDemo(),
    },
  ));
}
