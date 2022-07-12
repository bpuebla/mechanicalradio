/* Info Page */
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:url_launcher/url_launcher.dart';

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
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            SizedBox(
              height: 120,
              width: 200,
              child: Text(
                'Made by Bautista Puebla with tutoring of Horst Eidenberger for the TU Wien 2022SS course "Mobile App Prototyping".',
                style: Theme.of(context).textTheme.subtitle1,
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                IconButton(
                    padding: EdgeInsets.all(10.0),
                    onPressed: () => openGit(),
                    icon: const FaIcon(
                      FontAwesomeIcons.githubSquare,
                      size: 34.0,
                      color: Colors.blueGrey,
                    ))
              ],
            )
          ],
        ),
      ),
    );
  }

  openGit() async {
    final uri = Uri.parse("https://github.com/bpuebla/mechanicalradio");
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri);
    }
  }
}
