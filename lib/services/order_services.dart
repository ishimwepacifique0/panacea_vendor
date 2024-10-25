import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/models/order.dart';

class OrderServices {
  static final collection = collections.orders;
  static final fireStore = FirebaseFirestore.instance;

  static final ordersStream =
      StreamProvider.family<List<UserOrder>, String>((ref, id) {

    return fireStore
        .collection(collection)
        .where('vendor', isEqualTo: id)
        .snapshots()
        .map(
          (event) => event.docs.map((e) {
            var data = e.data();
            data['id'] = e.id;
            return UserOrder.fromMap(data);
          }).toList(),
        );
  });

  static Future<void> updateOrder(Map<String, dynamic> data, String id) async {
    await fireStore.collection(collection).doc(id).update(data);
  }
}
