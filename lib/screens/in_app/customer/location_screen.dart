import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:otonav/utils/dimensions.dart';
import 'package:otonav/widgets/custom_button.dart';
import 'package:otonav/widgets/custom_textfield.dart';

import '../../../utils/app_constants.dart';
import '../../../utils/colors.dart';

class LocationScreen extends StatefulWidget {
  const LocationScreen({super.key});

  @override
  State<LocationScreen> createState() => _LocationScreenState();
}

class _LocationScreenState extends State<LocationScreen> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController locationController = TextEditingController();

  bool isLoadingLocation = false;
  String? selectedName;

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

  GoogleMapController? mapController;
  Set<Marker> markers = {};
  LatLng initialPosition = const LatLng(37.42796133580664, -122.085749655962);

  @override
  void dispose() {
    nameController.dispose();
    locationController.dispose();
    super.dispose();
  }

  void showLocationNameModal() {
    showModalBottomSheet(
      context: context,
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
                style: TextStyle(
                  fontSize: Dimensions.font18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: Dimensions.height10),
              Expanded(
                child: ListView.builder(
                  itemCount: locationTypes.length,
                  itemBuilder: (context, index) {
                    final item = locationTypes[index];
                    return ListTile(
                      leading: Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.primaryColor.withOpacity(0.1),
                          shape: BoxShape.circle,
                        ),
                        child: Icon(
                          item['icon'],
                          color: AppColors.primaryColor,
                        ),
                      ),
                      title: Text(
                        item['name'],
                        style: TextStyle(fontSize: Dimensions.font16),
                      ),
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
    setState(() {
      isLoadingLocation = true;
    });

    try {
      // 1. Check Permissions (same as before)
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) return;
      }

      // 2. Get Position
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng currentLatLng = LatLng(position.latitude, position.longitude);

      // 3. Update Map Camera and Marker
      mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(currentLatLng, 15),
      );

      setState(() {
        markers = {
          Marker(
            markerId: MarkerId('currentLocation'),
            position: currentLatLng,
            infoWindow: InfoWindow(title: 'You are here'),
          ),
        };
      });

      // 4. Get Address Text (Geocoding)
      try {
        List<Placemark> placemarks = await placemarkFromCoordinates(
          position.latitude,
          position.longitude,
        );
        if (placemarks.isNotEmpty) {
          Placemark place = placemarks[0];
          locationController.text =
          "${place.street}, ${place.locality}, ${place.country}";
        }
      } catch (e) {
        locationController.text = "${position.latitude}, ${position.longitude}";
      }

    } catch (e) {
      print(e);
    } finally {
      setState(() {
        isLoadingLocation = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
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
                style: TextStyle(
                  fontSize: Dimensions.font22,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'Save Notable Locations in our database',
                style: TextStyle(
                  fontSize: Dimensions.font15,
                  fontWeight: FontWeight.w400,
                ),
              ),
              SizedBox(height: Dimensions.height20),
              Text(
                'Saved Locations',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              SizedBox(height: Dimensions.height20),
              Row(
                children: [
                  Container(
                    height: Dimensions.height10 * 7,
                    width: Dimensions.width10 * 7,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      shape: BoxShape.circle,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        SizedBox(height: Dimensions.height5),
                        Image.asset(
                          AppConstants.getPngAsset('home-icon'),
                          scale: 2,
                        ),
                        Text(
                          'Home',
                          style: TextStyle(
                            fontWeight: FontWeight.w300,
                            fontSize: Dimensions.font13,
                            color: AppColors.primaryColor,
                          ),
                        ),
                        SizedBox(height: Dimensions.height5),
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(height: Dimensions.height20),
              Text(
                'New Locations',
                style: TextStyle(
                  fontSize: Dimensions.font16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              Text(
                'You have to currently be in the location to save it ',
                style: TextStyle(
                  fontSize: Dimensions.font15,
                  fontWeight: FontWeight.w300,
                  color: AppColors.grey5,
                ),
              ),
              SizedBox(height: Dimensions.height10),
            Container(
              height: 200, // Fixed height for map area
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(Dimensions.radius10),
                border: Border.all(color: AppColors.grey4),
              ),
              child: ClipRRect( // Clips the map corners to match container
                borderRadius: BorderRadius.circular(Dimensions.radius10),
                child: GoogleMap(
                  initialCameraPosition: CameraPosition(
                    target: initialPosition,
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: false,
                  zoomControlsEnabled: false,
                  markers: markers,
                  onMapCreated: (GoogleMapController controller) {
                    mapController = controller;
                    getCurrentLocation();
                  },
                ),
              ),
            ),
              SizedBox(height: Dimensions.height20),

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
                          color: selectedName == null
                              ? AppColors.grey5
                              : Colors.black,
                        ),
                      ),
                      Icon(Icons.arrow_drop_down, color: AppColors.grey5),
                    ],
                  ),
                ),
              ),
              SizedBox(height: Dimensions.height20),
              GestureDetector(
                onTap: getCurrentLocation,
                child: AbsorbPointer(
                  child: CustomTextField(
                    controller: locationController, // Bind controller
                    labelText: isLoadingLocation
                        ? 'Fetching location...'
                        : 'Generate Location',
                    suffixIcon: isLoadingLocation
                        ? Container(
                            padding: EdgeInsets.all(10),
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2),
                          )
                        : Icon(Icons.location_searching),
                  ),
                ),
              ),
              SizedBox(height: Dimensions.height20),
              CustomButton(text: 'Save new Location', onPressed: () {}),
            ],
          ),
        ),
      ),
    );
  }
}
