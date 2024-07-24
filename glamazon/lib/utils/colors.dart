import 'package:flutter/material.dart';

class AppTheme {
  static const Color customColor =  Color.fromARGB(255, 181, 81, 31)
;

  // Define lighter shades of the custom color
  static final Color lighterColor1 = customColor.withOpacity(0.1);
  static final Color lighterColor2 = customColor.withOpacity(0.2);
  static final Color lighterColor3 = customColor.withOpacity(0.3);
  static final Color lighterColor4 = customColor.withOpacity(0.4);
  static final Color lighterColor5 = customColor.withOpacity(0.5);
  static final Color lighterColor6 = customColor.withOpacity(0.6);
  static final Color lighterColor7 = customColor.withOpacity(0.7);
  static final Color lighterColor8 = customColor.withOpacity(0.8);
  static final Color lighterColor9 = customColor.withOpacity(0.9);

  static ThemeData get lightTheme {
    return ThemeData(
      brightness: Brightness.light,
      primarySwatch: createMaterialColor(customColor),
      primaryColor: customColor,
      appBarTheme: AppBarTheme(
        backgroundColor: lighterColor7,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: customColor,
        unselectedItemColor: lighterColor4,
        backgroundColor: Colors.white,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(lighterColor7),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: MaterialStateProperty.all<BorderSide>(
            BorderSide(color: lighterColor5),
          ),
          foregroundColor: MaterialStateProperty.all<Color>(lighterColor5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lighterColor8,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: lighterColor8),
        headlineMedium: TextStyle(color: lighterColor7),
        bodySmall: TextStyle(color: Colors.black),
        bodyMedium: TextStyle(color: Colors.black),
      ),
      iconTheme: IconThemeData(color: lighterColor6),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      primarySwatch: createMaterialColor(customColor),
      primaryColor: customColor,
      appBarTheme: AppBarTheme(
        backgroundColor: lighterColor6,
        iconTheme: IconThemeData(color: Colors.white),
      ),
      bottomNavigationBarTheme: BottomNavigationBarThemeData(
        selectedItemColor: customColor,
        unselectedItemColor: lighterColor4,
        backgroundColor: Colors.black,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          backgroundColor: MaterialStateProperty.all<Color>(lighterColor7),
          foregroundColor: MaterialStateProperty.all<Color>(Colors.white),
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: ButtonStyle(
          side: MaterialStateProperty.all<BorderSide>(
            BorderSide(color: lighterColor5),
          ),
          foregroundColor: MaterialStateProperty.all<Color>(lighterColor5),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: lighterColor8,
      ),
      textTheme: TextTheme(
        headlineLarge: TextStyle(color: lighterColor8),
        headlineMedium: TextStyle(color: lighterColor7),
        bodyMedium: TextStyle(color: Colors.white),
        bodySmall: TextStyle(color: Colors.white),
      ),
      iconTheme: IconThemeData(color: lighterColor6),
    );
  }

  static MaterialColor createMaterialColor(Color color) {
    List strengths = <double>[.05];
    final Map<int, Color> swatch = {};
    final int r = color.red, g = color.green, b = color.blue;

    for (int i = 1; i < 10; i++) {
      strengths.add(0.1 * i);
    }
    for (var strength in strengths) {
      final double ds = 0.5 - strength;
      swatch[(strength * 1000).round()] = Color.fromRGBO(
        r + ((ds < 0 ? r : (255 - r)) * ds).round(),
        g + ((ds < 0 ? g : (255 - g)) * ds).round(),
        b + ((ds < 0 ? b : (255 - b)) * ds).round(),
        1,
      );
    }
    return MaterialColor(color.value, swatch);
  }
}
