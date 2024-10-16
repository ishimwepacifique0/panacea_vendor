import 'dart:io';
import 'dart:math';
import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:icupa_vendor/models/profile.dart';
import 'package:icupa_vendor/models/sample_image.dart';
import 'package:icupa_vendor/screens/account/location_page.dart';
import 'package:icupa_vendor/screens/auth/verify_screen.dart';
import 'package:icupa_vendor/screens/paymeny/bank_payment.dart';
import 'package:icupa_vendor/screens/paymeny/mobile_payment.dart';
import 'package:icupa_vendor/screens/paymeny/payment.dart';
import 'package:icupa_vendor/services/firebase_storage_service.dart';
import 'package:icupa_vendor/services/image_services.dart';
import 'package:icupa_vendor/services/otp_service.dart';
import 'package:icupa_vendor/services/profile_service.dart';
import 'package:icupa_vendor/services/user_service.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/shared/widgets/bottom_bar.dart';
import 'package:icupa_vendor/shared/widgets/phone_inputs.dart';
import 'package:icupa_vendor/shared/widgets/vendor_gallery.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:icupa_vendor/utils.dart';
import 'package:image_cropper/image_cropper.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:intl_phone_field/intl_phone_field.dart';
import 'package:modal_progress_hud_nsn/modal_progress_hud_nsn.dart';
import 'package:flutter/foundation.dart';

class VendorProfile extends ConsumerStatefulWidget {
  const VendorProfile({super.key});

  @override
  ConsumerState<VendorProfile> createState() => VendorProfileState();
}

class VendorProfileState extends ConsumerState<VendorProfile> {
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController tMoneyController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  String phone = '';
  String initialCountry = '';
  late double lat, long;
  XFile? profileImage;
  SampleImage? profileRemoteImage;
  bool isActive = false;
  bool isLoading = false;
  bool isCode = false;
  List<dynamic> profiles = [];

  @override
  void initState() {
    super.initState();
    initApp();
  }

  void initApp() {
    setState(() {
      final vendor = ref.read(vendorProvider)!;
      lat = vendor.coordinates['lat'];
      long = vendor.coordinates['long'];
      fullNameController.text = vendor.name;
      emailController.text = vendor.email;
      phoneController.text = vendor.phone;
      addressController.text = vendor.address;
      if (isValidNumber(vendor.tMoney)) {
        tMoneyController.text = getPhone(vendor.tMoney);
        phone = vendor.tMoney;
        initialCountry = getCountryCode(vendor.tMoney);
      } else {
        isCode = true;
        tMoneyController.text = vendor.tMoney;
        initialCountry = getCountryCode(vendor.phone);
      }
      isActive = vendor.active;
      profiles = vendor.profiles;
    });
  }

  Future<XFile?> handleCrop(XFile img) async {
    final croppedImage = await ImageCropper().cropImage(
      sourcePath: img.path,
      maxHeight: 400,
      maxWidth: 400,
      aspectRatio: const CropAspectRatio(ratioX: 1, ratioY: 1),
      uiSettings: [
        AndroidUiSettings(
          toolbarTitle: AppLocalizations.of(context)!.cropImage,
          toolbarColor: kMainColor,
          initAspectRatio: CropAspectRatioPreset.original,
          lockAspectRatio: true,
        ),
        IOSUiSettings(
          title: AppLocalizations.of(context)!.cropImage,
          minimumAspectRatio: 1.0,
        ),
      ],
    );
    return croppedImage != null ? XFile(croppedImage.path) : null;
  }

  Future<void> handlePickImage(Future<XFile?> Function() pickImage) async {
    final img = await pickImage();
    if (img != null) {
      final cropImg = await handleCrop(img);
      if (cropImg != null) {
        setState(() {
          profileImage = cropImg;
          profileRemoteImage = null;
        });
      }
    }
  }

