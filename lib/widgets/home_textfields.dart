import 'package:flutter/material.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:google_maps_webservice_ex/places.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class HomeTextFeilds extends StatefulWidget {
  final int? currentIndex;
  final PageController pageController;
  final TextEditingController pickupController;
  final TextEditingController destinationController;
  final TextEditingController receiversNameController;
  final TextEditingController receiversNumberController;
  
  const HomeTextFeilds(
      {super.key,
      this.currentIndex,
      required this.pageController,
      required this.pickupController,
      required this.destinationController,
      required this.receiversNameController,
      required this.receiversNumberController});

  @override
  State<HomeTextFeilds> createState() => _HomeTextFeildsState();
}

class _HomeTextFeildsState extends State<HomeTextFeilds> {
  TextEditingController pickupController1 = TextEditingController();
  TextEditingController destinationController1 = TextEditingController();
  TextEditingController receiversNameController1 = TextEditingController();
  TextEditingController receiversNumberController1 = TextEditingController();
  TextEditingController pickupController2 = TextEditingController();
  TextEditingController destinationController2 = TextEditingController();
  TextEditingController receiversNameController2 = TextEditingController();
  TextEditingController receiversNumberController2 = TextEditingController();
  TextEditingController pickupController3 = TextEditingController();
  TextEditingController destinationController3 = TextEditingController();
  TextEditingController receiversNameController3 = TextEditingController();
  TextEditingController receiversNumberController3 = TextEditingController();
  TextEditingController pickupController4 = TextEditingController();
  TextEditingController destinationController4 = TextEditingController();
  TextEditingController receiversNameController4 = TextEditingController();
  TextEditingController receiversNumberController4 = TextEditingController();
  TextEditingController pickupController5 = TextEditingController();
  TextEditingController destinationController5 = TextEditingController();
  TextEditingController receiversNameController5 = TextEditingController();
  TextEditingController receiversNumberController5 = TextEditingController();
  final GlobalKey<FormState> homeNewFormKey = GlobalKey<FormState>();
  List<TextEditingController> pickupControllers = [];
  List<TextEditingController> destinationControllers = [];
  List<TextEditingController> receiversNameControllers = [];
  List<TextEditingController> receiversNumberControllers = [];

//   List<TextEditingController> pickupControllers = List.generate(5, (index) => TextEditingController());
// List<TextEditingController> destinationControllers = List.generate(5, (index) => TextEditingController());
// List<TextEditingController> receiversNameControllers = List.generate(5, (index) => TextEditingController());
// List<TextEditingController> receiversNumberControllers = List.generate(5, (index) => TextEditingController());

  late TextEditingController selectedPickupController =
      pickupControllers[widget.currentIndex!];
  late TextEditingController selectedDestinationController =
      destinationControllers[widget.currentIndex!];
  late TextEditingController selectedReceiversNameController =
      receiversNameControllers[widget.currentIndex!];
  late TextEditingController selectedReceiversNumberController =
      receiversNumberControllers[widget.currentIndex!];

  String? pickupLat;
  String? pickupLng;
  String? currentLat;
  String? currentLng;
  String? destinationLat;
  String? destinationLng;

  List<PlacesSearchResult> pickUpPredictions = [];
  List<PlacesSearchResult> destinationPredictions = [];
  final places =
      GoogleMapsPlaces(apiKey: 'AIzaSyAk-CA4yYf-txNZvvwmCshykjpLiASEkcw');
  GoogleMapController? mapController;
  MarkerId? selectedMarker;
  LatLng? selectedLocation;
  LatLng? currentLocation;
  BitmapDescriptor? customMarkerIcon;

  Future<void> searchPickUpPlaces(String input) async {
    if (input.isNotEmpty) {
      final response = await places.searchByText(input);

      if (response.isOkay) {
        setState(() {
          pickUpPredictions = response.results;
        });
      }
    }
  }

  Future<void> searchDestinationPlaces(String input) async {
    if (input.isNotEmpty) {
      final response = await places.searchByText(input);

      if (response.isOkay) {
        setState(() {
          destinationPredictions = response.results;
        });
      }
    }
  }

  String currentAddress = "";
  Future<void> getCurrentLocation() async {
    final Position position = await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.best,
    );

    final List<Placemark> placemarks =
        await placemarkFromCoordinates(position.latitude, position.longitude);

