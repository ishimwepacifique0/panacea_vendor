import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/shared/widgets/custom_writer.dart';

class PrivacyPolicy extends StatelessWidget {
  final String title;
  const PrivacyPolicy({required this.title, super.key});

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          title,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 20,
          vertical: 10,
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Header(text: locale.pnp),
              const SizedBox(height: 20),
              P(text: locale.lastupdate),
              const SizedBox(height: 15),
              H2(text: locale.important),
              const SizedBox(height: 15),
              P(text: locale.sub_),
              const SizedBox(height: 15),
              H2(text: locale.one),
              const SizedBox(height: 15),
              P(text: locale.oneone),
              const SizedBox(height: 15),
              P(text: locale.onetwo),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(
                  children: [
                    Li(text: locale.lione),
                    Li(text: locale.litwo),
                    Li(text: locale.lithree),
                  ],
                ),
              ),
              const SizedBox(height: 15),
              H2(text: locale.two),
              const SizedBox(height: 15),
              P(text: locale.twoone),
              const SizedBox(height: 15),
              P(text: locale.twotwo),
              const SizedBox(height: 15),
              P(text: locale.twothree),
              const SizedBox(height: 15),
              P(text: locale.twofour),
              const SizedBox(height: 15),
              H2(text: locale.three),
              const SizedBox(height: 15),
              P(text: locale.threeone),
              const SizedBox(height: 15),
              P(text: locale.r1),
              P(text: locale.r2),
              P(text: locale.r3),
              P(text: locale.r4),
              const SizedBox(height: 15),
              P(text: locale.three2),
              const SizedBox(height: 15),
              P(text: locale.three3),
              const SizedBox(height: 15),
              P(text: locale.three4),
              const SizedBox(height: 15),
              P(text: locale.three5),
              const SizedBox(height: 15),
              P(text: locale.three6),
              const SizedBox(height: 15),
              H2(text: locale.four),
              const SizedBox(height: 15),
              P(text: locale.fourt),
              const SizedBox(height: 15),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: Column(children: [
                  Li(text: locale.l1),
                  Li(text: locale.l2),
                  Li(text: locale.l3),
                  Li(text: locale.l4),
                ]),
              ),
              const SizedBox(height: 15),
              H2(text: locale.five),
              const SizedBox(height: 15),
              P(text: locale.five1),
              const SizedBox(height: 15),
              P(text: locale.five2),
              const SizedBox(height: 15),
              P(text: locale.five3),
              const SizedBox(height: 15),
              P(text: locale.five4),
              const SizedBox(height: 15),
              H2(text: locale.six),
              const SizedBox(height: 15),
              P(text: locale.six1),
              const SizedBox(height: 15),
              P(text: locale.six2),
              const SizedBox(height: 15),
              P(text: locale.six3),
              const SizedBox(height: 15),
              P(text: locale.six4),
              const SizedBox(height: 15),
              P(text: locale.six5),
              const SizedBox(height: 15),
              H2(text: locale.seven),
              const SizedBox(height: 15),
              P(text: locale.seven1),
              const SizedBox(height: 15),
              P(text: locale.seven2),
              const SizedBox(height: 15),
              P(text: locale.seven3),
              const SizedBox(height: 15),
              H2(text: locale.eight),
              const SizedBox(height: 15),
              P(text: locale.ourservice),
              const SizedBox(height: 15),
              H2(text: locale.nine),
              const SizedBox(height: 15),
              P(text: locale.policy),
              const SizedBox(height: 15),
              P(text: locale.note),
              const SizedBox(height: 15),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
