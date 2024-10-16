import 'dart:async';
import 'dart:convert';

import 'package:animation_wrappers/animations/faded_slide_animation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:icupa_vendor/constants.dart';
import 'package:icupa_vendor/services/location_services.dart';
import 'package:icupa_vendor/shared/shared_states.dart';
import 'package:icupa_vendor/shared/widgets/bottom_bar.dart';
import 'package:icupa_vendor/themes/colors.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:map_autocomplete_field/map_autocomplete_field.dart';

class LocationPage extends ConsumerStatefulWidget {
  final double lat, long;
  const LocationPage({
    super.key,
    required this.lat,
    required this.long,
  });

  @override
  ConsumerState<LocationPage> createState() => _LocationPageState();
}

class _LocationPageState extends ConsumerState<LocationPage> {
  double lat = 0.0, long = 0.0;
  GoogleMapController? mapStyleController;
  String address = '';
  String initialAddress = '';
  TextEditingController searchController = TextEditingController();
  Completer<GoogleMapController> mapController = Completer();
  String selectedAddress = '';
  String? mapStyle;

  late CameraPosition kGooglePlex;

  updateMarkerPin(lat, lng) async {
    final GoogleMapController controller = await mapController.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(CameraPosition(
      target: LatLng(lat, lng),
      zoom: 17,
    )));
  }

  Future<void> handlePosition(CameraPosition pos) async {
    final adv = await LocationService.getAddressFromCoordinates(
      lat,
      long,
    );
    setState(() {
      lat = pos.target.latitude;
      long = pos.target.longitude;
      address = adv;
    });
  }

  @override
  void initState() {
    super.initState();
    final isLocated = widget.lat != 0 && widget.long != 0;
    kGooglePlex = CameraPosition(
      target: LatLng(widget.lat, widget.long),
      zoom: isLocated ? 14.4746 : 2,
    );
    mapStyle = jsonEncode([]);
    lat = widget.lat;
    long = widget.long;
    LocationService.getAddressFromCoordinates(widget.lat, widget.long)
        .then((v) {
      setState(() {
        address = v;
        initialAddress = v;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    final locale = AppLocalizations.of(context)!;
    final isValid = address != initialAddress;
    final user = ref.watch(userProvider)!;
    return GestureDetector(
      onTap: () {
        FocusScope.of(context).unfocus();
      },
      child: Scaffold(
        appBar: PreferredSize(
          preferredSize: const Size.fromHeight(126.0),
          child: AppBar(
            titleSpacing: 0.0,
            title: Text(
              locale.setLocation,
              style: const TextStyle(fontSize: 16.7),
            ),
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(0.0),
              child: Container(
                width: MediaQuery.sizeOf(context).width,
                margin: const EdgeInsets.symmetric(horizontal: 20.0),
                padding:
                    const EdgeInsets.symmetric(vertical: 6.0, horizontal: 24.0),
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(color: Theme.of(context).cardColor),
                  ],
                  borderRadius: BorderRadius.circular(30.0),
                  color: Theme.of(context).cardColor,
                ),
                child: MapAutoCompleteField(
                  locale: user.countryCode,
                  googleMapApiKey: apiKey,
                  controller: searchController,
                  hintStyle: Theme.of(context)
                      .textTheme
                      .titleLarge!
                      .copyWith(color: kHintColor),
                  itemBuilder: (BuildContext context, suggestion) {
                    return Container(
                      color: kLightGreyColor,
                      child: ListTile(
                        leading: Icon(Icons.location_on, color: kTextColor),
                        title: Text(
                          suggestion.description,
                          style:
                              Theme.of(context).textTheme.titleLarge!.copyWith(
                                    color: kTextColor,
                                  ),
                        ),
                      ),
                    );
                  },
                  onSuggestionSelected: (suggestion) async {
                    searchController.value = TextEditingValue(
                      text: suggestion.description,
                    );
                    if (searchController.value.text.isNotEmpty) {
                      final result =
                          await LocationService.getCoordinatesFromAddress(
                        searchController.value.text,
                      );
                      setState(() {
                        lat = result['lat']!;
                        long = result['long']!;
                        address = searchController.value.text;
                      });
                      await updateMarkerPin(lat, long);
                    }
                  },
                  inputDecoration: InputDecoration(
                    fillColor: Theme.of(context).cardColor,
                    contentPadding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 5.0),
                    icon: ImageIcon(const AssetImage('assets/ic_search.png'),
                        color: Theme.of(context).secondaryHeaderColor,
                        size: 16),
                    filled: true,
                    suffixIcon: searchController.value.text.isNotEmpty
                        ? InkWell(
                            onTap: () async {
                              searchController.clear();
                            },
                            child: const Icon(Icons.close),
                          )
                        : const Icon(Icons.close, color: Colors.transparent),
                    hintText: locale.enterLocation,
                    hintStyle: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: kHintColor),
                    labelStyle: Theme.of(context)
                        .textTheme
                        .titleLarge!
                        .copyWith(color: kHintColor),
                    border: InputBorder.none,
                  ),
                ),
              ),
            ),
          ),
        ),
        body: FadedSlideAnimation(
          beginOffset: const Offset(0, 0.3),
          endOffset: const Offset(0, 0),
          slideCurve: Curves.linearToEaseOut,
          child: SingleChildScrollView(
            child: SizedBox(
              height: MediaQuery.of(context).size.height -
                  AppBar().preferredSize.height -
                  MediaQuery.of(context).padding.top -
                  70,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  const SizedBox(height: 8.0),
                  Expanded(
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        GoogleMap(
                          mapType: MapType.normal,
                          initialCameraPosition: kGooglePlex,
                          onMapCreated: onMapCreated,
                          onCameraMove: handlePosition,
                          myLocationButtonEnabled: true,
                          myLocationEnabled: true,
                          onTap: (argument) {
                            FocusScope.of(context).unfocus();
                          },
                        ),
                        Image.asset('assets/map_pin.png', scale: 2.5),
                      ],
                    ),
                  ),
                  Container(
                    color: Theme.of(context).cardColor,
                    padding: const EdgeInsets.symmetric(
                        vertical: 8.0, horizontal: 16.0),
                    child: Row(
                      children: <Widget>[
                        Image.asset('assets/map_pin.png', scale: 2.5),
                        const SizedBox(width: 16.0),
                        Expanded(
                          child: Text(
                            address,
                            overflow: TextOverflow.ellipsis,
                            style: Theme.of(context).textTheme.bodySmall,
                          ),
                        ),
                      ],
                    ),
                  ),
                  BottomBar(
                    text: locale.continueText,
                    isValid: isValid,
                    onTap: () async {
                      if (isValid) {
                        Navigator.pop(context, {
                          'address': address,
                          'lat': lat,
                          'long': long,
                        });
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void onMapCreated(GoogleMapController controller) async {
    setState(() {
      mapController.complete(controller);
      mapStyleController = controller;
      mapStyleController!.setMapStyle(mapStyle);
    });
  }
}
