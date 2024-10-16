import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/models/profile.dart';

class ProfileServices {
  static final collection = collections.profiles;
  static final fireStore = FirebaseFirestore.instance;

  static final profilesStream = StreamProvider<List<Profile>>((ref) {
    return fireStore.collection(collection).snapshots().map(
          (event) => event.docs.map((e) {
            var data = e.data();
            data['id'] = e.id;
            return Profile.fromJson(data);
          }).toList(),
        );
  });
}
