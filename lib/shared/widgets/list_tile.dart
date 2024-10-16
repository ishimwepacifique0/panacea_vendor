import 'package:animation_wrappers/Animations/faded_scale_animation.dart';
import 'package:flutter/material.dart';

class BuildListTile extends StatelessWidget {
  final String image;
  final String text;
  final Function? onTap;

  const BuildListTile({super.key, 
    required this.image,
    required this.text,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return ListTile(
      contentPadding: const EdgeInsets.symmetric(vertical: 4.0, horizontal: 20.0),
      leading: FadedScaleAnimation(
        child: Image.asset(image, height: 25.3),
      ),
      title: Text(
        text,
        style: Theme.of(context).textTheme.headlineMedium!.copyWith(
              fontWeight: FontWeight.w500,
              letterSpacing: 0.07,
            ),
      ),
      onTap: onTap as void Function()?,
    );
  }
}
