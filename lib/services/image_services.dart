import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/models/sample_image.dart';

class ImageServices {
  static final String collection = collections.imageSamples;
  static final fireStore = FirebaseFirestore.instance;

  static final imagesStream = StreamProvider<List<SampleImage>>((ref) {
    return fireStore.collection(collection).snapshots().map((e) {
      return e.docs.map((e) {
        var data = e.data();
        data['id'] = e.id;
        return SampleImage.fromJson(data);
      }).toList();
    });
  });

  static Future<void> deleteImage(String id) async {
    await fireStore.collection(collection).doc(id).delete();
  }
}
