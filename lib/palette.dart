import 'package:flutter/material.dart';

class Palette {
  static const MaterialColor greenTone = MaterialColor(
    0xff83b0ba, // 0% comes in here, this will be color picked if no shade is selected when defining a Color property which doesn’t require a swatch.
    <int, Color>{
      50: Color(0xffc1d8dd), //10%
      100: Color(0xffa8c8cf), //20%
      200: Color(0xff9cc0c8), //30%
      300: Color(0xff8fb8c1), //40%
      400: Color(0xff83b0ba), //50%
      500: Color(0xff769ea7), //60%
      600: Color(0xff698d95), //70%
      700: Color(0xff5c7b82), //80%
      800: Color(0xff4f6a70), //90%
      900: Color(0xff42585d), //100%
    },
  );
}