    if (placemarks.isNotEmpty) {
      final Placemark currentPlace = placemarks.first;
      currentAddress =
          "${currentPlace.name}, ${currentPlace.locality}, ${currentPlace.country}";

      setState(() {
        currentLocation = LatLng(position.latitude, position.longitude);
        selectedLocation = null; // Clear selected location
        selectedMarker = const MarkerId('currentLocation');
        // (widget.currentIndex == 0)
        //     ? pickupController1.text
        //     : (widget.currentIndex == 1)
        //         ? pickupController2.text
        //         : (widget.currentIndex == 2)
        //             ? pickupController3.text
        //             : (widget.currentIndex == 3)
        //                 ? pickupController4.text
        //                 : pickupController5.text = currentAddress;
        currentLat = position.latitude.toString();
        currentLng = position.longitude.toString();
        print("currentLat: $currentLat");
        print("currentLng: $currentLng");
        print("currentpickupLocation: $currentAddress");
      });

      mapController
          ?.animateCamera(CameraUpdate.newLatLngZoom(currentLocation!, 15));
    }
  }

  void onPickUpLocationSelected(LatLng location, double zoomLevel) {
    setState(() {
      selectedLocation = location;
      currentLocation = null; // Clear current location
      selectedMarker = const MarkerId('selectedLocation');
    });

    mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(selectedLocation!, zoomLevel));
  }

  List<List<TextEditingController>> allControllers = [
    // For pickup controllers
    [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ],
    // For destination controllers
    [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ],
    // For receiver name controllers
    [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ],
    // For receiver number controllers
    [
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
      TextEditingController(),
    ],
  ];

  List<String> controllerNames = [
    "Pickup",
    "Destination",
    "Receiver Name",
    "Receiver Number",
  ];
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    for (int i = 0; i < 5; i++) {
      pickupControllers.add(TextEditingController());
      destinationControllers.add(TextEditingController());
      receiversNameControllers.add(TextEditingController());
      receiversNumberControllers.add(TextEditingController());
    }
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Container(
      color: transparentColor,
      height: size.height * 0.3,
      child: Row(
        children: [
          SvgPicture.asset('assets/images/home-location-path-icon.svg'),
          SizedBox(width: size.width * 0.02),
          SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Container(
                  color: transparentColor,
                  width: size.width * 0.8,
                  child: Stack(
                    children: [
                      TextFormField(
                        controller: widget.pickupController,
                        onChanged: (value) {
                          searchPickUpPlaces(value);
                        },
                        onTap: () {
                          // pickupController.clear();
                          pickUpPredictions.clear();
                        },
                        cursorColor: orangeColor,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 14,
                          fontFamily: 'Inter-Regular',
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: filledColor,
                          errorStyle: TextStyle(
                            color: redColor,
                            fontSize: 10,
                            fontFamily: 'Inter-Bold',
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide(
                              color: redColor,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 20,
                            vertical: 10,
                          ),
                          hintText: "Pickup Location",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 12,
                            fontFamily: 'Inter-Light',
                          ),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              getCurrentLocation();
                              int currentPage =
                                  widget.pageController.page?.round() ?? 0;
                              print("index: ${widget.currentIndex}");
                              widget.pickupController.text = currentAddress;
                            },
                            child: Container(
                              color: transparentColor,
                              child: SvgPicture.asset(
                                'assets/images/gps-icon.svg',
                                fit: BoxFit.scaleDown,
                              ),
                            ),
                          ),
                        ),
                      ),
                      if (pickUpPredictions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Container(
                            decoration: BoxDecoration(
                              color: filledColor,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            width: size.width * 0.8,
                            height: size.height * 0.2,
                            child: ListView.separated(
                              itemCount: pickUpPredictions.length,
                              itemBuilder: (context, index) {
                                final prediction = pickUpPredictions[index];
                                return ListTile(
                                  title: Text(prediction.name),
                                  subtitle:
                                      Text(prediction.formattedAddress ?? ''),
                                  onTap: () {
                                    widget.pickupController.text =
                                        prediction.formattedAddress!;
                                    final double lat =
                                        prediction.geometry!.location.lat;
                                    final double lng =
                                        prediction.geometry!.location.lng;
                                    const double zoomLevel = 15.0;
                                    onPickUpLocationSelected(
                                        LatLng(lat, lng), zoomLevel);
                                    pickupLat = lat.toString();
                                    pickupLng = lng.toString();
                                    setState(() {
                                      pickUpPredictions.clear();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      print("pickupLat: $pickupLat");
                                      print("pickupLng $pickupLng");
                                      print(
                                          "pickupLocation: ${prediction.formattedAddress}");
                                    });
                                    // Move the map camera to the selected location
                                    mapController?.animateCamera(
                                      CameraUpdate.newLatLng(selectedLocation!),
                                    );
                                  },
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                  color: textHaveAccountColor,
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Container(
                  color: transparentColor,
                  width: size.width * 0.8,
                  child: Stack(
                    children: [
                      TextFormField(
                        controller: widget.destinationController,
                        onChanged: (value) {
                          searchDestinationPlaces(value);
                        },
                        onTap: () {
                          // destinationController.clear();
                          destinationPredictions.clear();
                          print("Pickup Controller Text: ${widget.pickupController.text}");

                        },
                        cursorColor: orangeColor,
                        keyboardType: TextInputType.text,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 14,
                          fontFamily: 'Inter-Regular',
                        ),
                        decoration: InputDecoration(
                          filled: true,
                          fillColor: filledColor,
                          errorStyle: TextStyle(
                            color: redColor,
                            fontSize: 10,
                            fontFamily: 'Inter-Bold',
                          ),
                          border: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          enabledBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          focusedBorder: const OutlineInputBorder(
                            borderRadius: BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide.none,
                          ),
                          errorBorder: OutlineInputBorder(
                            borderRadius: const BorderRadius.all(
                              Radius.circular(10),
                            ),
                            borderSide: BorderSide(
                              color: redColor,
                              width: 1,
                            ),
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                              horizontal: 20, vertical: 10),
                          hintText: "Destination",
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 12,
                            fontFamily: 'Inter-Light',
                          ),
                        ),
                      ),
                      if (destinationPredictions.isNotEmpty)
                        Padding(
                          padding: const EdgeInsets.only(top: 40),
                          child: Container(
                            decoration: BoxDecoration(
                              color: filledColor,
                              borderRadius: const BorderRadius.only(
                                bottomLeft: Radius.circular(10),
                                bottomRight: Radius.circular(10),
                              ),
                            ),
                            width: size.width * 0.8,
                            height: size.height * 0.2,
                            child: ListView.separated(
                              itemCount: destinationPredictions.length,
                              itemBuilder: (context, index) {
                                final prediction =
                                    destinationPredictions[index];
                                return ListTile(
                                  title: Text(prediction.name),
                                  subtitle:
                                      Text(prediction.formattedAddress ?? ''),
                                  onTap: () {
                                    widget.destinationController.text =
                                        prediction.formattedAddress!;
                                    final double lat =
                                        prediction.geometry!.location.lat;
                                    final double lng =
                                        prediction.geometry!.location.lng;
                                    destinationLat = lat.toString();
                                    destinationLng = lng.toString();
                                    setState(() {
                                      destinationPredictions.clear();
                                      FocusManager.instance.primaryFocus
                                          ?.unfocus();
                                      print("destinationLat: $destinationLat");
                                      print("destinationLng $destinationLng");
                                      print(
                                          "destinationLocation: ${prediction.formattedAddress}");
                                    });
                                  },
                                );
                              },
                              separatorBuilder: (context, index) {
                                return Divider(
                                  color: textHaveAccountColor,
                                );
                              },
                            ),
                          ),
                        ),
                    ],
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Container(
                  color: transparentColor,
                  width: size.width * 0.8,
                  child: TextFormField(
                    controller: widget.receiversNameController,
                    cursorColor: orangeColor,
                    keyboardType: TextInputType.text,
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 14,
                      fontFamily: 'Inter-Regular',
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: filledColor,
                      errorStyle: TextStyle(
                        color: redColor,
                        fontSize: 10,
                        fontFamily: 'Inter-Bold',
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(
                          color: redColor,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      hintText: "Receiver's Name",
                      hintStyle: TextStyle(
                        color: hintColor,
                        fontSize: 12,
                        fontFamily: 'Inter-Light',
                      ),
                    ),
                  ),
                ),
                SizedBox(height: size.height * 0.015),
                Container(
                  color: transparentColor,
                  width: size.width * 0.8,
                  child: TextFormField(
                    controller: widget.receiversNumberController,
                    cursorColor: orangeColor,
                    keyboardType: TextInputType.phone,
                    style: TextStyle(
                      color: blackColor,
                      fontSize: 14,
                      fontFamily: 'Inter-Regular',
                    ),
                    decoration: InputDecoration(
                      filled: true,
                      fillColor: filledColor,
                      errorStyle: TextStyle(
                        color: redColor,
                        fontSize: 10,
                        fontFamily: 'Inter-Bold',
                      ),
                      border: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      enabledBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      focusedErrorBorder: const OutlineInputBorder(
                        borderRadius: BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide.none,
                      ),
                      errorBorder: OutlineInputBorder(
                        borderRadius: const BorderRadius.all(
                          Radius.circular(10),
                        ),
                        borderSide: BorderSide(
                          color: redColor,
                          width: 1,
                        ),
                      ),
                      contentPadding: const EdgeInsets.symmetric(
                          horizontal: 20, vertical: 10),
                      hintText: "Receiver's Phone Number",
                      hintStyle: TextStyle(
                        color: hintColor,
                        fontSize: 12,
                        fontFamily: 'Inter-Light',
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
