import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/screens/paymeny/add_account.dart';
import 'package:icupa_vendor/services/user_service.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/shared/widgets/bank_account.dart';
import 'package:icupa_vendor/shared/widgets/bottom_bar.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class BankPayment extends ConsumerStatefulWidget {
  const BankPayment({super.key});

  @override
  BankPaymentState createState() => BankPaymentState();
}

class BankPaymentState extends ConsumerState<BankPayment> {
  bool isLoading = false;

  Future<void> handlePaymentMethod() async {
    setState(() {
      isLoading = true;
    });
    try {
      final vendor = ref.read(vendorProvider)!;
      await VendorService.updateVendor(vendor.id, {
        'paymentMethod': 'bank',
      });
      Navigator.pop(context);
      setState(() {
        isLoading = false;
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final vendor = ref.watch(vendorProvider)!;
    final isDefaultMethod = vendor.paymentMethod == 'bank';
    final accounts = vendor.banks;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        }),
        title: Text(
          'Ecobank Account',
          style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                fontWeight: FontWeight.w500,
              ),
        ),
        titleSpacing: 0.0,
      ),
      body: ModalProgressHUD(
        inAsyncCall: isLoading,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: FadedSlideAnimation(
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Expanded(
                    child: ListView(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                      ),
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const AddAccount(),
                                  ),
                                );
                              },
                              child: const Icon(
                                Icons.add,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),
                        ...accounts.map((e) {
                          final isCurrent = e == vendor.banks.first;
                          return GestureDetector(
                            onTap: () {
                              if (!isCurrent) {
                                final newAccounts = [...vendor.banks];
                                newAccounts.remove(e);
                                VendorService.updateVendor(vendor.id, {
                                  'banks': [
                                    e,
                                    ...newAccounts,
                                  ],
                                });
                              }
                            },
                            child: BankAccount(
                              isCurrent: isCurrent,
                              account: e,
                            ),
                          );
                        }),
                      ],
                    ),
                  ),
                  if (!isDefaultMethod && accounts.isNotEmpty)
                    BottomBar(
                      text: 'Make it default',
                      isValid: !isLoading,
                      onTap: () async {
                        handlePaymentMethod();
                      },
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
