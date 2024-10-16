import 'package:animation_wrappers/animation_wrappers.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/models/region.dart';
import 'package:icupa_vendor/screens/auth/login.dart';
import 'package:icupa_vendor/services/user_service.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/shared/widgets/bottom_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/themes/colors.dart';

class WelcomeScreen extends ConsumerStatefulWidget {
  const WelcomeScreen({super.key});

  @override
  ConsumerState<WelcomeScreen> createState() => WelcomeScreenState();
}

class WelcomeScreenState extends ConsumerState<WelcomeScreen> {
  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(milliseconds: 300), () {
      final user = ref.read(userProvider);
      if (user != null) {
        UserService.unregisterForNotifications(user);
      }
      ref.read(vendorProvider.notifier).state = null;
      ref.read(userProvider.notifier).state = null;
      ref.read(regionProvider.notifier).state = Region('', '', 0, {});
      ref.read(locationProvider.notifier).state = {};
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        backgroundColor: kMainColor,
        systemOverlayStyle: SystemUiOverlayStyle(
          systemNavigationBarColor: kMainColor,
        ),
      ),
      body: FadedSlideAnimation(
        beginOffset: const Offset(0, 0.3),
        endOffset: const Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: Container(
          color: kMainColor,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              const Spacer(),
              Expanded(
                flex: 3,
                child: Center(
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                    ),
                    child: Image.asset('assets/logo.png'),
                  ),
                ),
              ),
              const Spacer(),
              Align(
                alignment: Alignment.bottomCenter,
                child: Container(
                  constraints: const BoxConstraints(
                    maxWidth: 600,
                  ),
                  child: BottomBar(
                    color: kWhiteColor,
                    textColor: kMainColor,
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) {
                            return const Login();
                          },
                        ),
                      );
                    },
                    text: locale.login,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
