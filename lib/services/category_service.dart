import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/models/category.dart';

class CategoryServices {
  static final collection = collections.categories;
  static final fireStore = FirebaseFirestore.instance;

  static final categoriesStream = StreamProvider<List<Category>>(
    (ref) {
      return fireStore.collection(collection).snapshots().map(
            (event) => event.docs.map((e) {
              var data = e.data();
              data['id'] = e.id;
              return Category.fromJson(data);
            }).toList(),
          );
    },
  );
}
