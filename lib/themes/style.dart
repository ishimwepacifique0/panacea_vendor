import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:icupa_vendor/themes/colors.dart';

final ThemeData darkTheme = ThemeData.dark().copyWith(
  //fontFamily: 'OpenSans',
  scaffoldBackgroundColor: kMainTextColor,
  secondaryHeaderColor: kWhiteColor,
  primaryColor: kMainColor,
  // bottomAppBarColor: kMainTextColor,
  dividerColor: const Color(0x1f000000),
  disabledColor: kDisabledColor,
  // buttonColor: kMainColor,
  cardColor: const Color(0xff212321),
  hintColor: kLightTextColor,
  indicatorColor: kMainColor,
  // accentColor: kMainColor,
  bottomAppBarTheme: BottomAppBarTheme(color: kMainColor),
  buttonTheme: ButtonThemeData(
    textTheme: ButtonTextTheme.normal,
    height: 33,
    padding: const EdgeInsets.only(top: 0, bottom: 0, left: 16, right: 16),
    shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(30.0)),
        side: BorderSide(color: kMainColor)),
    alignedDropdown: false,
    buttonColor: kMainColor,
    disabledColor: kDisabledColor,
  ),
  appBarTheme: AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.dark,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarColor: kBlackColor,
    ),
    color: kTransparentColor,
    elevation: 0.0,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(
      color: Colors.white,
    ),
  ),
  //text theme which contains all text styles
  textTheme: GoogleFonts.openSansTextTheme().copyWith(
    //text style of 'Delivering almost everything' at phone_number page
    bodyLarge: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18.3,
    ),

    //text style of 'Everything.' at phone_number page
    bodyMedium: TextStyle(
      fontSize: 18.3,
      letterSpacing: 1.0,
      color: kDisabledColor,
    ),

    //text style of button at phone_number page
    labelLarge: TextStyle(
      fontSize: 13.3,
      color: kWhiteColor,
    ),

    //text style of 'Got Delivered' at home page
    headlineMedium: const TextStyle(
      color: Colors.white,
      fontWeight: FontWeight.bold,
      fontSize: 16.7,
    ),

    //text style of we'll send verification code at register page
    titleLarge: TextStyle(
      color: kLightTextColor,
      fontSize: 13.3,
    ),

    //text style of 'everything you need' at home page
    headlineSmall: TextStyle(
      color: kDisabledColor,
      fontSize: 20.0,
      letterSpacing: 0.5,
    ),

    //text entry text style
    bodySmall: const TextStyle(
      color: Colors.white,
      fontSize: 13.3,
    ),

    labelSmall: TextStyle(color: kLightTextColor, letterSpacing: 0.2),

    //text style of titles of card at home page
    displayMedium: const TextStyle(
      color: Colors.white,
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
    titleSmall: TextStyle(
      color: kLightTextColor,
      fontSize: 15.0,
    ),
  ),
);

final ThemeData appTheme = ThemeData(
  scaffoldBackgroundColor: Colors.white,
  secondaryHeaderColor: kMainTextColor,
  primaryColor: kMainColor,
  // bottomAppBarColor: kWhiteColor,
  dividerColor: const Color(0x1f000000),
  disabledColor: kDisabledColor,
  // buttonColor: kMainColor,
  cardColor: kCardBackgroundColor,
  hintColor: kLightTextColor,
  indicatorColor: kMainColor,
  // accentColor: kMainColor,
  bottomAppBarTheme: BottomAppBarTheme(color: kMainColor),
  buttonTheme: ButtonThemeData(
    textTheme: ButtonTextTheme.normal,
    height: 33,
    padding: const EdgeInsets.only(top: 0, bottom: 0, left: 16, right: 16),
    shape: RoundedRectangleBorder(
        borderRadius: const BorderRadius.all(Radius.circular(30.0)),
        side: BorderSide(color: kMainColor)),
    alignedDropdown: false,
    buttonColor: kMainColor,
    disabledColor: kDisabledColor,
  ),
  appBarTheme: AppBarTheme(
    systemOverlayStyle: SystemUiOverlayStyle(
      statusBarBrightness: Brightness.light,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarIconBrightness: Brightness.light,
      systemNavigationBarColor: kWhiteColor,
    ),
    color: kTransparentColor,
    elevation: 0.0,
    surfaceTintColor: Colors.transparent,
    iconTheme: const IconThemeData(
      color: Colors.black,
    ),
  ),
  //text theme which contains all text styles
  textTheme: GoogleFonts.openSansTextTheme().copyWith(
    //text style of 'Delivering almost everything' at phone_number page
    bodyLarge: const TextStyle(
      fontWeight: FontWeight.bold,
      fontSize: 18.3,
    ),

    //text style of 'Everything.' at phone_number page
    bodyMedium: TextStyle(
      fontSize: 18.3,
      letterSpacing: 1.0,
      color: kDisabledColor,
    ),

    //text style of button at phone_number page
    labelLarge: TextStyle(
      fontSize: 13.3,
      color: kWhiteColor,
    ),

    //text style of 'Got Delivered' at home page
    headlineMedium: const TextStyle(
      color: Colors.black,
      fontWeight: FontWeight.bold,
      fontSize: 16.7,
    ),

    //text style of we'll send verification code at register page
    titleLarge: TextStyle(
      color: kLightTextColor,
      fontSize: 13.3,
    ),

    //text style of 'everything you need' at home page
    headlineSmall: TextStyle(
      color: kDisabledColor,
      fontSize: 20.0,
      letterSpacing: 0.5,
    ),

    //text entry text style
    bodySmall: TextStyle(
      color: kMainTextColor,
      fontSize: 13.3,
    ),

    labelSmall: TextStyle(color: kLightTextColor, letterSpacing: 0.2),

    //text style of titles of card at home page
    displayMedium: TextStyle(
      color: kMainTextColor,
      fontSize: 12.0,
      fontWeight: FontWeight.bold,
      letterSpacing: 0.5,
    ),
    titleSmall: TextStyle(
      color: kLightTextColor,
      fontSize: 15.0,
    ),
  ),
);

//text style of continue bottom bar
final TextStyle bottomBarTextStyle = GoogleFonts.openSans().copyWith(
  fontSize: 15.0,
  color: kWhiteColor,
  fontWeight: FontWeight.w400,
);

//text style of text input and account page list
final TextStyle inputTextStyle = GoogleFonts.openSans().copyWith(
  fontSize: 20.0,
  color: Colors.black,
);

final TextStyle listTitleTextStyle = GoogleFonts.openSans().copyWith(
  fontSize: 16.7,
  fontWeight: FontWeight.bold,
  color: kMainColor,
);

final TextStyle orderMapAppBarTextStyle = GoogleFonts.openSans().copyWith(
  fontSize: 13.3,
  fontWeight: FontWeight.bold,
  color: Colors.black,
);
