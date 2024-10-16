import 'package:cloud_firestore/cloud_firestore.dart';

class UserNotification {
  final String id;
  final String userId;
  final String title;
  final String body;
  final bool isRead;
  final dynamic data;
  final DateTime createdAt;

  UserNotification(
    this.id,
    this.userId,
    this.title,
    this.body,
    this.isRead,
    this.data,
    this.createdAt,
  );

  factory UserNotification.fromJson(Map<String, dynamic> json, String id) {
    return UserNotification(
      id,
      json['user_id'],
      json['title'],
      json['body'],
      json['isRead'],
      json['data'],
      json['createdAt'].toDate(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'user_id': userId,
      'title': title,
      'body': body,
      'isRead': isRead,
      'data': data,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }
}
