import 'package:animation_wrappers/animations/faded_scale_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/screens/account/privacy_policy.dart';
import 'package:icupa_vendor/screens/account/reviews.dart';
import 'package:icupa_vendor/screens/account/terms_and_condition.dart';
import 'package:icupa_vendor/screens/account/vendor_profile.dart';
import 'package:icupa_vendor/screens/auth/welcome_screen.dart';
import 'package:icupa_vendor/services/local_storage.dart';
import 'package:icupa_vendor/services/user_service.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/shared/widgets/list_tile.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:icupa_vendor/utils.dart';
import 'package:url_launcher/url_launcher.dart';

class Account extends ConsumerWidget {
  const Account({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocalizations.of(context)!;
    final vendor = ref.watch(vendorProvider)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(
          locale.account,
          style: Theme.of(context).textTheme.bodyLarge,
        ),
        centerTitle: true,
      ),
      body: ListView(
        children: <Widget>[
          InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const VendorProfile();
                  },
                ),
              );
            },
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                children: <Widget>[
                  FadedScaleAnimation(
                    child: SizedBox(
                      height: 98,
                      width: 98,
                      child: ClipRRect(
                        borderRadius:
                            const BorderRadius.all(Radius.circular(5.0)),
                        child: vendor.image.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: vendor.image,
                                fit: BoxFit.cover,
                                alignment: Alignment.topCenter,
                                progressIndicatorBuilder:
                                    (context, url, downloadProgress) {
                                  return Center(
                                    child: SizedBox(
                                      height: 40,
                                      width: 40,
                                      child: CircularProgressIndicator(
                                        value: downloadProgress.progress,
                                        strokeWidth: 2,
                                      ),
                                    ),
                                  );
                                },
                                errorWidget: (context, url, error) =>
                                    Image.asset('assets/placeholder.png'),
                              )
                            : Image.asset('assets/placeholder.png'),
                      ),
                    ),
                  ),
                  const SizedBox(width: 16.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Text(
                        vendor.name.isNotEmpty ? vendor.name : 'add Store name',
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                              fontSize: 15.0,
                              fontWeight: FontWeight.w500,
                            ),
                      ),
                      const SizedBox(height: 8.0),
                      Row(
                        children: <Widget>[
                          Icon(
                            Icons.location_on,
                            color: kLightTextColor,
                            size: 9.0,
                          ),
                          const SizedBox(width: 5.0),
                          SizedBox(
                            width: 200,
                            child: Text(
                              vendor.address.isNotEmpty
                                  ? vendor.address
                                  : 'add Store address',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleSmall!
                                  .copyWith(
                                    color: const Color(0xff4a4b48),
                                    fontSize: 13.3,
                                  ),
                            ),
                          ),
                        ],
                      ),
                      Text(
                        locale.storeProfile,
                        style: const TextStyle(
                          color: lavenderColor,
                          fontSize: 13.3,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          Divider(
            color: Theme.of(context).cardColor,
            thickness: 8.0,
          ),
          BuildListTile(
            image: 'assets/account/ic_menu_reviewact.png',
            text: locale.review,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) {
                    return const Reviews();
                  },
                ),
              );
            },
          ),
          BuildListTile(
            image: 'assets/account/ic_menu_tncact.png',
            text: locale.pnp,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => PrivacyPolicy(
                    title: locale.pnp,
                  ),
                ),
              );
            },
          ),
          BuildListTile(
            image: 'assets/account/ic_menu_tncact.png',
            text: locale.tnc,
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TermsCondition(
                    title: locale.tnc,
                  ),
                ),
              );
            },
          ),
          BuildListTile(
            image: 'assets/account/ic_menu_setting.png',
            text: locale.selectLanguage,
            onTap: () async {
              showLanguageSelectionDialog(context, ref);
            },
          ),
          BuildListTile(
            image: 'assets/account/ic_menu_supportact.png',
            text: locale.support,
            onTap: () async {
              String url = 'whatsapp://send?phone=+35677186193/';
              if (await canLaunchUrl(Uri.parse(url))) {
                await launchUrl(
                  Uri.parse(url),
                  mode: LaunchMode.externalApplication,
                );
              }
            },
          ),
          BuildListTile(
            image: 'assets/account/ic_menu_logoutact.png',
            text: locale.logout,
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(locale.loggingOut),
                      content: Text(locale.areYouSure),
                      actions: <Widget>[
                        MaterialButton(
                          textColor: kMainColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: kTransparentColor),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(locale.no),
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: kTransparentColor),
                          ),
                          textColor: kMainColor,
                          onPressed: () async {
                            Navigator.pop(context);
                            await LocalStorage.removeUserLocation();
                            await LocalStorage.removeUser().then(
                              (v) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const WelcomeScreen();
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(locale.yes),
                        ),
                      ],
                    );
                  });
            },
          ),
          const SizedBox(height: 40.0),
          GestureDetector(
            onTap: () {
              showDialog(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return AlertDialog(
                      title: Text(locale.closeQ),
                      content: Text(locale.closeP),
                      actions: <Widget>[
                        MaterialButton(
                          textColor: kMainColor,
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: kTransparentColor),
                          ),
                          onPressed: () => Navigator.pop(context),
                          child: Text(locale.no),
                        ),
                        MaterialButton(
                          shape: RoundedRectangleBorder(
                            side: BorderSide(color: kTransparentColor),
                          ),
                          textColor: kMainColor,
                          onPressed: () async {
                            Navigator.pop(context);
                            VendorService.updateVendor(vendor.id, {
                              'active': false,
                            });
                            UserService.deleteUser(vendor.phone);
                            await LocalStorage.removeUser().then(
                              (v) {
                                Navigator.pushReplacement(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) {
                                      return const WelcomeScreen();
                                    },
                                  ),
                                );
                              },
                            );
                          },
                          child: Text(locale.yes),
                        ),
                      ],
                    );
                  });
            },
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: <Widget>[
                Icon(
                  Icons.cancel,
                  color: redColor,
                  size: 13,
                ),
                const SizedBox(width: 5),
                Text(
                  locale.closeA,
                  style: Theme.of(context).textTheme.bodySmall!.copyWith(
                        color: redColor,
                        fontSize: 13,
                      ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10.0),
        ],
      ),
    );
  }
}
