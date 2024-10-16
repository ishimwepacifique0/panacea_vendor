import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/screens/paymeny/bank_payment.dart';
import 'package:icupa_vendor/screens/paymeny/mobile_payment.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/themes/colors.dart';

List<Map> paymentMethods = [
  {'title': 'TMoney', 'icon': 'assets/tmoney.png'},
  {'title': 'MoMo', 'icon': 'assets/momo.png'},
  {'title': 'Ecobank', 'icon': 'assets/eco_bank.png'},
];

class Payments extends ConsumerWidget {
  const Payments({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocalizations.of(context)!;
    final region = ref.read(regionProvider);
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        }),
        title: Text(
          'Payment Methods',
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
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 15.0,
            vertical: 50,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              paymentMethod(
                context,
                region.code == 'RW'
                    ? locale.mMoneyAccount
                    : locale.tMoneyAccount,
                region.code == 'RW' ? 'assets/momo.png' : 'assets/tmoney.png',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const MobilePayment();
                    }),
                  );
                },
              ),
              paymentMethod(
                context,
                'Ecobank',
                'assets/eco_bank.png',
                () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) {
                      return const BankPayment();
                    }),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget paymentMethod(BuildContext context, String title, String asset,
      void Function()? onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 20),
        padding: const EdgeInsets.symmetric(
          vertical: 10,
          horizontal: 20,
        ),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(10),
          border: Border.all(
            color: kGreyColor,
            width: 1,
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Row(
              children: [
                Image.asset(
                  asset,
                  width: 40,
                ),
                const SizedBox(width: 10),
                Text(
                  title,
                  style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                        fontSize: 18,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                      ),
                ),
              ],
            ),
            Icon(
              Icons.arrow_forward_ios,
              size: 25,
              color: kDisabledColor,
            ),
          ],
        ),
      ),
    );
  }
}
