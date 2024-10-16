import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/models/product.dart';

class ProductServices {
  static final collection = collections.products;
  static final vCollection = collections.vendorProducts;
  static final fireStore = FirebaseFirestore.instance;

  static final productsStream = StreamProvider<List<Product>>((ref) {
    return fireStore.collection(collection).snapshots().map(
          (event) => event.docs.map((e) {
            var data = e.data();
            data['id'] = e.id;
            return Product.fromJson(data);
          }).toList(),
        );
  });

  static final vendorsProductsStream =
      StreamProvider<List<VendorProduct>>((ref) {
    return fireStore.collection(vCollection).snapshots().map(
          (event) => event.docs.map((e) {
            var data = e.data();
            data['id'] = e.id;
            return VendorProduct.fromJson(data);
          }).toList(),
        );
  });

  static final storeProductsStream =
      StreamProvider.family<List<VendorProduct>, String>(
    (ref, id) {
      return fireStore
          .collection(vCollection)
          .where('vendor', isEqualTo: id)
          .snapshots()
          .map((event) {
        return event.docs.map((e) {
          var data = e.data();
          data['id'] = e.id;
          return VendorProduct.fromJson(data);
        }).toList();
      });
    },
  );

  static Future<void> addProduct(Map<String, dynamic> data) async {
    await fireStore.collection(vCollection).add(data);
  }

  static Future<void> updateProduct(
      Map<String, dynamic> data, String id) async {
    await fireStore.collection(vCollection).doc(id).update(data);
  }

  static Future<void> deleteProduct(String id) async {
    await fireStore.collection(vCollection).doc(id).delete();
  }
}
