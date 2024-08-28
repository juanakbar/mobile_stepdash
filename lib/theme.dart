import 'package:flutter/material.dart';

// Colors
Color green1 = const Color(0xFF097210);
Color green2 = const Color(0xFF00880F);

Color dark1 = const Color(0xFF1C1C1C);
Color dark2 = const Color(0xFF4A4A4A);
Color dark3 = const Color(0xFF999798);
Color dark4 = const Color(0xFFEDEDED);

Color blue1 = const Color(0xFF0281A0);
Color blue2 = const Color(0xFF00AED5);
Color blue3 = const Color(0xFF38BBDA);

Color red = const Color(0xFFED2739);
Color purple = const Color(0xFF87027B);

// Typography
TextStyle regular12_5 = const TextStyle(fontFamily: 'Poppins', fontSize: 12.5);
TextStyle regular14 = regular12_5.copyWith(fontSize: 14);

TextStyle semibold12_5 = regular12_5.copyWith(fontWeight: FontWeight.w600);
TextStyle semibold14 = semibold12_5.copyWith(fontSize: 14, letterSpacing: 0.1);

TextStyle bold16 = regular12_5.copyWith(
    fontWeight: FontWeight.w700, fontSize: 16, letterSpacing: 0.1);
TextStyle bold18 = bold16.copyWith(fontSize: 18, letterSpacing: -0.5);

const lightColorScheme = ColorScheme(
  brightness: Brightness.light,
  primary: Color(0xFF416FDF),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF6EAEE7),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFFCFDF6),
  onBackground: Color(0xFF1A1C18),
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFFC2C8BC),
  surface: Color(0xFFF9FAF3),
  onSurface: Color(0xFF1A1C18),
);

const darkColorScheme = ColorScheme(
  brightness: Brightness.dark,
  primary: Color(0xFF416FDF),
  onPrimary: Color(0xFFFFFFFF),
  secondary: Color(0xFF6EAEE7),
  onSecondary: Color(0xFFFFFFFF),
  error: Color(0xFFBA1A1A),
  onError: Color(0xFFFFFFFF),
  background: Color(0xFFFCFDF6),
  onBackground: Color(0xFF1A1C18),
  shadow: Color(0xFF000000),
  outlineVariant: Color(0xFFC2C8BC),
  surface: Color(0xFFF9FAF3),
  onSurface: Color(0xFF1A1C18),
);

ThemeData lightMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.light,
  colorScheme: lightColorScheme,
  elevatedButtonTheme: ElevatedButtonThemeData(
    style: ButtonStyle(
      backgroundColor: MaterialStateProperty.all<Color>(
        lightColorScheme.primary, // Slightly darker shade for the button
      ),
      foregroundColor:
          MaterialStateProperty.all<Color>(Colors.white), // text color
      elevation: MaterialStateProperty.all<double>(5.0), // shadow
      padding: MaterialStateProperty.all<EdgeInsets>(
          const EdgeInsets.symmetric(horizontal: 20, vertical: 18)),
      shape: MaterialStateProperty.all<RoundedRectangleBorder>(
        RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16), // Adjust as needed
        ),
      ),
    ),
  ),
);

ThemeData darkMode = ThemeData(
  useMaterial3: true,
  brightness: Brightness.dark,
  colorScheme: darkColorScheme,
);

class TextCustom extends StatelessWidget {
  final String text;
  final double fontSize;
  final Color color;
  final FontWeight fontWeight;
  final TextOverflow textOverflow;
  final int? maxLine;
  final TextAlign textAlign;

  const TextCustom(
      {super.key,
      required this.text,
      this.fontSize = 18,
      this.color = Colors.black,
      this.fontWeight = FontWeight.normal,
      this.textOverflow = TextOverflow.visible,
      this.maxLine,
      this.textAlign = TextAlign.left});

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      overflow: textOverflow,
      maxLines: maxLine,
      textAlign: textAlign,
      style:
          TextStyle(fontSize: fontSize, color: color, fontWeight: fontWeight),
    );
  }
}

class ColorsCustom {
  static const Color primaryColor = Color(0xff1977F3);
  static const Color secundaryColor = Color(0xff5B6589);
  static const Color backgroundColor = Color(0xffF5F5F5);
}

const Color blueButton = Color(0xFF5468FF);
const Color blueText = Color(0xFF4D60E7);

const Color grayText = Color(0xFF5D5F65);
const Color whiteText = Color(0xFFEDEEEF);

const Color white = Color(0xFFFFFFFF);
const Color black = Color(0xFF000000);

const Color blackBG = Color(0xFF181A20);
const Color blackTextFild = Color(0xFF262A34);

const List<Color> gradient = [
  Color.fromRGBO(24, 26, 32, 1),
  Color.fromRGBO(24, 26, 32, 0.9),
  Color.fromRGBO(24, 26, 32, 0.8),
  Color.fromRGBO(24, 26, 32, 0.7),
  Color.fromRGBO(24, 26, 32, 0.6),
  Color.fromRGBO(24, 26, 32, 0.5),
  Color.fromRGBO(24, 26, 32, 0.4),
  Color.fromRGBO(24, 26, 32, 0.0),
];
const TextStyle headline = TextStyle(
  fontSize: 28,
  color: whiteText,
  fontWeight: FontWeight.bold,
);

const TextStyle headlineDot = TextStyle(
  fontSize: 30,
  color: blueText,
  fontWeight: FontWeight.bold,
);
const TextStyle headline1 = TextStyle(
  fontSize: 24,
  color: whiteText,
  fontWeight: FontWeight.bold,
);

const TextStyle headline2 = TextStyle(
  fontSize: 14,
  color: whiteText,
  fontWeight: FontWeight.w600,
);
const TextStyle headline3 = TextStyle(
  fontSize: 14,
  color: grayText,
  fontWeight: FontWeight.bold,
);
const TextStyle hintStyle = TextStyle(
  fontSize: 14,
  color: grayText,
  fontWeight: FontWeight.bold,
);
