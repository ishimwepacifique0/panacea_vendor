import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:geolocator/geolocator.dart';
import 'package:icupa_vendor/screens/auth/welcome_screen.dart';
import 'package:icupa_vendor/services/local_storage.dart';
import 'package:icupa_vendor/services/notification_service.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/shared/widgets/app_screen.dart';
import 'package:icupa_vendor/utils.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class SplashScreen extends ConsumerStatefulWidget {
  const SplashScreen({super.key});

  @override
  SplashScreenState createState() => SplashScreenState();
}

class SplashScreenState extends ConsumerState<SplashScreen> {
  String error = '';
  @override
  void initState() {
    super.initState();
    initApp();
  }

  Future<void> initApp() async {
    FirebaseFirestore fireStore = FirebaseFirestore.instance;
    fireStore.collection('users').get().then((value) {});
    setState(() {
      error = '';
    });
    try {
      await LocalStorage.init(ref).then((val) async {
        await getLocationPermission();
        late Widget nextScreen;

        final user = ref.read(userProvider);
        if (user != null) {
          final reg = await getRegion(user.countryCode);
          ref.read(regionProvider.notifier).state = reg;
          nextScreen = const AppScreen();
        } else {
          nextScreen = const WelcomeScreen();
        }
        await NotificationService.initialize();
        try {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(
              builder: (context) => nextScreen,
            ),
          );
        } catch (_) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            Navigator.of(context).pushReplacement(
              MaterialPageRoute(
                builder: (context) => nextScreen,
              ),
            );
          });
        }
      });
    } catch (e) {
      if (e is TypeError) {
        await LocalStorage.removeUser();
        initApp();
      } else {
        setState(() {
          error = e.toString();
        });
      }
    }
  }

  Future getLocationPermission() async {
    final locationService = await Geolocator.isLocationServiceEnabled();
    if (locationService) {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final height = MediaQuery.of(context).size.height;
    return RefreshIndicator(
      onRefresh: () async {
        await initApp();
      },
      child: Scaffold(
        backgroundColor: Colors.white,
        body: Stack(
          children: [
            Positioned.fill(
              child: Center(
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 400,
                  ),
                  child: Image.asset(
                    'assets/5.png',
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            ListView(
              physics: const AlwaysScrollableScrollPhysics(),
              children: [
                Container(
                  color: Colors.transparent,
                  height: height,
                  padding: EdgeInsets.only(bottom: height * 0.2),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (error.isNotEmpty)
                        Text(
                          AppLocalizations.of(context)!.failInitialize,
                          style: Theme.of(context).textTheme.headlineMedium!,
                        ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
