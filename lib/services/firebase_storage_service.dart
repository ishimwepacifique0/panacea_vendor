import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  static Future<String> uploadImage(File image, String folderName) async {
    String downloadURL = '';
    var fileName = image.path.split('/').last;
    // Create a reference to Firebase Storage
    final storageRef = FirebaseStorage.instance.ref();
    // Create a reference to the path you want to upload to
    final imageRef = storageRef.child('$folderName/$fileName');

    try {
      // Upload the file
      await imageRef.putFile(File(image.path));
      // Optionally, you can get the download URL after uploading
      downloadURL = await imageRef.getDownloadURL();
    } on FirebaseException catch (e) {
      // Handle Firebase exceptions
      downloadURL = e.toString();
    } catch (e) {
      // Handle any other exceptions
      downloadURL = e.toString();
    }

    return downloadURL;
  }

  ///
  /// Get list of images urls
  static Future<List<String>> uploadImagesList(
      List<File> images, String folderName) async {
    List<String> imagesUrl = [];
    for (int i = 0; i < images.length; i++) {
      var fileName = images[i].path.split('/').last;

      final reference = firebase_storage.FirebaseStorage.instance
          .ref()
          .child('$folderName/$fileName');
      firebase_storage.UploadTask uploadTask = reference.putFile(images[i]);
      // final StreamSubscription<StorageTaskEvent> streamSubscription =
      uploadTask.snapshotEvents.listen((event) {});
      firebase_storage.TaskSnapshot snapshot =
          await uploadTask.whenComplete(() {});
      final imgUrl = await snapshot.ref.getDownloadURL();
      imagesUrl.add(imgUrl);
    }
    return imagesUrl;
  }
}
