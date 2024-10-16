import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/models/user.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:icupa_vendor/services/notification_service.dart';
import 'package:icupa_vendor/services/user_service.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/foundation.dart';

class LocalStorage {
  static String userKey = 'current-user';
  static String userLocationKey = 'current-user-location';
  static String visitKey = 'visited';

  static Future<void> init(WidgetRef ref) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? userLang = pref.getString('locale');
    late String localeLang;
    if (kIsWeb) {
      localeLang = 'en';
    } else {
      localeLang = Platform.localeName.split('_')[0];
    }
    localeLang = localeLang == 'fr' ? 'fr' : 'en';
    final locale_ = Locale(userLang ?? localeLang);
    ref.read(localeProvider.notifier).state = locale_;
    User? data = await getUser();
    if (data != null) {
      final vendor = await VendorService.getVendor(data.phoneNumber);
      if (vendor != null) {
        ref.read(vendorProvider.notifier).state = vendor;
        ref.read(userProvider.notifier).state = data;
      }
      final userLocation = await getUserLocation();
      ref.read(locationProvider.notifier).state = userLocation ?? {};
      await NotificationService.getToken().then((v) async {
        final data_ = {...data.tokens, v}.toList();
        UserService.updateUser(data.phoneNumber, {
          'tokens': data_,
        });
      });
    }
    await Future.delayed(const Duration(seconds: 1));
    return ref.read(userProvider);
  }

  static Future<void> setUser(User user) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    var jsonData = user.toJSON();
    jsonData['joinedOn'] = user.joinedOn.toIso8601String();
    String data = jsonEncode(jsonData);
    await pref.setString(userKey, data);
  }

  static Future<void> setUserLocation(Map<String, dynamic> data) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String info = jsonEncode(data);
    await pref.setString(userLocationKey, info);
  }

  static Future<User?> getUser() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? data = pref.getString(userKey);
    try {
      if (data != null) {
        Map<String, dynamic> userData = jsonDecode(data);
        DateTime joinedOn = DateTime.parse(userData['joinedOn']);
        userData['joinedOn'] = Timestamp.fromDate(joinedOn);
        return User.fromJSON(userData);
      }
    } catch (error) {
      await removeUser();
      return null;
    }
    return null;
  }

  static Future<Map<String, dynamic>?> getUserLocation() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    String? data = pref.getString(userLocationKey);
    try {
      if (data != null) {
        Map<String, dynamic> userLocationData = jsonDecode(data);
        return userLocationData;
      }
    } catch (error) {
      await removeUserLocation();
      return null;
    }
    return null;
  }

  static Future<void> removeUser() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(userKey);
  }

  static Future<void> removeUserLocation() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.remove(userLocationKey);
  }

  static Future<void> setVisit({bool didVisit = true}) async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    pref.setBool(visitKey, didVisit);
  }

  static Future<bool> getVisit() async {
    final SharedPreferences pref = await SharedPreferences.getInstance();
    bool? data = pref.getBool(visitKey);
    return data ?? false;
  }
}
