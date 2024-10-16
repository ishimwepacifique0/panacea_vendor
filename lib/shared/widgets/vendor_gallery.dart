import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/models/sample_image.dart';
import 'package:icupa_vendor/services/file_picker_services.dart';
import 'package:icupa_vendor/services/image_services.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:image_picker/image_picker.dart';

class VendorGallery extends ConsumerWidget {
  final Function(Future<XFile?> Function()) cameraPickImage;
  final Function(Future<XFile?> Function()) galleryPickImage;
  final void Function(SampleImage) handlePickImage;
  const VendorGallery({
    super.key,
    required this.cameraPickImage,
    required this.galleryPickImage,
    required this.handlePickImage,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final imagesStream = ref.watch(ImageServices.imagesStream);
    final images = imagesStream.value ?? [];
    return SafeArea(
      child: Container(
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        child: ListView(
          shrinkWrap: true,
          padding: const EdgeInsets.all(20),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    cameraPickImage(
                      FilePickerService.captureImageWithCamera,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: kMainColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.camera_alt_outlined,
                          color: kWhiteColor,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Camera',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                    galleryPickImage(
                      FilePickerService.pickImageWithCompression,
                    );
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 20,
                    ),
                    decoration: BoxDecoration(
                      color: kMainColor,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.photo_library_outlined,
                          color: kWhiteColor,
                        ),
                        const SizedBox(width: 10),
                        const Text(
                          'Gallery',
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (imagesStream.isLoading)
              Center(
                child: SizedBox(
                  height: 30,
                  width: 30,
                  child: CircularProgressIndicator(
                    valueColor: AlwaysStoppedAnimation<Color>(kMainColor),
                    strokeWidth: 2,
                  ),
                ),
              ),
            if (images.isNotEmpty)
              GridView.count(
                crossAxisCount: 2,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(10),
                childAspectRatio: 1,
                children: images.map((image) {
                  return InkWell(
                    onTap: () async {
                      Navigator.pop(context);
                      handlePickImage(image);
                    },
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        vertical: 10,
                        horizontal: 10,
                      ),
                      child: CachedNetworkImage(
                        imageUrl: image.image,
                        fit: BoxFit.cover,
                        progressIndicatorBuilder: (context, url, progress) =>
                            Center(
                          child: SizedBox(
                            height: 50,
                            width: 50,
                            child: CircularProgressIndicator(
                              value: progress.progress,
                              strokeWidth: 2,
                            ),
                          ),
                        ),
                      ),
                    ),
                  );
                }).toList(),
              ),
          ],
        ),
      ),
    );
  }
}
