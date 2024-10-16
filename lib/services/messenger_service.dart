import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:icupa_vendor/models/order.dart';
import 'package:icupa_vendor/services/notification_service.dart';

class MessengerService {
  static Future<void> orderPrepared(
      UserOrder order, BuildContext context) async {
    final locale = AppLocalizations.of(context)!;
    await NotificationService.sendNotification({
      'user_id': order.user,
      'title': locale.orderStatusUpdated,
      'body': locale.orderBeingPrepared(order.orderId),
      'isRead': false,
      'data': {
        'order_id': order.id,
      },
      'createdAt': Timestamp.now(),
    });
  }

  static Future<void> orderRejected(
      UserOrder order, String reason, BuildContext context) async {
    final locale = AppLocalizations.of(context)!;
    await NotificationService.sendNotification({
      'user_id': order.user,
      'title': locale.orderRejected,
      'body': locale.orderRejectedQ(order.orderId, reason),
      'isRead': false,
      'data': {
        'order_id': order.id,
      },
      'createdAt': Timestamp.now(),
    });
  }

  static Future<void> orderServed(UserOrder order, BuildContext context) async {
    final locale = AppLocalizations.of(context)!;
    await NotificationService.sendNotification({
      'user_id': order.user,
      'title': locale.orderStatusUpdated,
      'body': locale.orderServed(order.orderId),
      'isRead': false,
      'data': {
        'order_id': order.id,
      },
      'createdAt': Timestamp.now(),
    });
  }
}
