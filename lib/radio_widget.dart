import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:audioplayers/audioplayers.dart';
import 'text_form.dart';
import 'dart:async';
import 'web.dart';

/// Stateless widget that builds the body of the radio, provided the news.
class RadioWidget extends StatefulWidget {
  const RadioWidget({Key? key, required this.newsFromHome}) : super(key: key);

  final Map newsFromHome;

  @override
  State<RadioWidget> createState() => _RadioWidgetState();
}

class _RadioWidgetState extends State<RadioWidget> {
  /// Map of the news read on the radio.
  late Map news;

  /// Decoration image
  Image mesh = Image.network(
    'https://media.istockphoto.com/photos/metal-grille-over-speakers-picture-id182187519?k=20&m=182187519&s=612x612&w=0&h=BjMrjxZk8LdUyKHSNZ1G5bSVbs6lm8zXRKIgl_kcZeY=',
  );

  String radioText = ''; // Read by the TTS
  late Timer timer; // Periodic timer for exec. of radio
  FlutterTts flutterTts = FlutterTts(); // Text To Speech

  bool _isPlaying = false; // Indicates if radio is playing
  bool _audioPlayed = false; // Used for pausing, deprecated.
  AudioPlayer player = AudioPlayer(); // Player for background music
  var topicText; // Stores text on topic form
  var cityText; // Stores text from city form

  // Storing forms, see createForms()
  var itemForm;
  var cityForm;
  var totalForm;

  bool topicPlayed = false;
  bool weatherPlayed =
      false; // Indicates if weather has been played in the last 5 minutes

  // Indicates if weather or topic info is being updated
  bool _updatingCity = false;
  bool _updatingTopic = false;

  // Indexes for news articles
  num localIndex = 0;
  num worldIndex = 0;
  // Index for news option
  int count = 0;

  // Writes the news from the args to its variable, creates forms and initializes the text to speech.
  @override
  initState() {
    news = widget.newsFromHome;
    super.initState();
    createForms();
    flutterTts.setLanguage("en-US");
    flutterTts
        .awaitSpeakCompletion(true); // speak() returns once speech is completed
    flutterTts.speak(''); // initializing
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        resizeToAvoidBottomInset: false,
        body: Center(
          child: ListView(
            children: <Widget>[
              Container(
                padding: EdgeInsets.symmetric(vertical: 40.0, horizontal: 12.0),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(40),
                  child: mesh,
                ),
                width: 350,
              ),
              Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly, children: [
                totalForm,
                buttonChild(context),
              ]),
            ],
          ),
        ));
  }

  Widget buttonChild(context) {
    if (_updatingCity || _updatingTopic) {
      return CircularProgressIndicator();
    } else {
      return ElevatedButton(
          style: ElevatedButton.styleFrom(
            side: BorderSide(),
            primary: Colors.grey,
            onPrimary: Colors.black,
            shadowColor: Colors.white,
            elevation: 5,
            shape: const CircleBorder(),
            minimumSize: const Size(70, 70), //////// HERE
          ),
          onPressed: _togglePlaying,
          child: (_isPlaying
              ? const Icon(Icons.pause, size: 40)
              : const Icon(Icons.play_arrow, size: 40)));
    }
  }

  Timer weatherTimer() =>
      Timer(const Duration(minutes: 5), () => {switchWeather()});

  Timer topicTimer() =>
      Timer(const Duration(minutes: 5), () => {switchTopic()});

  void switchTopic() {
    topicPlayed = false;
  }

  void switchWeather() {
    weatherPlayed = false;
  }

  reduceLocal() {
    localIndex += 1;
    if (localIndex > news['local'].length - 1) {
      //reduce
      localIndex = localIndex % news['local'].length;
    }
  }

  reduceWorld() {
    worldIndex += 1;
    if (worldIndex > news['world'].length - 1) {
      //reduce
      worldIndex = worldIndex % news['world'].length;
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
        style: ElevatedButton.styleFrom(
          primary: Colors.grey,
          onPrimary: Colors.black,
          shadowColor: Colors.white,
        ),
        onPressed: () {
          if (formKey.currentState!.validate()) {
            // Validates nonEmpty and not null
            formKey.currentState!.save();
          }
        },
        child: const Text('Save All'));

    totalForm = Form(
        // to be appended to body.
        key: formKey,
        child: Column(
          children: [itemForm, cityForm, button],
        ));
  }

  void updateTopic(query) async {
    setState(() {
      _updatingTopic = true;
    });

    news['topic'] = await wikipedia(query);
    setState(() {
      _updatingTopic = false;
    });
  }

  void updateCity(query) async {
    setState(() {
      _updatingCity = true;
    });
    news['currweather'] = await getCurrentWeather(query);
    news['dayweather'] = await getDayWeather(query);
    setState(() {
      _updatingCity = false;
    });
  }
  //String cityFormText = cityForm.getCont;

  void disposeTimer() {
    if (timer != null) {
      timer.cancel();
      flutterTts.stop();
      player.pause();
    }
  }

  // webget
  void periodicInfo() async {
    radioText = webGet(count);
    bool readingCompleted = true;

    timer = Timer.periodic(const Duration(seconds: 10), (Timer t) async {
      //localIndex += 1;
      if (readingCompleted) {
        print(radioText);
        if (_isPlaying) {
          readingCompleted = false;
          player.resume();
          await flutterTts.speak(radioText);
          readingCompleted = true;
          //not working, crashes
        }

        count += 1;
        if (count > 4) {
          //reduce
          count = count % 5;
        }
        radioText = webGet(count);
      }
    });
  }

  String webGet(item) {
    String information = 'There was an error';
    switch (item) {
      case 0:
        if (weatherPlayed) {
          player.setSourceAsset("audio/stay_the_course.mp3");
          information = news['world'][worldIndex];
          reduceWorld();
        } else {
          player.setSourceAsset("audio/localforecast.mp3");
          information = news['currweather'];
          weatherPlayed = true;
          weatherTimer();
        }
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
        if (weatherPlayed) {
          player.setSourceAsset("audio/stay_the_course.mp3");
          information = news['world'][worldIndex];
          reduceWorld();
        } else {
          player.setSourceAsset("audio/springish.mp3");
          information = news['dayweather'];
          weatherPlayed = true;
          weatherTimer();
        }

        break;
      case 4:
        if (news['topic'] != null && !weatherPlayed) {
          player.setSourceAsset("audio/sincerely.mp3");
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
      disposeTimer();
      setState(() {
        _isPlaying = false;
      });
    } else if (!_isPlaying && !_audioPlayed) {
      periodicInfo();
      setState(() {
        _isPlaying = true;
        _audioPlayed = true;
      });
    } else {
      periodicInfo();
      setState(() {
        _isPlaying = true;
      });
    }
  }
}
