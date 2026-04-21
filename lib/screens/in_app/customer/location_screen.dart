import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:latlong2/latlong.dart';
import 'package:otonav/controllers/auth_controller.dart';
import 'package:otonav/controllers/user_controller.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';
import 'package:otonav/widgets/custom_textfield.dart';

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
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  UserController userController = Get.find<UserController>();
  AuthController authController = Get.find<AuthController>();
  final OSMHelper _osmHelper = OSMHelper();
  final MapController _mapController = MapController();

  bool isLoadingLocation = false;
  String? selectedName;
  LatLng? _currentPosition; // latlong2 LatLng

  // Default start position (e.g., Lagos)
  final LatLng _initialPosition = const LatLng(6.5244, 3.3792);

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
    // Optional: Get location immediately on load
    WidgetsBinding.instance.addPostFrameCallback((_) {
      getCurrentLocation();
    });
  }

  @override
  void dispose() {
    nameController.dispose();
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

  void showLocationNameModal() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.symmetric(vertical: Dimensions.height20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                "Choose a Label",
                style: TextStyle(fontSize: Dimensions.font18, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: Dimensions.height10),
              Expanded(
                child: ListView.builder(
                  itemCount: locationTypes.length,
                  itemBuilder: (context, index) {
                    final item = locationTypes[index];
                    return ListTile(
                      leading: Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(item['icon'], color: AppColors.primaryColor),
                      ),
                      title: Text(item['name'], style: TextStyle(fontSize: Dimensions.font16)),
                      onTap: () {
                        setState(() {
                          selectedName = item['name'];
                        });
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
      // 1. Check Permissions
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() => isLoadingLocation = false);
          return;
        }
      }

      // 2. Force High Precision GPS Lock
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.best,
        forceAndroidLocationManager: true,
        timeLimit: const Duration(seconds: 10),
      );

      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      setState(() {
        _currentPosition = currentLatLng;
      });

      // 3. Move Leaflet Map
      _mapController.move(currentLatLng, 17.0);

      // 4. Reverse Geocode (Get Address Text)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );

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
        print("Geocoding Error: $e");
        locationController.text = "${position.latitude}, ${position.longitude}";
      }

    } catch (e) {
      print("Error getting location: $e");
      CustomSnackBar.failure(message: "GPS signal weak. Step outside or try again.");
    } finally {
      if (mounted) {
        setState(() => isLoadingLocation = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        if (userController.userModel.value == null) {
          return Center(child: Padding(
            padding: EdgeInsets.symmetric(horizontal: Dimensions.width20),
            child: LinearProgressIndicator(color: AppColors.accentColor),
          ));
        }
        User user = userController.userModel.value!;

        return Container(
          padding: EdgeInsets.fromLTRB(
            Dimensions.width20,
            Dimensions.height100,
            Dimensions.width20,
            Dimensions.height20,
          ),
          child: SingleChildScrollView(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Add New Locations',
                  style: TextStyle(fontSize: Dimensions.font22, fontWeight: FontWeight.w500),
                ),
                Text(
                  'Save Notable Locations in our database',
                  style: TextStyle(fontSize: Dimensions.font15, fontWeight: FontWeight.w400),
                ),
                SizedBox(height: Dimensions.height20),

                // --- Saved Locations List ---
                Text('Saved Locations', style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w500)),
                SizedBox(height: Dimensions.height20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    if (user.locations != null)
                      ...user.locations!.map((location) {
                        return Padding(
                          padding: EdgeInsets.only(right: Dimensions.width20),
                          child: Container(
                            height: Dimensions.height10 * 8,
                            width: Dimensions.width10 * 8,
                            decoration: BoxDecoration(
                              color: AppColors.white,
                              shape: BoxShape.circle,
                              boxShadow: [
                                BoxShadow(color: Colors.grey.withOpacity(0.1), blurRadius: 5, offset: const Offset(0, 2)),
                              ],
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.spaceAround,
                              children: [
                                SizedBox(height: Dimensions.height5),
                                Icon(
                                  _getLocationIcon(location.label ?? ""),
                                  color: AppColors.primaryColor,
                                  size: Dimensions.iconSize24,
                                ),
                                Text(
                                  location.label ?? 'Loc',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w300,
                                    fontSize: Dimensions.font13,
                                    color: AppColors.primaryColor,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                                SizedBox(height: Dimensions.height5),
                              ],
                            ),
                          ),
                        );
                      }).toList(),
                  ],
                ),

                SizedBox(height: Dimensions.height20),
                Text('New Locations', style: TextStyle(fontSize: Dimensions.font16, fontWeight: FontWeight.w500)),
                Text(
                  'You have to currently be in the location to save it',
                  style: TextStyle(fontSize: Dimensions.font15, fontWeight: FontWeight.w300, color: AppColors.grey5),
                ),
                SizedBox(height: Dimensions.height10),

                // --- FLUTTER MAP (LEAFLET) ---
                Container(
                  height: 200,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                    border: Border.all(color: AppColors.grey4),
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                    child: FlutterMap(
                      mapController: _mapController,
                      options: MapOptions(
                        initialCenter: _initialPosition,
                        initialZoom: 14.0,
                      ),
                      children: [
                        TileLayer(
                          urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                          userAgentPackageName: 'com.otonav.app',
                        ),
                        if (_currentPosition != null)
                          MarkerLayer(
                            markers: [
                              Marker(
                                point: _currentPosition!,
                                width: 40,
                                height: 40,
                                child: const Icon(
                                    Icons.location_on,
                                    color: Colors.red,
                                    size: 40
                                ),
                              ),
                            ],
                          ),
                      ],
                    ),
                  ),
                ),

                SizedBox(height: Dimensions.height20),

                // --- Location Label Picker ---
                InkWell(
                  onTap: showLocationNameModal,
                  child: Container(
                    padding: EdgeInsets.symmetric(
                      horizontal: Dimensions.width20,
                      vertical: Dimensions.height15,
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(Dimensions.radius10),
                      color: AppColors.cardColor,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          selectedName ?? 'What will this place be called?',
                          style: TextStyle(
                            fontSize: Dimensions.font15,
                            color: selectedName == null ? AppColors.grey5 : Colors.black,
                          ),
                        ),
                        Icon(Icons.arrow_drop_down, color: AppColors.grey5),
                      ],
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                // --- GPS Accuracy Notice ---
                Container(
                  padding: EdgeInsets.all(Dimensions.height10),
                  decoration: BoxDecoration(
                    color: Colors.blue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(Dimensions.radius10),
                    border: Border.all(color: Colors.blue.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info_outline, color: Colors.blue[700], size: Dimensions.iconSize20),
                      SizedBox(width: Dimensions.width10),
                      Expanded(
                        child: Text(
                          "Tip: For the most precise GPS accuracy, please step outside before generating your location.",
                          style: TextStyle(
                            fontSize: Dimensions.font13,
                            color: Colors.blue[800],
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: Dimensions.height15),

                // --- Location Address Input (Read Only / Generated) ---
                GestureDetector(
                  onTap: getCurrentLocation,
                  child: AbsorbPointer(
                    child: CustomTextField(
                      controller: locationController,
                      labelText: isLoadingLocation ? 'Fetching location...' : 'Generate Location',
                      suffixIcon: isLoadingLocation
                          ? Container(
                        padding: const EdgeInsets.all(10),
                        height: 20, width: 20,
                        child: const CircularProgressIndicator(strokeWidth: 2),
                      )
                          : const Icon(Icons.location_searching),
                    ),
                  ),
                ),
                SizedBox(height: Dimensions.height20),

                // --- Save Button ---
                CustomButton(
                  text: 'Save new Location',
                  onPressed: () {
                    String address = locationController.text.trim();
                    if (selectedName == null) {
                      CustomSnackBar.failure(message: "Please choose a label (e.g., Home, Office)");
                      return;
                    }
                    if (address.isEmpty) {
                      CustomSnackBar.failure(message: "Please generate a location first");
                      return;
                    }
                    authController.addNewLocation(selectedName!, address);
                  },
                ),
                SizedBox(height: Dimensions.height20),
              ],
            ),
          ),
        );
      }),
    );
  }
}
