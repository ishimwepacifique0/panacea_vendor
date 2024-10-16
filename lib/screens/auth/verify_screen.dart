import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/shared/widgets/bottom_bar.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:pinput/pinput.dart';

class VerifyScreen extends ConsumerStatefulWidget {
  final String code;
  final String phone;

  const VerifyScreen({
    super.key,
    required this.code,
    required this.phone,
  });

  @override
  VerifyScreenState createState() => VerifyScreenState();
}

class VerifyScreenState extends ConsumerState<VerifyScreen> {
  bool hasError = false;
  String code = '';

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: true,
        backgroundColor: Colors.transparent,
        elevation: 0.0,
        centerTitle: true,
        title: Text(
          locale.verification,
          style:
              Theme.of(context).textTheme.bodySmall!.copyWith(fontSize: 16.7),
        ),
      ),
      body: FadedSlideAnimation(
        beginOffset: const Offset(0, 0.3),
        endOffset: const Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: GestureDetector(
          onTap: () => FocusScope.of(context).unfocus(),
          behavior: HitTestBehavior.opaque,
          child: Center(
            heightFactor: 1,
            child: Container(
              constraints: const BoxConstraints(
                maxWidth: 600,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Column(
                    children: [
                      Divider(
                        color: Theme.of(context).cardColor,
                        thickness: 8.0,
                      ),
                      Align(
                        alignment: Alignment.centerLeft,
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            locale.enterOtpCode,
                            style: Theme.of(context)
                                .textTheme
                                .titleLarge!
                                .copyWith(
                                  fontSize: 25,
                                  color: Theme.of(context).secondaryHeaderColor,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20.0),
                        child: Text(
                          '${locale.enterVerification} ${widget.phone}',
                          style: Theme.of(context)
                              .textTheme
                              .titleLarge!
                              .copyWith(
                                  fontSize: 17,
                                  color:
                                      Theme.of(context).secondaryHeaderColor),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 20.0, right: 20.0, top: 20.0),
                        child: Pinput(
                          length: 6,
                          inputFormatters: [
                            FilteringTextInputFormatter.digitsOnly,
                          ],
                          defaultPinTheme: PinTheme(
                            height: 56,
                            width: 59,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(
                                color: hasError ? redColor : kMainColor,
                                width: 1,
                              ),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          showCursor: true,
                          pinputAutovalidateMode:
                              PinputAutovalidateMode.onSubmit,
                          autofocus: true,
                          onChanged: (val) {
                            setState(() {
                              code = val;
                              hasError = false;
                            });
                          },
                          textInputAction: TextInputAction.done,
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          pinAnimationType: PinAnimationType.slide,
                        ),
                      ),
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.only(bottom: 40),
                    child: BottomBar(
                      text: AppLocalizations.of(context)!.continueText,
                      isValid: code.length == 6,
                      onTap: () {
                        if (code.length == 6) {
                          if (code == widget.code) {
                            Navigator.pop(context, true);
                          } else {
                            setState(() {
                              hasError = true;
                            });
                          }
                        }
                      },
                    ),
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
