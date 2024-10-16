import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/models/message.dart';

class MessageServices {
  static final collection = collections.messages;
  static final fireStore = FirebaseFirestore.instance;

  static final orderMessagesStream =
      StreamProvider.family<List<Message>, String>((ref, order) {
    return fireStore
        .collection(collection)
        .where('order', isEqualTo: order)
        .orderBy('time', descending: true)
        .snapshots()
        .map(
          (event) => event.docs.map((e) {
            var data = e.data();
            data['id'] = e.id;
            return Message.fromJson(data);
          }).toList(),
        );
  });

  static Future<void> sendMessage(Map<String, dynamic> data) async {
    await fireStore.collection(collection).add(data);
  }
}
