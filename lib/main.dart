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
        scaffoldBackgroundColor: const Color.fromARGB(255, 19, 19, 19),
        textTheme: const TextTheme()
            .apply(bodyColor: const Color.fromARGB(255, 131, 176, 186)),
        primarySwatch: Palette.greenTone,
      ),
      initialRoute: '/home',
      routes: {
        // When navigating to the "/" route, build the FirstScreen widget.
        '/home': (context) => const MyHomePage(title: 'Mechanical Radio'),
        // When navigating to the "/second" route, build the SecondScreen widget.
        '/info': (context) => const InfoPage(),
      },
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
  Image mesh = Image.network(
    'https://freevector-images.s3.amazonaws.com/uploads/vector/preview/40062/FreeVectorSpeakerGrillTexture.jpg',
    height: 200,
    width: 900,
  );

  String radioText = '';
  var timer;
  var news;
  FlutterTts flutterTts = FlutterTts();

  bool _isPlaying = false;
  bool _audioPlayed = false;
  AudioPlayer player = AudioPlayer();
  var topicText;
  var cityText;
  var itemForm;
  var cityForm;
  var totalForm;

  num localNewsIndex = 0;
  num worldNewsIndex = 0;

  reduceLocal() {
    localNewsIndex += 1;
    if (localNewsIndex > news['local'].length - 1) {
      //reduce
      localNewsIndex = localNewsIndex % news['local'].length;
    }
  }

  reduceWorld() {
    worldNewsIndex += 1;
    if (worldNewsIndex > news['world'].length - 1) {
      //reduce
      worldNewsIndex = worldNewsIndex % news['world'].length;
    }
  }

  void createForms() {
    final formKey = GlobalKey<FormState>();
    itemForm = MyTextFormField(
        hintText: 'Enter a topic...',
        onSaved: (String? value) {
          updateTopic(value);
          topicText = value;
        });
    cityForm = MyTextFormField(
        hintText: 'Enter a city',
        onSaved: (String? value) {
          updateCity(value);
          cityText = value;
        });

    ElevatedButton button = ElevatedButton(
        onPressed: () {
          if (formKey.currentState!.validate()) {
            formKey.currentState!.save();
          }
        },
        child: const Text('Save All'));

    totalForm = Form(
        key: formKey,
        child: Column(
          children: [itemForm, cityForm, button],
        ));
  }

  void updateTopic(query) async {
    news['topic'] = await wikipedia(query);
  }

  void updateCity(query) async {
    news['currweather'] = await getCurrentWeather(query);
    news['dayweather'] = await getDayWeather(query);
  }
  //String cityFormText = cityForm.getCont;

  num localIndex = 0;
  num worldIndex = 0;
  var newsLoaded = false;
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
    createForms();
    createNews();
    //timing

    //periodicInfo();
  }

  void createNews() async {
    news = await fetchAllNews();
    print('fetched all news');
    setState(() {
      newsLoaded = true;
    });
  }

  void disposeTimer() {
    if (timer != null) {
      timer.cancel();
    }
  }

  // webget
  void periodicInfo() async {
    radioText = webGet(0);

    int count = 0;

    timer = Timer.periodic(const Duration(seconds: 15), (Timer t) async {
      //localIndex += 1;
      print(radioText);
      if (_isPlaying) {
        flutterTts.speak(radioText);
        player.resume();
        //await flutterTts.awaitSpeakCompletion(true); not working, crashes
      }

      count += 1;
      if (count > 4) {
        //reduce
        count = count % 5;
      }

      radioText = webGet(count);
    });
  }

  //String getNews(item, index) {}

  String webGet(item) {
    String information = 'There was an error';
    switch (item) {
      case 0:
        player.setSourceAsset("audio/localforecast.mp3");
        information = news['currweather'];
        break;
      case 1:
        if (news['local'].isNotEmpty) {
          player.setSourceAsset("audio/smoothlovin.mp3");
          information = news['local'][localIndex];
          reduceLocal();
        } else {
          player.setSourceAsset("audio/stay_the_course.mp3");
          information = news['world'][worldIndex];
          reduceWorld();
        }

        break;
      case 2:
        player.setSourceAsset("audio/stay_the_course.mp3");
        information = news['world'][worldIndex];
        reduceWorld();
        break;
      case 3:
        player.setSourceAsset("audio/springish.mp3");
        information = news['dayweather'];
        break;
      case 4:
        if (news['topic'] != null) {
          player.setSourceAsset("audio/springish.mp3");
          information = news['topic'];
        } else {
          // if no topic give more world news
          player.setSourceAsset("audio/stay_the_course.mp3");
          information = news['world'][worldIndex];
          reduceWorld();
        }
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
      player.stop();
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

  // Rendering

  @override
  Widget build(BuildContext context) {
    /*if (!newsLoaded) {
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
              child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: const [
              CircularProgressIndicator(),
              Text("Loading"),
            ],
          )));
    }*/
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.title),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            mesh,
            Row(mainAxisAlignment: MainAxisAlignment.center, children: [
              totalForm,
              ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    primary: Colors.black,
                    onPrimary: Colors.white,
                    shadowColor: Color.fromARGB(255, 61, 70, 65),
                    elevation: 3,
                    shape: CircleBorder(),
                    minimumSize: Size(100, 40), //////// HERE
                  ),
                  onPressed: _togglePlaying,
                  child: (_isPlaying
                      ? const Icon(Icons.pause)
                      : const Icon(Icons.play_arrow))),
            ]),
            Text(
              'Press Play',
              style: Theme.of(context).textTheme.headline5,
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.radio),
            label: 'Radio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.info),
            label: 'Info',
          ),
        ],
        onTap: (int index) {
          if (index == 1) {
            Navigator.pushNamed(context, '/info');
          }
        },
      ),
    );
  }
}
