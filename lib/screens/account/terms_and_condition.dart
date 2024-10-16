import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/shared/widgets/custom_writer.dart';

class TermsCondition extends StatelessWidget {
  final String title;
  const TermsCondition({required this.title, super.key});

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
              Header(text: locale.tandc),
              const SizedBox(height: 20),
              P(text: locale.lastupdate),
              const SizedBox(height: 15),
              H2(text: locale.tone),
              const SizedBox(height: 15),
              P(text: locale.toneone),
              const SizedBox(height: 15),
              P(text: locale.tonetwo),
              const SizedBox(height: 15),
              H2(text: locale.ttwo),
              const SizedBox(height: 15),
              P(text: locale.ttwoone),
              const SizedBox(height: 15),
              P(text: locale.ttwotwo),
              const SizedBox(height: 15),
              // P(text: locale.ttwo3),
              // const SizedBox(height: 15),
              H2(text: locale.tthree),
              const SizedBox(height: 15),
              P(text: locale.tthree1),
              const SizedBox(height: 15),
              P(text: locale.tthree2),
              const SizedBox(height: 15),
              P(text: locale.tthree3),
              const SizedBox(height: 15),
              H2(text: locale.tfour),
              const SizedBox(height: 15),
              P(text: locale.tfour1),
              const SizedBox(height: 15),
              P(text: locale.tfour2),
              const SizedBox(height: 15),
              H2(text: locale.tfive),
              const SizedBox(height: 15),
              P(text: locale.tfive1),
              const SizedBox(height: 15),
              P(text: locale.tfive2),
              const SizedBox(height: 15),
              P(text: locale.tfive3),
              const SizedBox(height: 15),
              H2(text: locale.tsix),
              const SizedBox(height: 15),
              P(text: locale.tsix1),
              const SizedBox(height: 15),
              H2(text: locale.tseven),
              const SizedBox(height: 15),
              P(text: locale.tseven1),
              const SizedBox(height: 15),
              P(text: locale.tseven2),
              const SizedBox(height: 15),
              P(text: locale.tseven3),
              const SizedBox(height: 15),
              H2(text: locale.teight),
              const SizedBox(height: 15),
              P(text: locale.teight1),
              const SizedBox(height: 15),
              P(text: locale.teight2),
              const SizedBox(height: 15),
              H2(text: locale.tnine),
              const SizedBox(height: 15),
              P(text: locale.tnine1),
              const SizedBox(height: 15),
              H2(text: locale.tten),
              const SizedBox(height: 15),
              P(text: locale.tten1),
              const SizedBox(height: 15),
              H2(text: locale.televen),
              const SizedBox(height: 15),
              P(text: locale.televen1),
              const SizedBox(height: 15),
              H2(text: locale.ttwelve),
              const SizedBox(height: 15),
              P(text: locale.tqueries),
              const SizedBox(height: 15),
              const SizedBox(height: 15),
              const SizedBox(height: 15),
            ],
          ),
        ),
      ),
    );
  }
}
