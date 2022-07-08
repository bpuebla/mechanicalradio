import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'palette.dart';
import 'web.dart';
import 'dart:io'; // later internet connection check
import 'info.dart';
import 'text_form.dart';
import 'homepage.dart';

const pages = [MyHomePage(title: 'Mechanical Radio'), InfoPage()];
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Mechanical Radio',
      theme: ThemeData(
        fontFamily: 'Roboto',
        scaffoldBackgroundColor: Color.fromARGB(255, 24, 24, 24),
        textTheme: Theme.of(context).textTheme.apply(
              bodyColor: const Color.fromARGB(255, 202, 218, 222),
              //displayColor: const Color.fromARGB(255, 202, 218, 222),
            ),
        primarySwatch: Palette.greenTone,
      ),
      initialRoute: '/home',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/home': (context) => pages[0],
      },
    );
  }
}
