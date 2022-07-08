import 'package:flutter/material.dart';
import 'palette.dart';
import 'info.dart';
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
        // Named routes.
        '/home': (context) => pages[0],
      },
    );
  }
}
