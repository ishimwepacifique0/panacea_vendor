import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/models/review.dart';
import 'package:icupa_vendor/shared/shared_states.dart';

class ReviewServices {
  static final collection = collections.reviews;
  static final fireStore = FirebaseFirestore.instance;

  static final reviewsStream = StreamProvider<List<Review>>((ref) {
    final vendor = ref.read(vendorProvider)!;
    return fireStore
        .collection(collection)
        .where('vendor', isEqualTo: vendor.id)
        .snapshots()
        .map(
          (event) => event.docs.map((e) {
            var data = e.data();
            data['id'] = e.id;
            return Review.fromJson(data);
          }).toList(),
        );
  });
}
