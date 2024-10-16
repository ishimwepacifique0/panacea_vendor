import 'package:flutter/material.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:intl_phone_field/countries.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:intl_phone_field/phone_number.dart';

class PhoneNumberInput extends StatelessWidget {
  final String? label;
  final String? initialCountryCode;
  final void Function(PhoneNumber)? onChange;
  final void Function(Country)? onCountryChange;
  final TextEditingController? controller;
  const PhoneNumberInput({
    super.key,
    this.label,
    this.initialCountryCode,
    this.onChange,
    this.controller,
    this.onCountryChange,
  });

  @override
  Widget build(BuildContext context) {
    return IntlPhoneField(
      cursorColor: kSimpleText,
      controller: controller,
      keyboardType: TextInputType.phone,
      // ignore: deprecated_member_use
      searchText: 'Whatsapp number',
      style: Theme.of(context).textTheme.bodySmall,
      invalidNumberMessage: 'Invalid Number',
      decoration: InputDecoration(
        fillColor: kPrimary,
        labelText: label,
        hoverColor: kOrange,
        hintStyle: Theme.of(context).textTheme.bodySmall,
        labelStyle: Theme.of(context).textTheme.bodySmall,
        border: const OutlineInputBorder(
          borderSide: BorderSide(
            color: kOrange,
          ),
          borderRadius: BorderRadius.all(Radius.circular(24)),
        ),
        focusColor: kOrange,
        focusedBorder: OutlineInputBorder(
          borderSide: BorderSide(
            color: kMainColor,
          ),
          borderRadius: const BorderRadius.all(Radius.circular(24)),
        ),
        errorBorder: const OutlineInputBorder(
          borderSide: BorderSide(
            color: kRed,
          ),
        ),
      ),
      initialCountryCode: initialCountryCode,
      onChanged: onChange,
      onCountryChanged: onCountryChange,
    );
  }
}

const Color kPrimary = Color(0xFFFFFFFF);
const Color kTextColor = Color(0xff2D2D2D);
const Color kSimpleText = Color(0xff797373);
const Color kBlue = Color(0xff38ADB5);
const Color kOrange = Color(0xffFF8A35);
const Color kRed = Color(0xFFFF3535);
const Color kViolet = Color(0xff7a6efe);
const Color kGreen = Color(0xff09ca6e);
const Color kBlack = Color(0xFF000000);
const Color kTransparent = Colors.transparent;
