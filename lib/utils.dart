import 'dart:io';
import 'dart:math';

import 'package:collection/collection.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icupa_vendor/models/region.dart';
import 'package:icupa_vendor/services/local_storage.dart';
import 'package:icupa_vendor/services/location_services.dart';
import 'package:icupa_vendor/services/user_service.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:intl/intl.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/phone_number.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

String formatPrice(int price) {
  return NumberFormat('#,##0', 'en_US').format(price);
}

String formatDateTime(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final yesterdayStart = todayStart.subtract(const Duration(days: 1));

  AppLocalizations locale = AppLocalizations.of(context)!;
  String format = locale.localeName == 'en' ? 'en_US' : 'fr_FR';

  if (date.isAfter(todayStart)) {
    return '${locale.today}, ${DateFormat('HH:mm', format).format(date)}';
  } else if (date.isAfter(yesterdayStart) && date.isBefore(todayStart)) {
    return '${locale.yesterday}, ${DateFormat('HH:mm', format).format(date)}';
  } else {
    return DateFormat('d MMMM, HH:mm', format).format(date);
  }
}

String formatBalance(double price) {
  return NumberFormat('#,##0.00', 'en_US').format(price);
}

String randomReqId(prefix) {
  int randomNumber = Random().nextInt(1000);
  return '$prefix$randomNumber';
}

String formatPDateTime(DateTime dateTime) {
  return DateFormat('yyyy-MM-dd HH:mm:ss').format(dateTime);
}

String localeFormatDate(BuildContext context, DateTime date) {
  AppLocalizations locale = AppLocalizations.of(context)!;
  String format = locale.localeName == 'en' ? 'en_US' : 'fr_FR';
  return DateFormat('d-MM-yyyy', format).format(date);
}

bool isEmail(String em) {
  String p =
      r'^(([^<>()[\]\\.,;:\s@\"]+(\.[^<>()[\]\\.,;:\s@\"]+)*)|(\".+\"))@((\[[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\.[0-9]{1,3}\])|(([a-zA-Z\-0-9]+\.)+[a-zA-Z]{2,}))$';
  RegExp regExp = RegExp(p);
  return regExp.hasMatch(em);
}

String hideDigits(String input, int visibleCount) {
  if (input.length <= visibleCount) {
    return input;
  }

  String hiddenPart = '*' * (input.length - visibleCount);
  return hiddenPart + input.substring(input.length - visibleCount);
}

String formatDate(BuildContext context, DateTime date) {
  final now = DateTime.now();
  final todayStart = DateTime(now.year, now.month, now.day);
  final yesterdayStart = todayStart.subtract(const Duration(days: 1));

  AppLocalizations locale = AppLocalizations.of(context)!;
  String format = locale.localeName == 'en' ? 'en_US' : 'fr_FR';

  if (date.isAfter(todayStart)) {
    return locale.today;
  } else if (date.isAfter(yesterdayStart) && date.isBefore(todayStart)) {
    return locale.yesterday;
  } else {
    return DateFormat('d MMMM', format).format(date);
  }
}

String formatTime(BuildContext context, DateTime date) {
  AppLocalizations locale = AppLocalizations.of(context)!;
  String format = locale.localeName == 'en' ? 'en_US' : 'fr_FR';
  return DateFormat('HH:mm', format).format(date);
}

InputDecoration inputDecorationWithLabel(String hint, String labelText) {
  return InputDecoration(
    hintStyle: TextStyle(
        fontSize: 14,
        color: kHintColor,
        height: 1.5,
        fontWeight: FontWeight.w500),
    hintText: hint,
    labelStyle: const TextStyle(
        fontSize: 14,
        color: Colors.black,
        height: 1,
        fontWeight: FontWeight.w500),
    labelText: labelText,
    filled: true,
    alignLabelWithHint: true,
    fillColor: kWhiteColor,
    contentPadding: const EdgeInsets.all(15),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: kLightGreyColor),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide:const BorderSide(color: lavenderColor),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(10),
      borderSide: BorderSide(color: kLightGreyColor),
    ),
  );
}

