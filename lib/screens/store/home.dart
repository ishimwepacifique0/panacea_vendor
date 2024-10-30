import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/services/notification_service.dart';
import 'package:icupa_vendor/services/order_services.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/shared/widgets/notifications.dart';
import 'package:icupa_vendor/shared/widgets/orders.dart';
import 'package:icupa_vendor/themes/colors.dart';

class Home extends ConsumerWidget {
  const Home({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final scaffoldKey = GlobalKey<ScaffoldState>();
    final locale = AppLocalizations.of(context)!;
    final vendor = ref.watch(vendorProvider)!;
    final ordersStream = ref.watch(OrderServices.ordersStream(vendor.id));
    final notificationsStream = ref.watch(NotificationService.userNotificationStream);

    final orders = ordersStream.value ?? [];

    orders.sort((a, b) => b.date.compareTo(a.date));
    final List<Tab> tabs = <Tab>[
      Tab(text: locale.newOrder),
      Tab(text: locale.pastOrder),
    ];
    final notifications = notificationsStream.value ?? [];
    final isNotified = notifications
        .where((e) {
          return !e.isRead;
        })
        .toList() 
        .isNotEmpty;
    return DefaultTabController(
      length: tabs.length,
      child: Scaffold(
        key: scaffoldKey,
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(100.0),
          child: AppBar(
            centerTitle: true,
            title: Text(
              locale.orderText,
              style: Theme.of(context).textTheme.bodyLarge!.copyWith(
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 10),
                child: Stack(
                  children: [
                    GestureDetector(
                      onTap: () {
                        scaffoldKey.currentState!.openEndDrawer();
                      },
                      child: const Icon(
                        Icons.notifications_none_rounded,
                        size: 30,
                      ),
                    ),
                    if (isNotified)
                      Positioned(
                        top: 8,
                        right: 4,
                        child: Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: kMainColor,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: TabBar(
                tabs: tabs,
                isScrollable: false,
                labelColor: lavenderColor,
                unselectedLabelColor: kLightTextColor,
                indicatorColor: lavenderColor,
              ),
            ),
          ),
        ),
        endDrawer: Notifications(
          onDelete: () async {
            Navigator.pop(context);
            await NotificationService.deleteAllNotifications(notifications);
          },
        ),
        onEndDrawerChanged: (isOpened) async {
          if (!isOpened) {
            final ids = notifications
                .where((e) => !e.isRead)
                .map((item) => item.id)
                .toList();
            await NotificationService.readNotifications(ids);
          }
        },
        body: TabBarView(
          children: [
            Orders(
              orders: (orders).where((e) {
                return !e.served && !e.rejected;
              }).toList(),
            ),
            Orders(
              orders: (orders).where((e) {
                return e.served || e.rejected;
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }
}
