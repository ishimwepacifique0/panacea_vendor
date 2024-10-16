import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/services/bank_services.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:icupa_vendor/utils.dart';

class BankAccount extends ConsumerStatefulWidget {
  const BankAccount({
    super.key,
    required this.isCurrent,
    required this.account,
  });

  final bool isCurrent;
  final String account;

  @override
  ConsumerState<BankAccount> createState() => _BankAccountState();
}

class _BankAccountState extends ConsumerState<BankAccount> {
  double balance = 0;
  @override
  void initState() {
    super.initState();
    getBalance();
  }

  Future<void> getBalance() async {
    final b = await BankServices.getBalance(widget.account);
    setState(() {
      balance = b;
    });
  }

  @override
  Widget build(BuildContext context) {
    final region = ref.watch(regionProvider);
    return GestureDetector(
      onTap: () {
        getBalance();
      },
      child: Container(
        margin: const EdgeInsets.symmetric(
          vertical: 10,
        ),
        padding: const EdgeInsets.symmetric(
          vertical: 24,
          horizontal: 24,
        ),
        decoration: BoxDecoration(
          border: Border.all(
            color: widget.isCurrent ? kMainColor : kTransparentColor,
            width: 2,
          ),
          borderRadius: BorderRadius.circular(14),
          gradient: const LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xff0097b2),
              Color(0xff7ed957),
            ],
            stops: [0.0, 1.0],
          ),
        ),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Xpress Account',
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: kWhiteColor,
                            fontSize: 20,
                          ),
                    ),
                    Text(
                      widget.account,
                      textAlign: TextAlign.start,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: kWhiteColor,
                          ),
                    ),
                  ],
                ),
                Image.asset(
                  'assets/eco_bank_express.png',
                ),
              ],
            ),
            const SizedBox(height: 10),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '${region.currency}${formatBalance(balance)}',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            fontWeight: FontWeight.w500,
                            color: kWhiteColor,
                            fontSize: 18,
                          ),
                    ),
                    Text(
                      'Available Balance',
                      textAlign: TextAlign.end,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
                            color: kWhiteColor,
                          ),
                    ),
                  ],
                ),
                Text(
                  'More',
                  textAlign: TextAlign.end,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: kWhiteColor,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
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
