import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/models/vendor.dart';

class VendorServices {
  static final collection = collections.vendors;
  static final fireStore = FirebaseFirestore.instance;

  static final vendorsStream = StreamProvider<List<Vendor>>(
    (ref) {
      return fireStore
          .collection(collection)
          .where('active', isEqualTo: true)
          .snapshots()
          .map((event) {
        return event.docs.map((e) {
          var data = e.data();
          data['id'] = e.id;
          return Vendor.fromJson(data);
        }).toList();
      });
    },
  );
}
