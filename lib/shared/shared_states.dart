import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/models/region.dart';
import 'package:icupa_vendor/models/user.dart';
import 'package:icupa_vendor/models/vendor.dart';
import 'package:icupa_vendor/themes/style.dart';

final localeProvider = StateProvider<Locale>((ref) {
  return const Locale('fr');
});

final userProvider = StateProvider<User?>((ref) {
  return null;
});

final vendorProvider = StateProvider<Vendor?>((ref) {
  return null;
});

final themeProvider = StateProvider<ThemeData>((ref) {
  return appTheme;
});

final locationProvider = StateProvider<Map<String, dynamic>>((ref) {
  return {};
});

final regionProvider = StateProvider<Region>((ref) {
  return Region('', '', 0, {});
});
