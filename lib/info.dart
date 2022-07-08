/* Info Page */
import 'package:flutter/material.dart';

class InfoPage extends StatefulWidget {
  const InfoPage({Key? key}) : super(key: key);

  final String title = 'Information';

  @override
  State<InfoPage> createState() => _InfoPageState();
}

class _InfoPageState extends State<InfoPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: <Widget>[
            SizedBox(
              height: 400,
              width: 200,
              child: Text(
                'Made by Bautista Puebla with tutoring of Horst Eidenberg for the TU Wien 2022SS course "Mobile App Prototyping".',
                style: Theme.of(context).textTheme.headline5,
              ),
            ),
            Row(children: [
              IconButton(onPressed: openGit(), icon: FaIcon(FontAwesomeIcons.github-square))
            ],)
          ],
        ),
      ),
    );
  }
}
