import 'package:flutter/material.dart';
import 'package:mechanicalradio/info.dart';
import 'dart:async';
import 'web.dart';
import 'dart:io';
import 'radio_widget.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  /// Map of the news read on the radio.
  late Map news;
  bool newsLoaded = false;
  int _selectedIndex = 0;
  bool _disconnected = false;

  // Rendering
  Center loadingBody = Center(
      child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: const [
        Padding(
            padding: EdgeInsets.all(12.0), child: CircularProgressIndicator()),
        Text("Loading"),
      ]));

  @override
  Widget build(BuildContext context) {
    if (_disconnected) {
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: Center(
              child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                Text("Could not connect to network.",
                    style: Theme.of(context).textTheme.headline6),
              ])));
    }
    if (!newsLoaded) {
      return Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: loadingBody);
    }
    return WillPopScope(
        onWillPop: _onWillPop,
        child: Scaffold(
          appBar: AppBar(
            title: Text(widget.title),
          ),
          body: IndexedStack(
            children: [RadioWidget(newsFromHome: news), const InfoPage()],
            index: _selectedIndex,
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
            currentIndex: _selectedIndex,
            onTap: (int index) {
              setState(() {
                _selectedIndex = index;
              });
            },
          ),
        ));
  }

  @override
  void initState() {
    super.initState();
    createNews();
  }

  void createNews() async {
    bool connected = await checkConnection();
    if (connected) {
      news = await fetchAllNews();
      print('fetched all news');
      setState(() {
        newsLoaded = true;
      });
    } else {
      setState(() {
        _disconnected = false;
      });
    }
  }

  Future<bool> checkConnection() async {
    try {
      final result = await InternetAddress.lookup('example.com');
      if (result.isNotEmpty && result[0].rawAddress.isNotEmpty) {
        return true;
      }
    } on SocketException catch (_) {
      return false;
    }
    return false;
  }

  Future<bool> _onWillPop() async {
    setState(() {
      _selectedIndex = 0;
    });
    return false;
  }
}
