import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/models/region.dart';
import 'package:icupa_vendor/models/user.dart';
import 'package:icupa_vendor/models/vendor.dart';
import 'package:icupa_vendor/services/local_storage.dart';
import 'package:icupa_vendor/shared/shared_states.dart';

class UserService {
  static String collection = collections.users;
  static String appCollection = collections.application;
  static String regionCollection = collections.regions;
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static Future<User?> getUser(String phone) async {
    var user = await fireStore.collection(collection).doc(phone).get();
    if (user.exists) {
      final data = user.data()!;
      data['id'] = user.id;
      return User.fromJSON(data);
    }
    return null;
  }

  static Future<User?> addUser(Map<String, dynamic> data) async {
    String phone = data['phoneNumber'];
    await fireStore.collection(collection).doc(phone.toString()).set(data);
    final snapshot = await fireStore.collection(collection).doc(phone).get();
    if (snapshot.exists) {
      final data = snapshot.data()!;
      data['id'] = snapshot.id;
      return User.fromJSON(data);
    }
    return null;
  }

  static Future<void> updateUser(
      String phone, Map<String, dynamic> data) async {
    await fireStore.collection(collection).doc(phone).update(data);
  }

  static final usersStream = StreamProvider<List<User>>((ref) {
    return fireStore.collection(collection).snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return User.fromJSON(data);
      }).toList();
    });
  });

  static final userStream = StreamProvider.family<void, String>((ref, phone) {
    return fireStore
        .collection(collection)
        .doc(phone)
        .snapshots()
        .map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        data['id'] = snapshot.id;
        final u = User.fromJSON(data);
        ref.read(userProvider.notifier).state = u;
        LocalStorage.setUser(u);
      }
    });
  });

  static Future<void> deleteUser(String id) async {
    await fireStore.collection(collection).doc(id).delete();
  }

  static Future<String> getToken() async {
    final snapshot =
        await fireStore.collection(appCollection).doc('environments').get();
    if (snapshot.exists) {
      return snapshot.data()!['token'];
    }
    return '';
  }

  static Future<void> unregisterForNotifications(User user) async {
    final token = await getToken();
    final data = user.tokens;
    data.remove(token);
    final ref = fireStore.collection(collection).doc();
    await ref.update({
      'tokens': data,
    });
  }

  static Future<Region?> getRegion(String code) async {
    final snapshot = await fireStore
        .collection(regionCollection)
        .where('code', isEqualTo: code)
        .get();

    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      return Region.fromJSON(data);
    }
    return null;
  }
}

class VendorService {
  static String collection = collections.vendors;
  static String appCollection = collections.application;
  static FirebaseFirestore fireStore = FirebaseFirestore.instance;

  static Future<Vendor?> getVendor(String phone) async {
    final vendor = await fireStore
        .collection(collection)
        .where('phone', isEqualTo: phone)
        .get();
    if (vendor.docs.isNotEmpty) {
      final data = vendor.docs.first.data();
      data['id'] = vendor.docs.first.id;
      return Vendor.fromJson(data);
    }
    return null;
  }

  static Future<Vendor?> addVendor(Map<String, dynamic> data) async {
    final phone = data['phone'];
    await fireStore.collection(collection).add(data);
    final snapshot = await fireStore
        .collection(collection)
        .where('phone', isEqualTo: phone)
        .get();
    if (snapshot.docs.isNotEmpty) {
      final data = snapshot.docs.first.data();
      data['id'] = snapshot.docs.first.id;
      return Vendor.fromJson(data);
    }
    return null;
  }

  static Future<void> updateVendor(String id, Map<String, dynamic> data) async {
    await fireStore.collection(collection).doc(id).update(data);
  }

  static final vendorStream = StreamProvider.family<void, String>((ref, id) {
    return fireStore.collection(collection).doc(id).snapshots().map((snapshot) {
      if (snapshot.exists) {
        final data = snapshot.data()!;
        data['id'] = snapshot.id;
        final v = Vendor.fromJson(data);
        ref.read(vendorProvider.notifier).state = v;
      }
    });
  });
}
