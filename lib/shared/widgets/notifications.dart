import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/services/notification_service.dart';
import 'package:icupa_vendor/shared/widgets/bottom_bar.dart';
import 'package:icupa_vendor/shared/widgets/phone_inputs.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:icupa_vendor/utils.dart';

class Notifications extends ConsumerWidget {
  final void Function() onDelete;
  const Notifications({super.key, required this.onDelete});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = AppLocalizations.of(context)!;
    final notificationsStream =
        ref.watch(NotificationService.userNotificationStream);
    final notifications = notificationsStream.value ?? [];
    notifications.sort((a, b) => b.createdAt.compareTo(a.createdAt));
    return Container(
      width: MediaQuery.of(context).size.width * 0.9,
      padding: const EdgeInsets.symmetric(horizontal: 20),
      color: Theme.of(context).scaffoldBackgroundColor,
      child: SafeArea(
        child: Column(
          children: [
            Text(
              locale.notifications,
              style: Theme.of(context).textTheme.bodyLarge,
            ),
            const SizedBox(height: 20),
            Expanded(
              child: notifications.isNotEmpty
                  ? ListView.separated(
                      itemCount: notifications.length,
                      itemBuilder: (context, index) {
                        final notification = notifications[index];
                        final isRead = notification.isRead;
                        return GestureDetector(
                          onTap: () {
                            try {
                              if ((notification.data as Map)
                                  .keys
                                  .contains('order_id')) {
                                Navigator.pop(context);
                              }
                            } catch (_) {}
                          },
                          child: Container(
                            padding: const EdgeInsets.all(10),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              color: kBlack.withOpacity(isRead ? 0.03 : 0.1),
                            ),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Container(
                                      margin: const EdgeInsets.only(right: 10),
                                      padding:
                                          const EdgeInsetsDirectional.all(10),
                                      decoration: BoxDecoration(
                                        color: kMainColor.withOpacity(0.1),
                                        borderRadius:
                                            BorderRadiusDirectional.circular(
                                                20),
                                      ),
                                      child: Icon(
                                        Icons.notifications,
                                        color: kMainColor,
                                      ),
                                    ),
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          notification.title,
                                          style: Theme.of(context)
                                              .textTheme
                                              .titleSmall!
                                              .copyWith(
                                                color: kBlack,
                                              ),
                                        ),
                                        Text(
                                          '${formatDate(
                                            context,
                                            notification.createdAt,
                                          )} | ${formatTime(
                                            context,
                                            notification.createdAt,
                                          )}',
                                          style: Theme.of(context)
                                              .textTheme
                                              .bodySmall,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 10),
                                Text(
                                  notification.body,
                                  style: Theme.of(context).textTheme.bodySmall,
                                )
                              ],
                            ),
                          ),
                        );
                      },
                      separatorBuilder: (context, index) {
                        return Container(
                          margin: const EdgeInsets.symmetric(vertical: 15),
                          width: double.infinity,
                          height: 2,
                          color: Theme.of(context).cardColor,
                        );
                      },
                    )
                  : Center(
                      child: Text(
                        locale.noNotification,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ),
            ),
            if (notifications.isNotEmpty)
              BottomBar(
                onTap: onDelete,
                text: locale.clearAll,
              ),
          ],
        ),
      ),
    );
  }
}
