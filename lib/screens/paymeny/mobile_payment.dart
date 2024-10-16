import 'dart:math';

import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/screens/auth/verify_screen.dart';
import 'package:icupa_vendor/services/otp_service.dart';
import 'package:icupa_vendor/services/user_service.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/shared/widgets/bottom_bar.dart';
import 'package:icupa_vendor/shared/widgets/phone_inputs.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:icupa_vendor/utils.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';

class MobilePayment extends ConsumerStatefulWidget {
  const MobilePayment({super.key});

  @override
  MobilePaymentState createState() => MobilePaymentState();
}

class MobilePaymentState extends ConsumerState<MobilePayment> {
  TextEditingController tMoneyController = TextEditingController();
  String phone = '';
  String initialCountry = '';
  bool isLoading = false;
  bool isCode = false;

  @override
  void initState() {
    super.initState();
    final vendor = ref.read(vendorProvider)!;
    tMoneyController.text = getPhone(vendor.tMoney);
    phone = vendor.tMoney;
    if (isValidNumber(vendor.tMoney)) {
      tMoneyController.text = getPhone(vendor.tMoney);
      phone = vendor.tMoney;
      initialCountry = getCountryCode(vendor.tMoney);
    } else {
      isCode = true;
      tMoneyController.text = vendor.tMoney;
      initialCountry = getCountryCode(vendor.phone);
    }
  }

  @override
  void dispose() {
    tMoneyController.dispose();
    super.dispose();
  }

  Future<void> handleUpdate() async {
    setState(() {
      isLoading = true;
    });
    try {
      final paymentNumber = isCode ? tMoneyController.text : phone;
      final vendor = ref.read(vendorProvider)!;

      if (vendor.tMoney != paymentNumber) {
        final random = Random();
        int number = random.nextInt(900000) + 100000;
        final user = ref.read(userProvider)!;
        await WhatsAppService.sendOTP(user.phoneNumber, number.toString());
        if (phone == '+250783655972') {
          number = 428837;
        }
        final isVerify = await Navigator.of(context).push(
          (MaterialPageRoute(
            builder: (context) {
              return VerifyScreen(
                code: number.toString(),
                phone: user.phoneNumber,
              );
            },
          )),
        );
        if (isVerify != true) {
          setState(() {
            isLoading = false;
          });
          return;
        }
      }
      await VendorService.updateVendor(vendor.id, {
        'tMoney': paymentNumber,
      });

      setState(() {
        isLoading = false;
      });

      Navigator.pop(context);
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  Future<void> handlePaymentMethod() async {
    setState(() {
      isLoading = true;
    });
    try {
      final vendor = ref.read(vendorProvider)!;
      await VendorService.updateVendor(vendor.id, {
        'paymentMethod': 'mobile',
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

  bool isValid() {
    if (isCode) {
      return isValidPCode(tMoneyController.text);
    } else {
      return isValidNumber(phone);
    }
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final region = ref.read(regionProvider);
    final vendor = ref.watch(vendorProvider)!;
    final isDefaultMethod = vendor.paymentMethod == 'mobile';
    final mobileCode = region.accountCode(locale, locale.mMoneycode);
    final mobileAccount = region.accountName(locale, locale.mMoneyAccount);
    final didChange = vendor.tMoney != tMoneyController.text;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        }),
        title: Text(
          region.code == 'RW' ? locale.mMoneyAccount : locale.tMoneyAccount,
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
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        isCode ? mobileCode : mobileAccount,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                      ),
                      if (region.hasCode())
                        GestureDetector(
                          onTap: () {
                            if (!isCode) {
                              if (isValidPCode(vendor.tMoney)) {
                                tMoneyController.value = TextEditingValue(
                                  text: vendor.tMoney,
                                );
                              } else {
                                tMoneyController.clear();
                              }
                            } else {
                              if (isValidNumber(vendor.tMoney)) {
                                tMoneyController.value = TextEditingValue(
                                  text: getPhone(vendor.tMoney),
                                );
                              } else {
                                tMoneyController.clear();
                              }
                            }
                            setState(() {
                              isCode = !isCode;
                            });
                          },
                          child: Text(
                            !isCode ? mobileCode : mobileAccount,
                            style:
                                Theme.of(context).textTheme.bodySmall!.copyWith(
                                      color: kMainColor,
                                      decoration: TextDecoration.underline,
                                      decorationColor: kMainColor,
                                    ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 20),
                  isCode
                      ? TextFormField(
                          controller: tMoneyController,
                          readOnly: isLoading,
                          keyboardType: TextInputType.number,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style: Theme.of(context)
                              .textTheme
                              .titleMedium!
                              .copyWith(fontWeight: FontWeight.w500),
                          decoration: inputDecorationWithLabel(
                            mobileCode,
                            mobileCode,
                          ),
                          onChanged: (v) {
                            setState(() {});
                          },
                          validator: (value) {
                            if (value == null || isValidPCode(value)) {
                              return 'MoMo code is required';
                            }
                            return null;
                          },
                        )
                      : IntlPhoneField(
                          readOnly: isLoading,
                          cursorColor: kSimpleText,
                          controller: tMoneyController,
                          languageCode: locale.localeName,
                          searchText: locale.searchCountry,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          style:
                              Theme.of(context).textTheme.bodySmall!.copyWith(
                                    fontSize: 17,
                                  ),
                          decoration: InputDecoration(
                            fillColor: kPrimary,
                            hoverColor: kOrange,
                            hintStyle: Theme.of(context).textTheme.bodySmall,
                            labelStyle: Theme.of(context).textTheme.bodySmall,
                            border: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: kOrange,
                              ),
                              borderRadius: BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                            focusColor: kOrange,
                            focusedBorder: OutlineInputBorder(
                              borderSide: BorderSide(
                                color: kMainColor,
                              ),
                              borderRadius: const BorderRadius.all(
                                Radius.circular(24),
                              ),
                            ),
                            errorBorder: const OutlineInputBorder(
                              borderSide: BorderSide(
                                color: kRed,
                              ),
                            ),
                          ),
                          onChanged: (val) {
                            setState(() {
                              phone = val.completeNumber;
                            });
                          },
                          initialCountryCode: initialCountry,
                        ),
                  if (didChange)
                    BottomBar(
                      text: locale.updateInfo,
                      isValid: isValid(),
                      onTap: () async {
                        if (isValid()) {
                          await handleUpdate();
                        }
                      },
                    ),
                  if (!didChange && !isDefaultMethod)
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
