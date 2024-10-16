import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/screens/account/account.dart';
import 'package:icupa_vendor/screens/store/home.dart';
import 'package:icupa_vendor/screens/store/products.dart';
import 'package:icupa_vendor/services/user_service.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/shared/widgets/animated_bottom_bar.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class AppScreen extends ConsumerStatefulWidget {
  const AppScreen({
    super.key,
  });

  @override
  ConsumerState<AppScreen> createState() => AppScreenState();
}

class AppScreenState extends ConsumerState<AppScreen> {
  int currentIndex = 0;
  @override
  Widget build(BuildContext context) {
    var locale = AppLocalizations.of(context)!;
    final user = ref.watch(userProvider)!;
    final vendor = ref.watch(vendorProvider)!;
    ref.watch(UserService.userStream(user.phoneNumber));
    ref.watch(VendorService.vendorStream(vendor.id));
    final List<BarItem> barItems = [
      BarItem(locale.orderText, bottomHome),
      BarItem(locale.product, bottomProducts),
      BarItem(locale.account, bottomAccount),
    ];
    final List<Widget> children = [
      const Home(),
      Products(),
      const Account(),
    ];
    return Scaffold(
      body: children[currentIndex],
      bottomNavigationBar: AnimatedBottomBar(
        barItems: barItems,
        onBarTap: (index) {
          setState(() {
            currentIndex = index;
          });
        },
      ),
    );
  }
}
