import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/models/notification.dart';
import 'package:icupa_vendor/services/local_storage.dart';
import 'package:icupa_vendor/shared/shared_states.dart';

class NotificationService {
  static final fireMessage = FirebaseMessaging.instance;
  static final firestore = FirebaseFirestore.instance;
  static final collection = collections.notifications;
  static final notificationsPlugin = FlutterLocalNotificationsPlugin();

  static Future<void> initialize() async {
    await fireMessage.requestPermission();

    FirebaseMessaging.onMessage.listen((RemoteMessage message) {
      showNotification(message);
    });

    // Handle background messages
    FirebaseMessaging.onBackgroundMessage((message) {
      return fireMessageBackgroundHandler(message);
    });

    // initialize notification
    InitializationSettings initializationSettings = InitializationSettings(
      android: const AndroidInitializationSettings('app_icon'),
      iOS: DarwinInitializationSettings(
        requestSoundPermission: true,
        requestBadgePermission: true,
        requestAlertPermission: true,
        onDidReceiveLocalNotification: (id, title, body, payload) async {},
      ),
    );

    notificationsPlugin.initialize(initializationSettings,
        onDidReceiveNotificationResponse:
            (NotificationResponse notificationResponse) {
      dynamic data = jsonDecode(notificationResponse.payload ?? '{}');
      if (data is Map<String, dynamic> && data.containsKey('basket_id')) {
        // final _ = data['basket_id'];
      }
    });
  }

  static Future<void> fireMessageBackgroundHandler(
      RemoteMessage message) async {
    showNotification(message);
  }

  static Future<void> sendNotification(Map<String, dynamic> data) async {
    await firestore.collection(collection).add(data);
  }

  static Future<void> readNotifications(List<String> ids) async {
    for (int i = 0; i < ids.length; i += 20) {
      final lastIndex = i + 20 > ids.length ? ids.length : i + 20;
      final data = ids.sublist(i, lastIndex);
      final batch = firestore.batch();
      for (final id in data) {
        batch.update(firestore.collection(collection).doc(id), {
          'isRead': true,
        });
      }
      await batch.commit();
    }
  }

  static Future<void> deleteAllNotifications(List<UserNotification> ids) async {
    for (int i = 0; i < ids.length; i += 20) {
      final lastIndex = i + 20 > ids.length ? ids.length : i + 20;
      final data = ids.sublist(i, lastIndex);
      final batch = firestore.batch();
      for (final id in data) {
        batch.delete(firestore.collection(collection).doc(id.id));
      }
      await batch.commit();
    }
  }

  static final userNotificationStream =
      StreamProvider<List<UserNotification>>((ref) {
    final userId = ref.read(userProvider)?.id ?? '';
    return firestore
        .collection(collection)
        .where('user_id', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((e) {
        return UserNotification.fromJson(e.data(), e.id);
      }).toList();
    });
  });

  static showNotification(RemoteMessage notification) async {
    final user = await LocalStorage.getUser();
    if (user != null) {
      try {
        final id = DateTime.now().millisecondsSinceEpoch ~/ 1000;
        const NotificationDetails notificationDetails = NotificationDetails(
          android: AndroidNotificationDetails(
            'default_channel_id',
            'Default Channel',
            channelDescription: 'This is the default channel',
            importance: Importance.max,
            priority: Priority.high,
            ticker: 'ticker',
            playSound: true,
            enableLights: true,
            enableVibration: true,
            visibility: NotificationVisibility.public,
          ),
          iOS: DarwinNotificationDetails(
            sound: 'default',
            presentSound: true,
            presentAlert: true,
            presentBadge: true,
          ),
        );

        await notificationsPlugin.show(
          id,
          notification.notification?.title,
          notification.notification?.body,
          notificationDetails,
          payload: jsonEncode(
            notification.data,
          ),
        );
      } on Exception catch (_) {}
    }
  }

  static Future<String?> getToken() async {
    return await fireMessage.getToken();
  }
}
