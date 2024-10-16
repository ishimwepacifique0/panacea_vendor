import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:icupa_vendor/models/account_info.dart';
import 'package:icupa_vendor/services/bank_services.dart';
import 'package:icupa_vendor/services/user_service.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/shared/widgets/bottom_bar.dart';
import 'package:icupa_vendor/shared/widgets/phone_inputs.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:icupa_vendor/utils.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AddAccount extends ConsumerStatefulWidget {
  const AddAccount({super.key});

  @override
  AddAccountState createState() => AddAccountState();
}

class AddAccountState extends ConsumerState<AddAccount> {
  bool isLoading = false;
  bool isSubmitted = false;
  TextEditingController fNameController = TextEditingController();
  TextEditingController lNameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController idNoController = TextEditingController();
  TextEditingController emailController = TextEditingController();

  DateTime? idIssue, idExpiry, birthDate;
  int phone = 0;
  String gender = 'M';

  Future<void> handleClick() async {
    setState(() {
      isLoading = true;
      isSubmitted = true;
    });
    try {
      if (fNameController.text.isNotEmpty &&
          lNameController.text.isNotEmpty &&
          phoneController.text.isNotEmpty &&
          idNoController.text.isNotEmpty &&
          idIssue != null &&
          idExpiry != null &&
          birthDate != null &&
          validateEmail(emailController.text) == null) {
        final region = ref.read(regionProvider);
        final vendor = ref.read(vendorProvider)!;

        final accountInfo = AccountInfo(
          firstName: fNameController.text,
          lastName: lNameController.text,
          mobileNo: phone,
          gender: gender,
          identityNo: idNoController.text,
          idIssue: Timestamp.fromDate(idIssue!),
          idExpiry: Timestamp.fromDate(idExpiry!),
          currency: region.currency,
          countryCode: vendor.countryCode,
          dbDate: Timestamp.fromDate(birthDate!),
          country: vendor.countryCode,
          email: emailController.text,
          city: vendor.countryCode,
        );
        await Future.delayed(const Duration(seconds: 2));
        final accountNo = await BankServices.openXpressAccount(accountInfo);
        if (accountNo?.isEmpty ?? true) {
          final vendor = ref.read(vendorProvider)!;
          await VendorService.updateVendor(vendor.id, {
            'banks': {
              ...vendor.banks,
              birthDate!.microsecondsSinceEpoch.toString(),
            }.toList(),
          });
          setState(() {
            isLoading = false;
          });
          Navigator.pop(context);
        } else {
          throw Exception('not found');
        }
      }
    } catch (e) {
      showToast(
        context,
        AppLocalizations.of(context)!.networkIssue,
        toastLength: Toast.LENGTH_LONG,
      );
    }
    setState(() {
      isLoading = false;
    });
  }