void showConfirmModal(BuildContext context, String title, String message,
    String actionText, Function() onPressed) {
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: false,
        backgroundColor: kWhiteColor,
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: SizedBox(
          width: double.infinity,
          height: 50,
          child: Text(
            message,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ),
        actions: [
          TextButton(
            onPressed: onPressed,
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 11.7,
                letterSpacing: 0.06,
                fontWeight: FontWeight.bold,
                color: lavenderColor,
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(
                fontSize: 11.7,
                letterSpacing: 0.06,
                fontWeight: FontWeight.bold,
                color: Color(0xffffa025),
              ),
            ),
          ),
        ],
      );
    },
  );
}

void showRejectModal(BuildContext context, String title, String message,
    String actionText, Function(String) onPressed) {
  String? reason = 'out of stock';
  showDialog(
    context: context,
    builder: (BuildContext context) {
      return AlertDialog(
        scrollable: false,
        backgroundColor: kWhiteColor,
        title: Text(
          title,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: SizedBox(
          width: double.infinity,
          height: 120,
          child: StatefulBuilder(
            builder: (context, setState) {
              return Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  RadioListTile<String>(
                    title: Text(
                      AppLocalizations.of(context)!.outOfStock,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: 'out of stock',
                    groupValue: reason,
                    onChanged: (String? value) {
                      setState(() {
                        reason = value;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: Text(
                      AppLocalizations.of(context)!.otherReason,
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                    value: 'other',
                    groupValue: reason,
                    onChanged: (String? value) {
                      setState(() {
                        reason = value;
                      });
                    },
                  ),
                ],
              );
            },
          ),
        ),
        actions: [
          TextButton(
            onPressed: () async {
              await onPressed(reason ?? '');
              Navigator.pop(context);
            },
            child: Text(
              actionText,
              style: const TextStyle(
                fontSize: 11.7,
                letterSpacing: 0.06,
                fontWeight: FontWeight.bold,
                color: Color(0xffffa025),
              ),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
            },
            child: Text(
              AppLocalizations.of(context)!.cancel,
              style: const TextStyle(
                fontSize: 11.7,
                letterSpacing: 0.06,
                fontWeight: FontWeight.bold,
                color: lavenderColor,
              ),
            ),
          ),
        ],
      );
    },
  );
}

String getPhone(String phone) {
  return PhoneNumber.fromCompleteNumber(completeNumber: phone).number;
}

String getCountryCode(String phone) {
  return PhoneNumber.fromCompleteNumber(completeNumber: phone).countryISOCode;
}

Country? getCountry(String code) {
  return countries.firstWhereOrNull((c) => c.code == code);
}

bool isValidNumber(String phone) {
  if (phone.isEmpty || phone[0] != '+') return false;
  try {
    final number = PhoneNumber.fromCompleteNumber(completeNumber: phone);
    return number.isValidNumber();
  } catch (_) {
    return false;
  }
}

bool isValidPCode(String code) {
  return code.isNotEmpty && RegExp(r'^[0-9]+$').hasMatch(code);
}

void messageToWhatApp(String message, String phone) async {
  String url = 'https://wa.me/$phone?text=${Uri.encodeComponent(message)}/';
  if (await canLaunchUrl(Uri.parse(url))) {
    await launchUrl(Uri.parse(url));
  }
}

void handlePriceChange(String value, TextEditingController controller) {
  int? val = int.tryParse(
    value.replaceAll(',', ''),
  );
  if (val == null) {
    controller.value = const TextEditingValue(
      text: '',
      selection: TextSelection.collapsed(
        offset: ('').length,
      ),
    );
    return;
  }
  final formattedVal = formatPrice(val);
  controller.value = TextEditingValue(
    text: formattedVal,
    selection: TextSelection.collapsed(
      offset: formattedVal.length,
    ),
  );
}

Future<void> showLanguageSelectionDialog(
    BuildContext context, WidgetRef ref) async {
  final prefs = await SharedPreferences.getInstance();

  return showDialog(
    context: context,
    builder: (BuildContext context) {
      final locale = AppLocalizations.of(context)!;
      return AlertDialog(
        title: Text(
          locale.selectLanguage,
          style: Theme.of(context).textTheme.headlineMedium,
        ),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            TextButton(
              onPressed: () {
                ref.read(localeProvider.notifier).state = const Locale('en');
                prefs.setString('locale', 'en');
                Navigator.pop(context);
              },
              child: Text(
                'English',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
            TextButton(
              onPressed: () {
                ref.read(localeProvider.notifier).state = const Locale('fr');
                prefs.setString('locale', 'fr');
                Navigator.pop(context);
              },
              child: Text(
                'French',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ),
          ],
        ),
      );
    },
  );
}

Future<Region> getRegion(String countryCode) async {
  late String localCode;
  try {
    localCode = Platform.localeName.split('_')[1];
  } catch (_) {
    localCode = countryCode;
  }
  final reg = await UserService.getRegion(localCode);
  return reg ?? Region('', '', 0, {});
}

dynamic showToast(BuildContext context, String message,
    {Toast toastLength = Toast.LENGTH_SHORT}) {
  return Fluttertoast.showToast(
    msg: message,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.BOTTOM,
    fontSize: 16.0,
  );
}

Future getUserCurrentLocation(WidgetRef ref) async {
  final serviceEnabled = await Geolocator.isLocationServiceEnabled();
  if (serviceEnabled) {
    try {
      await Geolocator.getCurrentPosition().then((value) async {
        var address = await LocationService.getAddressFromCoordinates(
          value.latitude,
          value.longitude,
        );
        final data = {
          'address': address,
          'lat': value.latitude,
          'long': value.longitude,
        };
        ref.read(locationProvider.notifier).state = data;
        LocalStorage.setUserLocation(data);
      });
    } catch (_) {
      return throw Exception('location error');
    }
  } else {
    return throw Exception('error service');
  }
}

void showPermissionDialog(context, Function initApp) async {
  final locale = AppLocalizations.of(context)!;
  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(locale.enableLocation),
        content: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(locale.enableLocationMessage),
            const SizedBox(height: 10),
            Text(locale.howToEnable),
            const SizedBox(height: 10),
            ListTile(
              minTileHeight: 5,
              minVerticalPadding: 5,
              leading: const Icon(
                Icons.fiber_manual_record,
                size: 12,
              ),
              titleTextStyle: Theme.of(context).textTheme.bodyMedium,
              title: Text(locale.openSettings),
            ),
            ListTile(
              minTileHeight: 5,
              minVerticalPadding: 5,
              leading: const Icon(
                Icons.fiber_manual_record,
                size: 12,
              ),
              titleTextStyle: Theme.of(context).textTheme.bodyMedium,
              title: Text(locale.goToLocation),
            ),
            ListTile(
              minTileHeight: 5,
              minVerticalPadding: 5,
              leading: const Icon(
                Icons.fiber_manual_record,
                size: 12,
              ),
              titleTextStyle: Theme.of(context).textTheme.bodyMedium,
              title: Text(locale.turnOnLocation),
            ),
          ],
        ),
        actions: <Widget>[
          MaterialButton(
            textColor: lavenderColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: kTransparentColor),
            ),
            onPressed: () {
              openAppSettings();
            },
            child: Text(locale.goToSettings),
          ),
          MaterialButton(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: kTransparentColor),
            ),
            textColor: lavenderColor,
            onPressed: () async {
              initApp();
            },
            child: Text(locale.tryAgain),
          )
        ],
      );
    },
  );
}

void showLocationServiceDialog(BuildContext context, Function initApp) async {
  final locale = AppLocalizations.of(context)!;

  await showDialog(
    context: context,
    barrierDismissible: true,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text(locale.enableLocation),
        content: Text(locale.enableLocationMessage),
        actions: <Widget>[
          MaterialButton(
            textColor: lavenderColor,
            shape: RoundedRectangleBorder(
              side: BorderSide(color: kTransparentColor),
            ),
            onPressed: () async {
              Geolocator.openLocationSettings();
            },
            child: Text(locale.openSettings),
          ),
          MaterialButton(
            shape: RoundedRectangleBorder(
              side: BorderSide(color: kTransparentColor),
            ),
            textColor: lavenderColor,
            onPressed: () {
              initApp();
            },
            child: Text(locale.tryAgain),
          )
        ],
      );
    },
  );
}
