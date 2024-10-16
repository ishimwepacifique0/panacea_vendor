import 'package:flutter/material.dart';
import 'package:icupa_vendor/themes/colors.dart';

class CustomSearchBar extends StatelessWidget {
  final String? hint;
  final Function? onTap;
  final Color? color;
  final BoxShadow? boxShadow;

  const CustomSearchBar({
    super.key,
    this.hint,
    this.onTap,
    this.color,
    this.boxShadow,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 20.0),
      padding: const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24.0),
      decoration: BoxDecoration(
        boxShadow: [
          boxShadow ?? BoxShadow(color: Theme.of(context).cardColor),
        ],
        borderRadius: BorderRadius.circular(30.0),
        color: color ?? Theme.of(context).cardColor,
      ),
      child: TextField(
        textCapitalization: TextCapitalization.sentences,
        cursorColor: kMainColor,
        readOnly: true,
        decoration: InputDecoration(
          icon: ImageIcon(
            const AssetImage('assets/icons/ic_search.png'),
            color: Theme.of(context).secondaryHeaderColor,
            size: 16,
          ),
          hintText: hint,
          hintStyle: Theme.of(context).textTheme.titleLarge!.copyWith(
                color: kHintColor,
              ),
          border: InputBorder.none,
        ),
        onTap: onTap as void Function()?,
      ),
    );
  }
}
