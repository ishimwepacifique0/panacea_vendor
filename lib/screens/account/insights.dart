import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/themes/colors.dart';

class SalesData {
  SalesData(this.year, this.sales);
  final String year;
  final int sales;
}

class Insights extends StatefulWidget {
  const Insights({super.key});

  @override
  State<Insights> createState() => _InsightsState();
}

class _InsightsState extends State<Insights> {
  bool hasData = false;
  String orderLength = '0';
  int itemSold = 0;
  double earnings = 0;
  final List<int> dynamicSales = [25, 30, 40];
  final List<String> specificYears = [
    '3',
    '6',
    '9',
    '12',
    '15',
    '18',
    '21',
    '24'
  ];

  @override
  void initState() {
    super.initState();
    getDetails();
  }

  getDetails() async {
    orderLength = '0';
    for (int i = 0; i < 0; i++) {
      // itemSold = itemSold + int.parse(commonController.getAllOrders[i].items.length.toString());
      // earnings = earnings + double.parse(commonController.getAllOrders[i].amountPayed.toString());

      // DateTime dateTime = DateTime.fromMillisecondsSinceEpoch(commonController.getAllOrders[i].createdOn!);
      // Convert seconds to hours
      // int hours = dateTime.hour;
      int hours = 3;
      if (hours > 0 || hours <= 3) {
        dynamicSales.add(hours);
      }
      if (hours > 3 || hours <= 6) {
        dynamicSales.add(hours);
      }
      if (hours > 6 || hours <= 9) {
        dynamicSales.add(hours);
      }
      if (hours > 9 || hours <= 12) {
        dynamicSales.add(hours);
      }
      if (hours > 12 || hours <= 15) {
        dynamicSales.add(hours);
      }
      if (hours > 15 || hours <= 18) {
        dynamicSales.add(hours);
      }
      if (hours > 21 || hours <= 24) {
        dynamicSales.add(hours);
      }
    }
    hasData = true;
  }

  // Specific set of years

  // Create a list of SalesData objects for the specific years
  List<SalesData> generateSalesData() {
    List<SalesData> data = [];
    for (int i = 0; i < specificYears.length; i++) {
      int salesValue = i < dynamicSales.length ? dynamicSales[i] : 0;
      data.add(SalesData(specificYears[i], salesValue));
    }
    return data;
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title:
            Text(locale.insight, style: Theme.of(context).textTheme.bodyLarge),
        titleSpacing: 0.0,
        actions: <Widget>[
          Row(
            children: <Widget>[
              Text(
                locale.today.toUpperCase(),
                style: Theme.of(context).textTheme.headlineMedium!.copyWith(
                      fontSize: 15.0,
                      letterSpacing: 1.5,
                      color: kMainColor,
                    ),
              ),
              const SizedBox(width: 30),
            ],
          )
        ],
      ),
      body: FadedSlideAnimation(
        beginOffset: const Offset(0, 0.3),
        endOffset: const Offset(0, 0),
        slideCurve: Curves.linearToEaseOut,
        child: ListView(
          children: <Widget>[
            Divider(
              color: Theme.of(context).cardColor,
              thickness: 8.0,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 40.0, vertical: 10.0),
              child: Row(
                children: <Widget>[
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          orderLength.toString(),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        locale.orders,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w500, color: kTextColor),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          itemSold.toString(),
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        locale.itemSold,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w500, color: kTextColor),
                      ),
                    ],
                  ),
                  const Spacer(),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(bottom: 8.0),
                        child: Text(
                          '\$${earnings.toString()}',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                      ),
                      Text(
                        locale.earnings,
                        style: Theme.of(context).textTheme.titleLarge!.copyWith(
                            fontWeight: FontWeight.w500, color: kTextColor),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Divider(
              color: Theme.of(context).cardColor,
              thickness: 6.7,
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(horizontal: 20.0, vertical: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(locale.earnings.toUpperCase(),
                      style: Theme.of(context)
                          .textTheme
                          .headlineMedium!
                          .copyWith(fontSize: 15.0, letterSpacing: 1.5)),
                  Center(
                    child: Container(),
                  ),
                ],
              ),
            ),
            Divider(
              color: Theme.of(context).cardColor,
              thickness: 6.7,
            ),
          ],
        ),
      ),
    );
  }
}
