import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'palette.dart';

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
          primarySwatch: Palette.greenTone,
        ),
        home: const Center(
          child: MyHomePage(title: 'Mechanical Radio'),
        )
        //page2,
        //page3,
        );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool _isPlaying = false;
  bool _audioPlayed = false;
  AudioPlayer player = AudioPlayer();
  String audioasset = "assets/audio/sound1.mp3";
  late Uint8List audiobytes;

  @override
  void initState() {
    Future.delayed(Duration.zero, () async {
      ByteData bytes =
          await rootBundle.load(audioasset); //load audio from assets
      audiobytes =
          bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
      setState(() {});
    });
    super.initState();
  }

  void _togglePlaying() async {
    if (_isPlaying && _audioPlayed) {
      int result = await player.pause();
      if (result == 1) {
        setState(() {
          _isPlaying = false;
        });
      }
    } else if (!_isPlaying && !_audioPlayed) {
      int result = await player.playBytes(audiobytes);
      if (result == 1) {
        setState(() {
          _isPlaying = true;
          _audioPlayed = true;
        });
      }
    } else {
      int result = await player.resume();
      if (result == 1) {
        setState(() {
          _isPlaying = true;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
                onPressed: _togglePlaying,
                child: (_isPlaying
                    ? const Icon(Icons.pause)
                    : const Icon(Icons.play_arrow))),
            Text(
              'Press Play',
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.radio),
          label: 'Radio',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.info),
          label: 'Info',
        ),
      ]),
    );
  }
}
