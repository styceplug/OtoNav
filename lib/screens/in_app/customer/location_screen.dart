import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:iconsax/iconsax.dart';
import 'package:latlong2/latlong.dart';
import 'package:otonav/controllers/auth_controller.dart';
import 'package:otonav/controllers/user_controller.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';
import 'package:otonav/widgets/custom_textfield.dart';
import 'package:skeletonizer/skeletonizer.dart';

import '../../../helpers/route_helper.dart';
import '../../../model/user_model.dart';
import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';
import '../../../widgets/snackbars.dart';



class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController locationController = TextEditingController();

  UserController userController = Get.find<UserController>();
  AuthController authController = Get.find<AuthController>();
  final OSMHelper _osmHelper = OSMHelper();
  final MapController _mapController = MapController();

  bool isLoadingLocation = false;
  String? selectedName;
  LatLng? _currentPosition;

  final LatLng _initialPosition = const LatLng(6.5244, 3.3792);

  final User _dummyUser = User(
      locations: [
        LocationModel(label: "Home", preciseLocation: "Loading saved address..."),
        LocationModel(label: "Office", preciseLocation: "Loading saved address..."),
      ]
  );

  final List<Map<String, dynamic>> locationTypes = [
    {'name': 'Home', 'icon': Icons.home_rounded},
    {'name': 'Office', 'icon': Icons.work_rounded},
    {'name': 'Partner\'s Place', 'icon': Icons.favorite_rounded},
    {'name': 'Parents\' House', 'icon': Icons.family_restroom_rounded},
    {'name': 'Gym', 'icon': Icons.fitness_center_rounded},
    {'name': 'Church', 'icon': Icons.church_rounded},
    {'name': 'School', 'icon': Icons.school_rounded},
    {'name': 'Market', 'icon': Icons.shopping_cart_rounded},
    {'name': 'Chill Spot', 'icon': Icons.local_cafe_rounded},
  ];

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentLocation();
    });
  }

  @override
  void dispose() {
    locationController.dispose();
    super.dispose();
  }

  IconData _getLocationIcon(String label) {
    var match = locationTypes.firstWhere(
          (element) => element['name'].toString().toLowerCase() == label.toLowerCase(),
      orElse: () => {'icon': Icons.location_on_rounded},
    );
    return match['icon'] as IconData;
  }

  void _showDeleteConfirmation(String label) {
    Get.bottomSheet(
      Container(
        padding: EdgeInsets.all(Dimensions.width20),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radius20)),
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 40, height: 5,
              decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)),
            ),
            SizedBox(height: Dimensions.height20),
            Container(
              padding: const EdgeInsets.all(15),
              decoration: BoxDecoration(color: Colors.redAccent.withOpacity(0.1), shape: BoxShape.circle),
              child: const Icon(Iconsax.trash, color: Colors.redAccent, size: 35),
            ),
            SizedBox(height: Dimensions.height15),
            Text("Delete '$label'?", style: TextStyle(fontSize: Dimensions.font20, fontWeight: FontWeight.bold)),
            SizedBox(height: Dimensions.height10),
            Text("This action is permanent and cannot be undone.", style: TextStyle(color: AppColors.grey5, fontSize: Dimensions.font14)),
            SizedBox(height: Dimensions.height30),
            Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () => Get.back(),
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(Dimensions.radius10),
                        border: Border.all(color: Colors.grey[300]!),
                      ),
                      child: Center(child: Text("Cancel", style: TextStyle(fontSize: Dimensions.font15, fontWeight: FontWeight.w500))),
                    ),
                  ),
                ),
                SizedBox(width: Dimensions.width15),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      Get.back(); // Close bottom sheet
                      authController.deleteSavedLocation(label); // Trigger deletion
                    },
                    child: Container(
                      padding: EdgeInsets.symmetric(vertical: Dimensions.height15),
                      decoration: BoxDecoration(
                        color: Colors.redAccent,
                        borderRadius: BorderRadius.circular(Dimensions.radius10),
                      ),
                      child: Center(child: Text("Yes, Delete", style: TextStyle(color: Colors.white, fontSize: Dimensions.font15, fontWeight: FontWeight.bold))),
                    ),
                  ),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  void showLocationNameModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Center(child: Container(width: 40, height: 5, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(10)))),
              SizedBox(height: Dimensions.height20),
              Text("Choose a Label", style: TextStyle(fontSize: Dimensions.font18, fontWeight: FontWeight.bold)),
              SizedBox(height: Dimensions.height15),
              Expanded(
                child: ListView.builder(
                  physics: const BouncingScrollPhysics(),
                  itemCount: locationTypes.length,
                  itemBuilder: (context, index) {
                    final item = locationTypes[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(color: AppColors.primaryColor.withOpacity(0.1), shape: BoxShape.circle),
                        child: Icon(item['icon'], color: AppColors.primaryColor, size: 20),
                      ),
                      title: Text(item['name'], style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w500)),
                      onTap: () {
                        setState(() => selectedName = item['name']);
                        Navigator.pop(context);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> getCurrentLocation() async {
    setState(() => isLoadingLocation = true);

    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => isLoadingLocation = false);
          return;
        }
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds: 10),
      );

      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() => _currentPosition = currentLatLng);

      _mapController.move(currentLatLng, 17.0);

      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          List<String> addressParts = [];
          if (place.street != null && place.street!.isNotEmpty) addressParts.add(place.street!);
          if (place.subLocality != null && place.subLocality!.isNotEmpty) addressParts.add(place.subLocality!);
          if (place.locality != null && place.locality!.isNotEmpty) addressParts.add(place.locality!);
          if (place.administrativeArea != null && place.administrativeArea!.isNotEmpty) addressParts.add(place.administrativeArea!);
          locationController.text = addressParts.join(", ");
        } else {
          locationController.text = "${position.latitude}, ${position.longitude}";
        }
      } catch (e) {
        locationController.text = "${position.latitude}, ${position.longitude}";
      }
    } catch (e) {
      CustomSnackBar.failure(message: "GPS signal weak. Step outside or try again.");
    } finally {
      if (mounted) setState(() => isLoadingLocation = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundColor,
      body: Obx(() {
        final bool isUserLoading = userController.userModel.value == null;
        final User user = isUserLoading ? _dummyUser : userController.userModel.value!;

        return Skeletonizer(
          enabled: isUserLoading,
          child: Container(
            padding: EdgeInsets.fromLTRB(
              Dimensions.width20,
              Dimensions.height100-Dimensions.height20,
              Dimensions.width20,
              Dimensions.height20,
            ),
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- HEADER ---
                  Row(
                    children: [
                      InkWell(
                        onTap: () => Get.back(),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: const BoxDecoration(color: Colors.white, shape: BoxShape.circle, boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 5)]),
                          child: const Icon(Icons.arrow_back, color: Colors.black),
                        ),
                      ),
                      SizedBox(width: Dimensions.width15),
                      Text('Manage Locations', style: TextStyle(fontSize: Dimensions.font22, fontWeight: FontWeight.bold)),
                    ],
                  ),
                  SizedBox(height: Dimensions.height30),

                  // --- SAVED LOCATIONS HORIZONTAL LIST ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Saved Locations', style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w600)),
                      Text('Long-press to delete', style: TextStyle(fontSize: 12, color: AppColors.grey5, fontStyle: FontStyle.italic)),
                    ],
                  ),
                  SizedBox(height: Dimensions.height15),

                  if (user.locations == null || user.locations!.isEmpty)
                    Container(
                      width: double.infinity,
                      padding: EdgeInsets.all(Dimensions.height20),
                      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(15), border: Border.all(color: Colors.grey.withOpacity(0.2))),
                      child: const Center(child: Text("No saved locations yet.", style: TextStyle(color: Colors.grey))),
                    )
                  else
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      physics: const BouncingScrollPhysics(),
                      child: Row(
                        children: user.locations!.map((location) {
                          return InkWell(
                            // ✅ LONG PRESS TO DELETE
                            onLongPress: () {
                              if (!isUserLoading && location.label != null) {
                                _showDeleteConfirmation(location.label!);
                              }
                            },
                            child: Container(
                              height: 100,
                              width: 110,
                              margin: EdgeInsets.only(right: Dimensions.width15),
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(Dimensions.radius15),
                                border: Border.all(color: Colors.grey.withOpacity(0.15)),
                                boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))],
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Icon(_getLocationIcon(location.label ?? ""), color: AppColors.accentColor, size: 24),
                                  const Spacer(),
                                  Text(
                                    location.label ?? 'Location',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  SizedBox(height: Dimensions.height5),
                                  Text(
                                    location.preciseLocation ?? '',
                                    style: const TextStyle(fontSize: 10, color: Colors.grey),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),

                  SizedBox(height: Dimensions.height30),

                  // --- ADD NEW LOCATION CARD ---
                  Text('Add New Location', style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w600)),
                  Text('You must be physically at the location to save it accurately.', style: TextStyle(fontSize: 13, color: AppColors.grey5)),
                  SizedBox(height: Dimensions.height15),

                  Container(
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(Dimensions.radius20),
                      boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 5))],
                    ),
                    child: Column(
                      children: [
                        // 1. FLUTTER MAP
                        SizedBox(
                          height: 180,
                          width: double.infinity,
                          child: ClipRRect(
                            borderRadius: BorderRadius.vertical(top: Radius.circular(Dimensions.radius20)),
                            child: Stack(
                              children: [
                                FlutterMap(
                                  mapController: _mapController,
                                  options: MapOptions(initialCenter: _initialPosition, initialZoom: 15.0),
                                  children: [
                                    TileLayer(urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png', userAgentPackageName: 'com.otonav.app'),
                                    if (_currentPosition != null)
                                      MarkerLayer(
                                        markers: [
                                          Marker(
                                            point: _currentPosition!,
                                            width: 40, height: 40,
                                            child: const Icon(Icons.location_on, color: Colors.redAccent, size: 40),
                                          ),
                                        ],
                                      ),
                                  ],
                                ),
                                Positioned(
                                  bottom: 10, right: 10,
                                  child: FloatingActionButton.small(
                                    heroTag: "locate_me_btn",
                                    backgroundColor: Colors.white,
                                    onPressed: getCurrentLocation,
                                    child: isLoadingLocation
                                        ? const Padding(padding: EdgeInsets.all(8.0), child: CircularProgressIndicator(strokeWidth: 2))
                                        : const Icon(Icons.my_location, color: AppColors.primaryColor),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),

                        Padding(
                          padding: EdgeInsets.all(Dimensions.width20),
                          child: Column(
                            children: [
                              Container(
                                padding: EdgeInsets.all(Dimensions.height10),
                                decoration: BoxDecoration(color: Colors.blue.withOpacity(0.08), borderRadius: BorderRadius.circular(Dimensions.radius10), border: Border.all(color: Colors.blue.withOpacity(0.2))),
                                child: Row(
                                  children: [
                                    Icon(Iconsax.info_circle, color: Colors.blue[700], size: 18),
                                    SizedBox(width: Dimensions.width10),
                                    Expanded(child: Text("Tip: Step outside for 10 seconds before generating to ensure maximum GPS precision.", style: TextStyle(fontSize: 12, color: Colors.blue[800], fontWeight: FontWeight.w500))),
                                  ],
                                ),
                              ),
                              SizedBox(height: Dimensions.height20),

                              InkWell(
                                onTap: showLocationNameModal,
                                child: Container(
                                  padding: EdgeInsets.symmetric(horizontal: Dimensions.width20, vertical: Dimensions.height15),
                                  decoration: BoxDecoration(borderRadius: BorderRadius.circular(Dimensions.radius10), color: AppColors.backgroundColor, border: Border.all(color: Colors.grey.withOpacity(0.2))),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(selectedName ?? 'Select a label (e.g. Home, Office)', style: TextStyle(fontSize: 14, color: selectedName == null ? AppColors.grey5 : Colors.black, fontWeight: selectedName == null ? FontWeight.normal : FontWeight.w500)),
                                      Icon(Icons.keyboard_arrow_down_rounded, color: AppColors.grey5),
                                    ],
                                  ),
                                ),
                              ),
                              SizedBox(height: Dimensions.height15),

                              GestureDetector(
                                onTap: getCurrentLocation,
                                child: AbsorbPointer(
                                  child: CustomTextField(controller: locationController, labelText: isLoadingLocation ? 'Acquiring satellites...' : 'Generated Address', suffixIcon: const Icon(Iconsax.location)),
                                ),
                              ),
                              SizedBox(height: Dimensions.height24),

                              CustomButton(
                                text: 'Save Location',
                                onPressed: () {
                                  String address = locationController.text.trim();
                                  if (selectedName == null) {
                                    CustomSnackBar.failure(message: "Please choose a label");
                                    return;
                                  }
                                  if (address.isEmpty || isLoadingLocation) {
                                    CustomSnackBar.failure(message: "Please generate a valid location first");
                                    return;
                                  }
                                  authController.addNewLocation(selectedName!, address);
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: Dimensions.height40),
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