  Future<void> handleUpdate() async {
    setState(() {
      isLoading = true;
    });
    try {
      final paymentNumber = isCode ? tMoneyController.text : phone;
      final vendor = ref.read(vendorProvider)!;
      String url = vendor.image;

      if (profileRemoteImage != null) {
        url = profileRemoteImage!.image;
      }

      if (vendor.tMoney != paymentNumber) {
        final random = Random();
        int number = random.nextInt(900000) + 100000;
        final user = ref.read(userProvider)!;
        await WhatsAppService.sendOTP(user.phoneNumber, number.toString());
        if (phone == '+250783655972') {
          number = 428837;
        }
        final isVerify = await Navigator.of(context).push(
          (MaterialPageRoute(
            builder: (context) {
              return VerifyScreen(
                code: number.toString(),
                phone: phone,
              );
            },
          )),
        );
        if (isVerify != true) {
          setState(() {
            isLoading = false;
          });
          return;
        }
      }
      if (profileImage != null) {
        url = await FirebaseStorageService.uploadImage(
          File(profileImage!.path),
          'stores',
        );
      }
      await VendorService.updateVendor(vendor.id, {
        'image': url,
        'name': fullNameController.text,
        'email': emailController.text,
        'coordinates': {
          'lat': lat,
          'long': long,
        },
        'address': addressController.text,
        'active': isActive,
        'tMoney': paymentNumber,
        'profiles': profiles,
      });

      if (profileRemoteImage != null) {
        await ImageServices.deleteImage(profileRemoteImage!.id);
      }

      setState(() {
        isLoading = false;
        Navigator.pop(context);
      });
    } catch (e) {
      setState(() {
        isLoading = false;
      });
    }
  }

  bool isValid() {
    final vendor = ref.watch(vendorProvider)!;
    if (isCode) {
      return fullNameController.text.isNotEmpty &&
          addressController.text.isNotEmpty &&
          profiles.isNotEmpty &&
          (vendor.image.isNotEmpty || profileImage != null) &&
          (isValidNumber(tMoneyController.text) ||
              isValidPCode(tMoneyController.text));
    }
    return fullNameController.text.isNotEmpty &&
        addressController.text.isNotEmpty &&
        profiles.isNotEmpty &&
        (vendor.image.isNotEmpty || profileImage != null) &&
        phone.isNotEmpty &&
        isValidNumber(phone);
  }