  String? validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'Email is required';
    } else if (!isEmail(value)) {
      return 'Invalid email';
    }
    return null;
  }

  @override
  Widget build(BuildContext context) {
    final vendor = ref.read(vendorProvider)!;
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        leading: BackButton(onPressed: () {
          Navigator.pop(context);
        }),
        title: Text(
          'Add Account',
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
              child: SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    TextFormField(
                      controller: fNameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      forceErrorText:
                          isSubmitted && fNameController.text.isEmpty
                              ? 'First name is required'
                              : null,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                      decoration: inputDecorationWithLabel(
                        'Enter your first name',
                        'First name',
                      ),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: lNameController,
                      keyboardType: TextInputType.name,
                      textInputAction: TextInputAction.next,
                      autocorrect: false,
                      forceErrorText:
                          isSubmitted && lNameController.text.isEmpty
                              ? 'Last name is required'
                              : null,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                      decoration: inputDecorationWithLabel(
                        'Enter your last name',
                        'last name',
                      ),
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        locale.mobileNumber,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    IntlPhoneField(
                      readOnly: isLoading,
                      cursorColor: kSimpleText,
                      controller: phoneController,
                      languageCode: locale.localeName,
                      searchText: locale.searchCountry,
                      invalidNumberMessage: locale.invalidPhoneNumber,
                      validator: (value) {
                        if (isSubmitted) {
                          if (value == null || value.number.isEmpty) {
                            return locale.validphone;
                          } else if (value.number.length < 7) {
                            return locale.validphone;
                          }
                        }
                        return null;
                      },
                      keyboardType: TextInputType.phone,
                      style: Theme.of(context).textTheme.bodySmall!.copyWith(
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
                      initialCountryCode: getCountryCode(vendor.phone),
                      onChanged: (val) {
                        final v = val.completeNumber.replaceAll('+', '');
                        final value = int.tryParse(v) ?? 0;
                        setState(() {
                          phone = value;
                        });
                      },
                    ),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        'Gender',
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: Gender.genders.map((g) {
                        return Row(
                          children: [
                            Radio(
                              value: g.value,
                              groupValue: gender,
                              activeColor: kMainColor,
                              toggleable: isLoading,
                              onChanged: (v) {
                                if (isLoading) return;
                                setState(() {
                                  gender = v!;
                                });
                              },
                            ),
                            Text(
                              g.name,
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontSize: 17,
                                  ),
                            ),
                          ],
                        );
                      }).toList(),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: idNoController,
                      keyboardType: TextInputType.number,
                      maxLength: 20,
                      textInputAction: TextInputAction.next,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                      ],
                      autocorrect: false,
                      forceErrorText: isSubmitted && idNoController.text.isEmpty
                          ? 'Identity number is required'
                          : null,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                      decoration: inputDecorationWithLabel(
                        'Enter your identity number',
                        'identity number',
                      ),
                    ),
                    const SizedBox(height: 20),
                    SizedBox(
                      width: double.infinity,
                      child: Row(
                        children: [
                          datePicker(
                            context,
                            'ID issue date',
                            idIssue,
                            (v) {
                              setState(() {
                                idIssue = v;
                              });
                            },
                          ),
                          const SizedBox(width: 10),
                          datePicker(
                            context,
                            'ID expiry date',
                            idExpiry,
                            (v) {
                              setState(() {
                                idExpiry = v;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    Row(
                      children: [
                        datePicker(
                          context,
                          'Date of birth',
                          birthDate,
                          (v) {
                            setState(() {
                              birthDate = v;
                            });
                          },
                          lastDate: DateTime.now().add(
                            const Duration(days: -365 * 15),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      textInputAction: TextInputAction.done,
                      autocorrect: false,
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Email is required';
                        } else if (!isEmail(value)) {
                          return 'Invalid email';
                        }
                        return null;
                      },
                      forceErrorText: isSubmitted
                          ? validateEmail(emailController.text)
                          : null,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                      decoration: inputDecorationWithLabel(
                        'Enter your email',
                        'Email',
                      ),
                    ),
                    const SizedBox(height: 20),
                    BottomBar(
                      text: 'Create Xpress account',
                      isValid: !isLoading,
                      onTap: () async {
                        handleClick();
                      },
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget datePicker(
    BuildContext context,
    String title,
    DateTime? date,
    Function(DateTime) onChange, {
    DateTime? firstDate,
    DateTime? lastDate,
  }) {
    return Expanded(
      child: TextFormField(
        readOnly: true,
        controller: TextEditingController(
          text: date != null ? localeFormatDate(context, date) : '',
        ),
        onTap: () {
          showDatePicker(
            context: context,
            initialDate: date,
            firstDate: DateTime(1900),
            lastDate: lastDate ??
                DateTime.now().add(
                  const Duration(days: 36500),
                ),
          ).then((value) {
            if (value != null) {
              onChange(value);
            }
          });
        },
        autocorrect: false,
        forceErrorText:
            isSubmitted && date == null ? '$title is required' : null,
        style: Theme.of(context).textTheme.titleSmall!.copyWith(
              fontWeight: FontWeight.w500,
              color: kBlackColor,
            ),
        decoration: inputDecorationWithLabel(
          'Select $title',
          title,
        ),
      ),
    );
  }
}

class Gender {
  Gender({
    required this.name,
    required this.value,
  });

  final String name;
  final String value;

  static List<Gender> genders = [
    Gender(name: 'Male', value: 'M'),
    Gender(name: 'Female', value: 'F'),
  ];
}
