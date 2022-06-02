import 'dart:async';
import 'dart:typed_data';
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'palette.dart';
import 'web.dart';
import 'dart:io'; // later internet connection check

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
  String radioText = '';
  var timer;
  FlutterTts flutterTts = FlutterTts();

  bool _isPlaying = false;
  bool _audioPlayed = false;
  AudioPlayer player = AudioPlayer();
  String audioasset = "assets/audio/sound1.mp3";
  late Uint8List audiobytes;

  MyCustomForm itemForm = MyCustomForm();
  MyCustomForm cityForm = MyCustomForm();

  @override
  void initState() {
    // audioplay
    //Future.delayed(Duration.zero, () async {
    //  ByteData bytes =
    //      await rootBundle.load(audioasset); //load audio from assets
    //  audiobytes =
    //      bytes.buffer.asUint8List(bytes.offsetInBytes, bytes.lengthInBytes);
    //  setState(() {});
    //});

    super.initState();
    //timing
    //periodicInfo();
  }

  @override
  void dispose() {
    if (timer != null) {
      timer.cancel();
    }
  }

  // webget
  void periodicInfo() async {
    var localNewsTitles = await googleNews();
    int localNewsIndex = 0;

    radioText = await webGet(0, localNewsTitles, localNewsIndex);

    int count = 0;

    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) async {
      localNewsIndex += 1;
      count += 1;

      if (count > 4) {
        //reduce
        count = count % 5;
      }

      if (localNewsIndex > localNewsTitles.length) {
        // to be corrected
        localNewsIndex = localNewsIndex % (localNewsTitles.length + 1);
      }

      radioText = await webGet(count, localNewsTitles, localNewsIndex);
      if (_isPlaying) {
        flutterTts.speak(radioText);
      }
    });
  }

  Future<String> webGet(item, titles, index, {form, city = 'vienna'}) async {
    String information = 'There was an error';
    if (form == null || form == '') {
      // TO BE REMOVED ONLY TESTING
      item -= 1;
    }
    switch (item) {
      case 0:
        information = await getCurrentWeather(city);
        break;
      case 1:
        information = getLocalNewsTitle(titles, index);
        break;
      case 2:
        information = await bbcnews2(1);
        break;
      case 3:
        information = await getDayWeather(city);
        break;
      case 4:
        information = await wikipedia(form);
        break;
    }

    return information;
  }

  // player
  void _togglePlaying() async {
    if (_isPlaying && _audioPlayed) {
      //int result = await player.pause();
      //if (result == 1) {
      dispose();
      setState(() {
        _isPlaying = false;
      });
      //}
    } else if (!_isPlaying && !_audioPlayed) {
      //int result = await player.playBytes(audiobytes);
      //if (result == 1) {
      periodicInfo();
      setState(() {
        _isPlaying = true;
        _audioPlayed = true;
      });
      //}
    } else {
      //int result = await player.resume();
      //if (result == 1) {
      periodicInfo();
      setState(() {
        _isPlaying = true;
      });
      //}
    }
  }

  // Form

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            MyCustomForm(),
            MyCustomForm(),
            Row(children: [
              Center(
                  child: ElevatedButton(
                      onPressed: _togglePlaying,
                      child: (_isPlaying
                          ? const Icon(Icons.pause)
                          : const Icon(Icons.play_arrow)))),
            ]),
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

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key}) : super(key: key);

  set controllerText(String controllerText) {}

  @override
  MyCustomFormState createState() {
    return MyCustomFormState();
  }
}

// Create a corresponding State class.
// This class holds data related to the form.
class MyCustomFormState extends State<MyCustomForm> {
  // Create a global key that uniquely identifies the Form widget
  // and allows validation of the form.
  //
  // Note: This is a GlobalKey<FormState>,
  // not a GlobalKey<MyCustomFormState>.
  final _formKey = GlobalKey<FormState>();
  TextEditingController controller = TextEditingController();

  @override
  Widget build(BuildContext context) {
    // Build a Form widget using the _formKey created above.
    var form = Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextFormField(
            controller: controller,
            // The validator receives the text that the user has entered.
            validator: (value) {
              if (value == null || value.isEmpty) {
                return 'Please enter some text';
              }
              return null;
            },
          ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 16.0),
            child: ElevatedButton(
              onPressed: () {
                // Validate returns true if the form is valid, or false otherwise.
                if (_formKey.currentState!.validate()) {
                  // If the form is valid, display a snackbar. In the real world,
                  // you'd often call a server or save the information in a database.
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text('Processing Data')),
                  );
                }
              },
              child: const Text('Submit'),
            ),
          ),
        ],
      ),
    );
    widget.controllerText = controller.text;
    return form;
  }
}