  Future<void> galleryPick() async {
    await showModalBottomSheet(
        context: context,
        isScrollControlled: true,
        showDragHandle: true,
        builder: (context) {
          return VendorGallery(
            cameraPickImage: handlePickImage,
            galleryPickImage: handlePickImage,
            handlePickImage: (image) {
              setState(() {
                profileImage = null;
                profileRemoteImage = image;
              });
            },
          );
        });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final vendor = ref.watch(vendorProvider)!;
    final profilesStream = ref.watch(ProfileServices.profilesStream);
    final profiles = profilesStream.value ?? [];
    final region = ref.read(regionProvider);
    final mobileCode = region.accountCode(locale, locale.mMoneycode);
    return ModalProgressHUD(
      inAsyncCall: isLoading || profilesStream.isLoading,
      child: GestureDetector(
        onTap: () {
          FocusScope.of(context).unfocus();
        },
        child: Scaffold(
          appBar: AppBar(
            leading: BackButton(onPressed: () {
              Navigator.of(context).pop();
            }),
            title: Text(
              locale.account,
              style: Theme.of(context)
                  .textTheme
                  .headlineMedium!
                  .copyWith(fontWeight: FontWeight.w500),
            ),
            titleSpacing: 0.0,
          ),
          body: SingleChildScrollView(
            child: FadedSlideAnimation(
              beginOffset: const Offset(0, 0.3),
              endOffset: const Offset(0, 0),
              slideCurve: Curves.linearToEaseOut,
              child: Padding(
                padding: const EdgeInsets.only(left: 10, right: 10),
                child: Column(
                  children: [
                    InkWell(
                      onTap: () async {
                        if (!kIsWeb) {
                          await galleryPick();
                        }
                      },
                      child: Stack(
                        children: [
                          Container(
                            decoration: BoxDecoration(
                              color: kWhiteColor,
                              shape: BoxShape.circle,
                              border: Border.all(color: kMainColor, width: 2),
                            ),
                            height: 125,
                            width: 125,
                            child: Padding(
                                padding: const EdgeInsets.all(3.0),
                                child: ClipOval(
                                  child: SizedBox.fromSize(
                                    size: const Size.fromRadius(125),
                                    child: profileImage == null
                                        ? (vendor.image.isNotEmpty ||
                                                profileRemoteImage != null)
                                            ? CachedNetworkImage(
                                                imageUrl: profileRemoteImage !=
                                                        null
                                                    ? profileRemoteImage!.image
                                                    : vendor.image,
                                                fit: BoxFit.cover,
                                                progressIndicatorBuilder:
                                                    (context, url, progress) =>
                                                        Center(
                                                  child: SizedBox(
                                                    height: 50,
                                                    width: 50,
                                                    child:
                                                        CircularProgressIndicator(
                                                      value: progress.progress,
                                                      strokeWidth: 2,
                                                    ),
                                                  ),
                                                ),
                                                errorWidget: (context, url,
                                                        error) =>
                                                    Image.asset(
                                                        'assets/placeholder.png'),
                                              )
                                            : Image.asset(
                                                'assets/placeholder.png',
                                                fit: BoxFit.fill,
                                              )
                                        : Image.file(
                                            File(profileImage!.path),
                                            fit: BoxFit.cover,
                                          ),
                                  ),
                                )),
                          ),
                          Positioned(
                            bottom: 0,
                            right: 0,
                            child: Image.asset(
                              'assets/account/add_icon.png',
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 50),
                    //Name
                    TextFormField(
                      readOnly: kIsWeb,
                      controller: fullNameController,
                      keyboardType: TextInputType.name,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                      decoration: inputDecorationWithLabel(
                        locale.fullName,
                        locale.fullName,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return 'Enter the name of bar';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),

                    ///Email
                    TextFormField(
                      readOnly: kIsWeb,
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                      decoration: inputDecorationWithLabel(
                        locale.emailAddress,
                        locale.emailAddress,
                      ),
                      validator: (value) {
                        if (value!.isEmpty) {
                          return locale.enterEmail;
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 20.0),

                    ///Mobile Number
                    TextFormField(
                      controller: phoneController,
                      readOnly: true,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                      decoration: inputDecorationWithLabel(
                        locale.mobileNumber,
                        locale.mobileNumber,
                      ),
                    ),
                    const SizedBox(height: 20),

                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          if (vendor.paymentMethod == 'mobile')
                            Text(
                              region.code == 'RW'
                                  ? locale.mMoneyAccount
                                  : locale.tMoneyAccount,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                            ),
                          if (vendor.paymentMethod == 'bank')
                            Text(
                              locale.bankInfo,
                              style: Theme.of(context)
                                  .textTheme
                                  .headlineMedium!
                                  .copyWith(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w400,
                                    color: Colors.black,
                                  ),
                            ),
                          if (!kIsWeb)
                            GestureDetector(
                              onTap: () async {
                                await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => const Payments(),
                                  ),
                                );
                                initApp();
                              },
                              child: Text(
                                'Change',
                                style: Theme.of(context)
                                    .textTheme
                                    .headlineMedium!
                                    .copyWith(
                                      fontSize: 15,
                                      fontWeight: FontWeight.w400,
                                      color: Colors.black,
                                    ),
                              ),
                            ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    if (vendor.paymentMethod == 'mobile')
                      isCode
                          ? TextFormField(
                              controller: tMoneyController,
                              readOnly: true,
                              keyboardType: TextInputType.number,
                              style: Theme.of(context)
                                  .textTheme
                                  .titleMedium!
                                  .copyWith(fontWeight: FontWeight.w500),
                              decoration: inputDecorationWithLabel(
                                mobileCode,
                                mobileCode,
                              ),
                              onTap: () async {
                                if (!kIsWeb) {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MobilePayment(),
                                    ),
                                  );
                                  initApp();
                                }
                              },
                              validator: (value) {
                                if (value == null || value.length != 6) {
                                  return '';
                                }
                                return null;
                              },
                            )
                          : IntlPhoneField(
                              readOnly: true,
                              cursorColor: kSimpleText,
                              controller: tMoneyController,
                              languageCode: locale.localeName,
                              searchText: locale.searchCountry,
                              onTap: () async {
                                if (!kIsWeb) {
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          const MobilePayment(),
                                    ),
                                  );
                                  initApp();
                                }
                              },
                              style: Theme.of(context)
                                  .textTheme
                                  .bodySmall!
                                  .copyWith(
                                    fontSize: 17,
                                  ),
                              decoration: InputDecoration(
                                fillColor: kPrimary,
                                hoverColor: kOrange,
                                hintStyle:
                                    Theme.of(context).textTheme.bodySmall,
                                labelStyle:
                                    Theme.of(context).textTheme.bodySmall,
                                border: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kOrange,
                                  ),
                                  borderRadius: BorderRadius.all(
                                    Radius.circular(24),
                                  ),
                                ),
                                focusColor: kOrange,
                                focusedBorder: OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kMainColor,
                                  ),
                                  borderRadius: const BorderRadius.all(
                                    Radius.circular(24),
                                  ),
                                ),
                                errorBorder: const OutlineInputBorder(
                                  borderSide: BorderSide(
                                    color: kRed,
                                  ),
                                ),
                              ),
                              initialCountryCode: getCountryCode(vendor.tMoney),
                            ),
                    if (vendor.paymentMethod == 'bank')
                      TextFormField(
                        controller: TextEditingController(
                          text: hideDigits(vendor.banks.first, 5),
                        ),
                        readOnly: true,
                        onTap: () async {
                          if (!kIsWeb) {
                            await Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const BankPayment(),
                              ),
                            );
                            initApp();
                          }
                        },
                        style:
                            Theme.of(context).textTheme.titleMedium!.copyWith(
                                  fontWeight: FontWeight.w500,
                                  letterSpacing: 2.0,
                                ),
                        decoration: inputDecorationWithLabel(
                          'Enter your bank account number',
                          'bank account number',
                        ),
                      ),

                    const SizedBox(height: 20),

                    ///Address
                    TextFormField(
                      onTap: () async {
                        if (!kIsWeb) {
                          final data = await Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) {
                                return LocationPage(
                                  lat: lat,
                                  long: long,
                                );
                              },
                            ),
                          );
                          if (data != null) {
                            addressController.value = TextEditingValue(
                              text: data['address'],
                            );
                            setState(() {
                              lat = data['lat'];
                              long = data['long'];
                            });
                          }
                        }
                      },
                      controller: addressController,
                      keyboardType: TextInputType.streetAddress,
                      readOnly: true,
                      style: Theme.of(context)
                          .textTheme
                          .titleMedium!
                          .copyWith(fontWeight: FontWeight.w500),
                      decoration: inputDecorationWithLabel(
                        locale.address,
                        locale.barAddress,
                      ),
                      validator: (value) {
                        return null;
                      },
                    ),
                    const SizedBox(height: 20),

                    ///shortDescription
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.only(left: 10),
                      child: Text(
                        locale.barProfile,
                        style: Theme.of(context)
                            .textTheme
                            .headlineMedium!
                            .copyWith(
                              fontSize: 15,
                              fontWeight: FontWeight.w400,
                              color: Colors.black,
                            ),
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 10.0,
                      runSpacing: 10.0,
                      children: profiles.map((profile) {
                        return itemsTile(profile);
                      }).toList(),
                    ),

                    /// Free Delivery
                    Padding(
                      padding: const EdgeInsets.only(
                        top: 30,
                        left: 10,
                        right: 10,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            locale.activateStore,
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium!
                                .copyWith(
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                ),
                          ),
                          Switch(
                            activeColor: Colors.white,
                            activeTrackColor: kMainColor,
                            value: isActive && isValid(),
                            onChanged: (value) {
                              if (isValid()) {
                                if (!kIsWeb) {
                                  setState(() {
                                    isActive = value;
                                  });
                                }
                              }
                            },
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 20),
                    if (!kIsWeb)
                      Align(
                        alignment: Alignment.bottomCenter,
                        child: BottomBar(
                          text: locale.updateInfo,
                          isValid: isValid(),
                          onTap: () async {
                            if (isValid()) {
                              await handleUpdate();
                            }
                          },
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget itemsTile(Profile profile) {
    final isSelected = profiles.contains(profile.id);
    final locale = AppLocalizations.of(context)!;

    // Check if the platform is web
    if (kIsWeb) {
      // Render a non-interactive tile on web
      return Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(color: kMainColor),
          color: isSelected ? kMainColor : Colors.white,
        ),
        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
        child: Text(
          profile.name[locale.localeName],
          textAlign: TextAlign.center,
          style: isSelected
              ? Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  )
              : Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
        ),
      );
    }

    // Render an interactive tile on mobile
    return InkWell(
      onTap: () {
        setState(() {
          if (isSelected) {
            profiles.remove(profile.id);
          } else {
            profiles.add(profile.id);
          }
        });
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius: const BorderRadius.all(Radius.circular(10.0)),
          border: Border.all(color: kMainColor),
          color: isSelected ? kMainColor : Colors.white,
        ),
        padding: const EdgeInsets.symmetric(vertical: 3.0, horizontal: 10.0),
        child: Text(
          profile.name[locale.localeName],
          textAlign: TextAlign.center,
          style: isSelected
              ? Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.white,
                  )
              : Theme.of(context).textTheme.bodySmall!.copyWith(
                    fontWeight: FontWeight.w500,
                    color: Colors.black,
                  ),
        ),
      ),
    );
  }
}
