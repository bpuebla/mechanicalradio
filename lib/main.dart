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
  var news;
  FlutterTts flutterTts = FlutterTts();

  bool _isPlaying = false;
  bool _audioPlayed = false;
  AudioPlayer player = AudioPlayer();
  String audioasset = "assets/audio/sound1.mp3";
  late Uint8List audiobytes;
  var topicText;
  var cityText;
  var itemForm;
  var cityForm;
  createThings() {
    itemForm = MyTextFormField(
        hintText: 'Enter a topic...',
        onSaved: (String? value) {
          topicText = value;
        });
    cityForm = MyTextFormField(
        hintText: 'Enter a city',
        onSaved: (String? value) {
          cityText = value;
        });
  }
  //String cityFormText = cityForm.getCont;

  num localIndex = 0;
  num worldIndex = 0;
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
    createThings();

    news = fetchAllNews();
    //timing

    //periodicInfo();
  }

  void disposeTimer() {
    if (timer != null) {
      timer.cancel();
    }
  }

  // webget
  void periodicInfo() async {
    radioText = await webGet(0);

    int count = 0;

    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) async {
      localIndex += 1;
      count += 1;

      if (count > 4) {
        //reduce
        count = count % 5;
      }
      if (localIndex > news['local'].length) {
        // to be corrected
        localIndex = localIndex % (news['local'].length + 1);
      }

      radioText = await webGet(count);
      if (_isPlaying) {
        flutterTts.speak(radioText);
      }
    });
  }

  //String getNews(item, index) {}

  Future<String> webGet(item, {form, city = 'vienna'}) async {
    String information = 'There was an error';
    if (form == null || form == '') {
      // TO BE REMOVED ONLY TESTING
      item -= 1;
    }
    switch (item) {
      case 0:
        information = news['currweather'];
        break;
      case 1:
        information = news['local'][localIndex];
        break;
      case 2:
        information = await bbcnews2Article(news['world'], worldIndex);
        break;
      case 3:
        information = news['dayweather'];
        break;
      case 4:
        information = news['topic'];
        break;
    }

    return information;
  }

  // player
  void _togglePlaying() async {
    if (_isPlaying && _audioPlayed) {
      //int result = await player.pause();
      //if (result == 1) {
      disposeTimer();
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
            cityForm,
            itemForm,
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
/*
/*

Custom Form Builder

Passes text to the HomePageState

*/

class MyCustomForm extends StatefulWidget {
  const MyCustomForm({Key? key}) : super(key: key);

  String _controllerText;

  String get controllerText => 'test';

  set controllerText(String controllerText) {
    _controllerText = controllerText;
  }

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
    widget.controllerText(controller.text);
    return form;
  }
}

*/

/* New Form */

class MyTextFormField extends StatelessWidget {
  final String hintText;
  final void Function(String?)? onSaved;

  MyTextFormField({
    required this.hintText,
    required this.onSaved,
  });
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(8.0),
      child: TextFormField(
        decoration: InputDecoration(
          hintText: hintText,
          contentPadding: EdgeInsets.all(15.0),
          border: InputBorder.none,
          filled: true,
          fillColor: Colors.grey[200],
        ),
        validator: (value) {
          if (value == null || value.isEmpty) {
            return 'Please enter some text';
          }
          return null;
        },
        onSaved: onSaved,
      ),
    );
  }
}
