import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:icupa_vendor/themes/style.dart';

class BottomBar extends StatelessWidget {
  final Function onTap;
  final String text;
  final Color? color;
  final Color? textColor;
  final bool isValid;

  const BottomBar({
    super.key,
    required this.onTap,
    required this.text,
    this.color,
    this.textColor,
    this.isValid = true,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap as void Function()?,
      child: Container(
        decoration: BoxDecoration(
          color: color ?? kMainColor.withOpacity(isValid ? 1.0 : 0.5),
          borderRadius: const BorderRadius.all(
            Radius.circular(30.0),
          ),
        ),
        margin: const EdgeInsets.symmetric(
          horizontal: 15.0,
          vertical: 20.0,
        ),
        height: 60.0,
        child: Center(
          child: Text(
            text,
            style: textColor != null
                ? bottomBarTextStyle.copyWith(color: textColor)
                : bottomBarTextStyle,
          ),
        ),
      ),
    );
  }
}
