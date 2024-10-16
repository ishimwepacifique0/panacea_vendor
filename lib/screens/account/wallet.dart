import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:icupa_vendor/shared/widgets/phone_inputs.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class Wallet extends StatelessWidget {
  const Wallet({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          AppLocalizations.of(context)!.wallet,
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        titleSpacing: 0.0,
      ),
      body: FadedSlideAnimation(
          beginOffset: const Offset(0, 0.3),
          endOffset: const Offset(0, 0),
          slideCurve: Curves.linearToEaseOut,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                height: 40.0,
                width: double.infinity,
                padding:
                    const EdgeInsets.only(left: 20.0, right: 20.0, top: 10.0),
                color: Theme.of(context).cardColor,
                child: Text(
                  AppLocalizations.of(context)!.recent,
                  style: Theme.of(context).textTheme.titleSmall!.copyWith(
                      color: kTextColor,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 0.08),
                ),
              ),
              const Expanded(
                  child: Center(
                child: Text('No Record Found'),
              )),
            ],
          )),
    );
  }

  Widget orderData() {
    return const Column(
      children: [],
    );
  }
}
