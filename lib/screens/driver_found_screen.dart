// ignore_for_file: use_build_context_synchronously

import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:share_plus/share_plus.dart';
import 'package:lottie/lottie.dart' as lottie;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:flutter/services.dart'
    show Clipboard, ClipboardData, rootBundle;
import 'package:deliver_client/screens/chat_screen.dart';
import 'package:deliver_client/widgets/custom_toast.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/models/cancel_booking_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';
import 'package:deliver_client/models/get_all_system_data_model.dart';
import 'package:deliver_client/models/update_booking_status_model.dart';
import 'package:fluttertoast/fluttertoast.dart';

String? userId;

class DriverFoundScreen extends StatefulWidget {
  final String? bookingId;
  final String? fleetId;
  final String? passCode;
  final String? currentBookingId;
  final double? distance;
  final Map? singleData;
  final Map? multipleData;
  final SearchRiderData? riderData;
  final String? bookingDestinationId;

  const DriverFoundScreen({
    super.key,
    this.bookingId,
    this.fleetId,
    this.passCode,
    this.currentBookingId,
    this.distance,
    this.singleData,
    this.multipleData,
    this.riderData,
    this.bookingDestinationId,
  });

  @override
  State<DriverFoundScreen> createState() => _DriverFoundScreenState();
}

class _DriverFoundScreenState extends State<DriverFoundScreen> {
  bool isLoading = false;

  String? currencyUnit;
  String? distanceUnit;
  Timer? timer;
  String? lat;
  String? lng;
  double? riderLat;
  double? riderLng;
  int currentIndex = 0;
  GoogleMapController? mapController;
  BitmapDescriptor? customMarkerIcon;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];
  ScrollController scrollController = ScrollController();

  GetAllSystemDataModel getAllSystemDataModel = GetAllSystemDataModel();

  getAllSystemData() async {
    try {
      setState(() {
        isLoading = true;
      });
      String apiUrl = "$baseUrl/get_all_system_data";
      debugPrint("apiUrl: $apiUrl");
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getAllSystemDataModel = getAllSystemDataModelFromJson(responseString);
        debugPrint(
            'getAllSystemDataModel status: ${getAllSystemDataModel.status}');
        debugPrint(
            'getAllSystemDataModel length: ${getAllSystemDataModel.data!.length}');
        await updateBookingStatus();
        for (int i = 0; i < getAllSystemDataModel.data!.length; i++) {
          if (getAllSystemDataModel.data?[i].type == "system_currency") {
            currencyUnit = "${getAllSystemDataModel.data?[i].description}";
            debugPrint("currencyUnit: $currencyUnit");
          }
          if (getAllSystemDataModel.data?[i].type == "distance_unit") {
            distanceUnit = "${getAllSystemDataModel.data?[i].description}";
            debugPrint("distanceUnit: $distanceUnit");
            setState(() {
              isLoading = false;
            });
          }
        }
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  CancelBookingModel cancelBookingModel = CancelBookingModel();

  cancelBooking(String cancellationReasonId) async {
    try {
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/cancel_booking_customers";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("bookings_id: ${widget.bookingId}");
      debugPrint("users_fleet_id: ${widget.fleetId}");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "bookings_id": widget.bookingId,
          "bookings_cancellations_reasons_id": cancellationReasonId
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        cancelBookingModel = cancelBookingModelFromJson(responseString);
        setState(() {});
        debugPrint('cancelBookingModel status: ${cancelBookingModel.status}');
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  String? passcode0;
  String? passcode1;
  String? passcode2;
  String? passcode3;
  String? passcode4;

  UpdateBookingStatusModel updateBookingStatusModel =
      UpdateBookingStatusModel();
  String? responseString1;
  updateBookingStatus() async {
    // print(
    // " Passssssssssss ${updateBookingStatusModel.data!.bookingsFleet![0].bookingsDestinations!.passCode}");
    // try {
    String apiUrl = "$baseUrl/get_updated_status_booking";
    debugPrint("apiUrl: $apiUrl");
    debugPrint("currentBookingId: ${widget.currentBookingId}");
    final response = await http.post(
      Uri.parse(apiUrl),
      headers: {
        'Accept': 'application/json',
      },
      body: {
        "bookings_id": widget.currentBookingId,
      },
    );
    responseString1 = response.body;

    debugPrint("response zain: $responseString1");
    debugPrint("statusCode: ${response.statusCode}");
    if (response.statusCode == 200) {
      updateBookingStatusModel =
          updateBookingStatusModelFromJson(responseString1!);
      Map<String, dynamic> jsonResponse = jsonDecode(response.body);

      // Access the passcode

      passcode0 = jsonResponse['data']['bookings_fleet'][0]
              ['bookings_destinations']['passcode'] ??
          "";
      print("Passcode0: $passcode0");
      if (jsonResponse['data']['bookings_fleet'].length > 1) {
        passcode1 = jsonResponse['data']['bookings_fleet'][1]
                ['bookings_destinations']['passcode'] ??
            "";
        print("Passcode1: $passcode1");
      }
      if (jsonResponse['data']['bookings_fleet'].length > 2) {
        passcode2 = jsonResponse['data']['bookings_fleet'][2]
                ['bookings_destinations']['passcode'] ??
            "";
        print("Passcode2: $passcode2");
      }
      if (jsonResponse['data']['bookings_fleet'].length > 3) {
        passcode3 = jsonResponse['data']['bookings_fleet'][3]
                ['bookings_destinations']['passcode'] ??
            "";
        print("Passcode3: $passcode3");
      }
      if (jsonResponse['data']['bookings_fleet'].length > 4) {
        passcode4 = jsonResponse['data']['bookings_fleet'][4]
                ['bookings_destinations']['passcode'] ??
            "";
        print("Passcode4: $passcode4");
      }
      // passcode2 = jsonResponse['data']['bookings_fleet'][2]
      //         ['bookings_destinations']['passcode'] ??
      //     "";
      // print("Passcode2: $passcode2");
      // passcode3 = jsonResponse['data']['bookings_fleet'][3]
      //         ['bookings_destinations']['passcode'] ??
      //     "";
      // print("Passcode3: $passcode3");
      // passcode4 = jsonResponse['data']['bookings_fleet'][4]
      //         ['bookings_destinations']['passcode'] ??
      //     "";
      // print("Passcode4: $passcode4");

      debugPrint(
          'updateBookingStatusModel status: ${updateBookingStatusModel.status}');
      if (updateBookingStatusModel.data?.status == "Accepted") {
        timer?.cancel();
        // Navigator.push(
        //   context,
        //   MaterialPageRoute(
        //     builder: (context) => BookingAcceptedScreen(
        //       distance: widget.distance,
        //       singleData: widget.singleData,
        //       multipleData: widget.multipleData,
        //       passCode: widget.passCode,
        //       riderData: widget.riderData!,
        //       currentBookingId: widget.currentBookingId,
        //       bookingDestinationId: widget.bookingDestinationId,
        //     ),
        //   ),
        // );
      }
      if (mounted) {
        setState(() {});
      }
    }
    // }
    //  catch (e) {
    //   debugPrint('Something went wrong = ${e.toString()}');
    //   return null;
    // }
  }

  Future<void> loadCustomMarker() async {
    final ByteData bytes = await rootBundle.load(
      'assets/images/rider-marker-icon.png',
    );
    final Uint8List list = bytes.buffer.asUint8List();

    customMarkerIcon = BitmapDescriptor.fromBytes(list);

    setState(() {});
  }

  void showPasscodeDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        var size = MediaQuery.of(context).size;
        return WillPopScope(
          onWillPop: () {
            return Future.value(false);
          },
          child: StatefulBuilder(
            builder: (context, setState) => Dialog(
              backgroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(40),
              ),
              insetPadding: const EdgeInsets.only(left: 20, right: 20),
              child: SizedBox(
                height: size.height * 0.36,
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SizedBox(height: size.height * 0.02),
                      Text(
                        'Passcode',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: orangeColor,
                          fontSize: 24,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                      SizedBox(height: size.height * 0.01),
                      Text(
                        'Share your passcode with the receiver\nto ensure a secure and safe delivery.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 16,
                          fontFamily: 'Syne-Regular',
                        ),
                      ),
                      Text(
                        '${widget.passCode}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 24,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                      SizedBox(height: size.height * 0.002),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          GestureDetector(
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: dialogButtonTransparentGradientSmall(
                              "Continue",
                              context,
                            ),
                          ),
                          GestureDetector(
                            onTap: () {
                              sharePasscode("${widget.passCode}");
                            },
                            child: dialogButtonGradientSmall("Share", context),
                          ),
                        ],
                      ),
                      SizedBox(height: size.height * 0.01),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  void sharePasscode(String passcode) {
    Share.share('Your passcode is: $passcode');
  }

  Future<void> makePhoneCall(String phoneNumber) async {
    final Uri launchUri = Uri(
      scheme: 'tel',
      path: phoneNumber,
    );
    await launchUrl(launchUri);
  }

  startTimer() {
    timer = Timer.periodic(const Duration(seconds: 10), (timer) {
      updateBookingStatus();
    });
  }

  @override
  void initState() {
    super.initState();
    debugPrint("passCode: ${widget.passCode}");

    // Future.delayed(Duration.zero, () {
    //   showPasscodeDialog();
    // });
    getAllSystemData();
    loadCustomMarker();
    lat = "${widget.riderData!.latitude}";
    lng = "${widget.riderData!.longitude}";
    riderLat = double.parse(lat!);
    riderLng = double.parse(lng!);
    debugPrint("riderLat: $riderLat");
    debugPrint("riderLng: $riderLng");
    debugPrint("currentBookingId: ${widget.currentBookingId}");
    debugPrint("bookingDestinationId;: ${widget.bookingDestinationId}");
    startTimer();
    scrollController.addListener(() {
      setState(() {
        // Update the current index based on the scroll position
        currentIndex =
            (scrollController.offset / MediaQuery.of(context).size.width)
                .round();
      });
    });
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Scaffold(
        backgroundColor: bgColor,
        body: isLoading
            ? Center(
                child: Container(
                  width: 100,
                  height: 100,
                  color: transparentColor,
                  child: lottie.Lottie.asset(
                    'assets/images/loading-icon.json',
                    fit: BoxFit.cover,
                  ),
                ),
              )
            : widget.riderData != null
                ? Stack(
                    children: [
                      Container(
                        color: transparentColor,
                        width: size.width,
                        height: size.height * 1,
                        child: GoogleMap(
                          onMapCreated: (controller) {
                            mapController = controller;
                          },
                          mapType: MapType.normal,
                          myLocationEnabled: false,
                          zoomControlsEnabled: false,
                          initialCameraPosition: CameraPosition(
                            target: LatLng(
                              riderLat != null ? riderLat! : 0.0,
                              riderLng != null ? riderLng! : 0.0,
                            ),
                            zoom: 15,
                          ),
                          markers: {
                            Marker(
                              markerId: const MarkerId("riderMarker"),
                              position: LatLng(
                                riderLat != null ? riderLat! : 0.0,
                                riderLng != null ? riderLng! : 0.0,
                              ),
                              icon: customMarkerIcon ??
                                  BitmapDescriptor.defaultMarker,
                            ),
                          },
                        ),
                      ),
                      Positioned(
                        top: 45,
                        left: 0,
                        right: 0,
                        child: Text(
                          "Driver Found",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: blackColor,
                            fontSize: 20,
                            fontFamily: 'Syne-Bold',
                          ),
                        ),
                      ),
                      // Positioned(
                      //   top: 160,
                      //   left: 50,
                      //   child: SpeechBalloon(
                      //     nipLocation: NipLocation.bottom,
                      //     nipHeight: 12,
                      //     borderColor: borderColor,
                      //     width: size.width * 0.45,
                      //     height: size.height * 0.1,
                      //     borderRadius: 10,
                      //     offset: const Offset(10, 0),
                      //     child: Padding(
                      //       padding: const EdgeInsets.all(8),
                      //       child: Column(
                      //         children: [
                      //           Row(
                      //             mainAxisAlignment: MainAxisAlignment.start,
                      //             crossAxisAlignment: CrossAxisAlignment.start,
                      //             children: [
                      //               ClipRRect(
                      //                 borderRadius: BorderRadius.circular(100),
                      //                 child: Container(
                      //                   color: transparentColor,
                      //                   width: 35,
                      //                   height: 35,
                      //                   child: FadeInImage(
                      //                     placeholder: const AssetImage(
                      //                       "assets/images/user-profile.png",
                      //                     ),
                      //                     image: NetworkImage(
                      //                       '$imageUrl${widget.riderData!.profilePic}',
                      //                     ),
                      //                     fit: BoxFit.cover,
                      //                   ),
                      //                 ),
                      //               ),
                      //               SizedBox(width: size.width * 0.01),
                      //               Column(
                      //                 mainAxisAlignment: MainAxisAlignment.start,
                      //                 crossAxisAlignment:
                      //                     CrossAxisAlignment.start,
                      //                 children: [
                      //                   Text(
                      //                     "${widget.riderData!.firstName} ${widget.riderData!.lastName}",
                      //                     textAlign: TextAlign.left,
                      //                     style: TextStyle(
                      //                       color: blackColor,
                      //                       fontSize: 12,
                      //                       fontFamily: 'Inter-Regular',
                      //                     ),
                      //                   ),
                      //                   Row(
                      //                     children: [
                      //                       SvgPicture.asset(
                      //                         'assets/images/orange-location-icon.svg',
                      //                       ),
                      //                       SizedBox(width: size.width * 0.005),
                      //                       Text(
                      //                         "${widget.riderData!.address}",
                      //                         textAlign: TextAlign.center,
                      //                         style: TextStyle(
                      //                           color: textHaveAccountColor,
                      //                           fontSize: 10,
                      //                           fontFamily: 'Inter-Regular',
                      //                         ),
                      //                       ),
                      //                     ],
                      //                   ),
                      //                 ],
                      //               ),
                      //             ],
                      //           ),
                      //           statusButtonSmall(
                      //               "Pending", redStatusButtonColor, context),
                      //         ],
                      //       ),
                      //     ),
                      //   ),
                      // ),
                      Positioned(
                        bottom: 0,
                        child: ClipRRect(
                          borderRadius: const BorderRadius.only(
                            topLeft: Radius.circular(40),
                            topRight: Radius.circular(40),
                          ),
                          child: Container(
                            width: size.width,
                            height: widget.singleData!.isNotEmpty
                                ? size.height * 0.46
                                : size.height * 0.48,
                            decoration: BoxDecoration(
                              color: whiteColor,
                            ),
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 20),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(height: size.height * 0.04),
                                  Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        "Driver Found",
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: blackColor,
                                          fontSize: 22,
                                          fontFamily: 'Syne-Bold',
                                        ),
                                      ),
                                      statusButtonSmall("Pending",
                                          redStatusButtonColor, context),
                                      // Text(
                                      //   "5min",
                                      //   textAlign: TextAlign.left,
                                      //   style: TextStyle(
                                      //     color: textHaveAccountColor,
                                      //     fontSize: 16,
                                      //     fontFamily: 'Inter-Regular',
                                      //   ),
                                      // ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.02),
                                  Row(
                                    children: [
                                      ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Container(
                                          color: transparentColor,
                                          width: 55,
                                          height: 55,
                                          child: widget.riderData!.profilePic != null &&
                                              widget.riderData!.profilePic!.isNotEmpty
                                              ? FadeInImage(
                                            placeholder: const AssetImage("assets/images/user-profile.png"),
                                            image: NetworkImage(
                                              '$imageUrl${widget.riderData!.profilePic}',
                                            ),
                                            fit: BoxFit.cover,
                                          )
                                              : Image.asset(
                                            "assets/images/user-profile.png", // Asset fallback image
                                            fit: BoxFit.cover,
                                          ),
                                          // child: FadeInImage(
                                          //   placeholder: const AssetImage(
                                          //     "assets/images/user-profile.png",
                                          //   ),
                                          //   image: NetworkImage(
                                          //     '$imageUrl${widget.riderData!.profilePic}',
                                          //   ),
                                          //   fit: BoxFit.cover,
                                          // ),
                                        ),
                                      ),
                                      SizedBox(width: size.width * 0.03),
                                      Column(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          Container(
                                            color: transparentColor,
                                            width: size.width * 0.45,
                                            child: AutoSizeText(
                                              "${widget.riderData!.firstName} ${widget.riderData!.lastName}",
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: drawerTextColor,
                                                fontSize: 16,
                                                fontFamily: 'Syne-SemiBold',
                                              ),
                                              maxFontSize: 16,
                                              minFontSize: 12,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(height: size.height * 0.003),
                                          Stack(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/star-with-container-icon.svg',
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                    top: 1.5, left: 24),
                                                child: Text(
                                                  "${widget.riderData!.bookingsRatings}",
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 14,
                                                    fontFamily: 'Inter-Regular',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          SizedBox(height: size.height * 0.003),
                                          Container(
                                            color: transparentColor,
                                            width: size.width * 0.45,
                                            child: AutoSizeText(
                                              "${widget.riderData!.usersFleetVehicles!.color} ${widget.riderData!.usersFleetVehicles!.model} (${widget.riderData!.usersFleetVehicles!.vehicleRegistrationNo})",
                                              textAlign: TextAlign.center,
                                              style: TextStyle(
                                                color: textHaveAccountColor,
                                                fontSize: 14,
                                                fontFamily: 'Syne-Regular',
                                              ),
                                              minFontSize: 14,
                                              maxFontSize: 14,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const Spacer(),
                                      Row(
                                        children: [
                                          GestureDetector(
                                            onTap: () {
                                              timer?.cancel();
                                              Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      ChatScreen(
                                                    callbackFunction:
                                                        startTimer,
                                                    riderId: widget
                                                        .riderData!.usersFleetId
                                                        .toString(),
                                                    name:
                                                        "${widget.riderData!.firstName} ${widget.riderData!.lastName}",
                                                    image: widget
                                                        .riderData!.profilePic,
                                                    phone:
                                                        widget.riderData!.phone,
                                                    address: widget
                                                        .riderData!.address,
                                                  ),
                                                ),
                                              );
                                            },
                                            child: SvgPicture.asset(
                                              'assets/images/message-icon.svg',
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.02),
                                          GestureDetector(
                                            onTap: () {
                                              makePhoneCall(
                                                  "${widget.riderData!.phone}");
                                              // timer?.cancel();
                                              // Navigator.push(
                                              //   context,
                                              //   MaterialPageRoute(
                                              //     builder: (context) =>
                                              //         CallScreen(
                                              //       name:
                                              //           "${widget.riderData!.firstName} ${widget.riderData!.lastName}",
                                              //       image: widget
                                              //           .riderData!.profilePic,
                                              //     ),
                                              //   ),
                                              // );
                                            },
                                            child: SvgPicture.asset(
                                              'assets/images/call-icon.svg',
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: size.height * 0.01),
                                  widget.singleData!.isNotEmpty
                                      ? Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            GestureDetector(
                                              onTap: () {
                                                Clipboard.setData(ClipboardData(
                                                    text: "$passcode0"));
                                                CustomToast.showToast(
                                                  fontSize: 12,
                                                  message:
                                                      "$passcode0 copied to clipboard",
                                                );
                                              },
                                              child: Tooltip(
                                                message: "$passcode0",
                                                child: Text(
                                                  "Passcode ${passcode0 ?? '--'}",
                                                  textAlign: TextAlign.left,
                                                  style: TextStyle(
                                                    color: orangeColor,
                                                    fontSize: 16,
                                                    fontFamily: 'Syne-Bold',
                                                  ),
                                                  maxLines: 2,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                ),
                                              ),
                                            ),
                                            Tooltip(
                                              message:
                                                  "${widget.singleData?["destin_address"]}",
                                              child: Text(
                                                "${widget.singleData?["destin_address"]}",
                                                textAlign: TextAlign.left,
                                                style: TextStyle(
                                                  color: blackColor,
                                                  fontSize: 16,
                                                  fontFamily: 'Syne-Bold',
                                                ),
                                                maxLines: 2,
                                                overflow: TextOverflow.ellipsis,
                                              ),
                                            ),
                                            SizedBox(
                                                height: size.height * 0.03),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: [
                                                Column(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/images/black-location-icon.svg',
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Tooltip(
                                                      message:
                                                          "${widget.distance} $distanceUnit",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.18,
                                                        child: AutoSizeText(
                                                          "${widget.distance} $distanceUnit",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color:
                                                                drawerTextColor,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Inter-Regular',
                                                          ),
                                                          maxFontSize: 16,
                                                          minFontSize: 12,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/images/black-clock-icon.svg',
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Tooltip(
                                                      message:
                                                          "${widget.singleData?["destin_time"]}",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width:
                                                            size.width * 0.38,
                                                        child: AutoSizeText(
                                                          "${widget.singleData?["destin_time"]}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color:
                                                                drawerTextColor,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Inter-Regular',
                                                          ),
                                                          maxFontSize: 16,
                                                          minFontSize: 12,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                Column(
                                                  children: [
                                                    SvgPicture.asset(
                                                      'assets/images/black-naira-icon.svg',
                                                    ),
                                                    SizedBox(
                                                        height:
                                                            size.height * 0.01),
                                                    Tooltip(
                                                      message:
                                                          "$currencyUnit${widget.singleData?["total_charges"]}",
                                                      child: Container(
                                                        color: transparentColor,
                                                        width: size.width * 0.2,
                                                        child: AutoSizeText(
                                                          "$currencyUnit${widget.singleData?["total_charges"]}",
                                                          textAlign:
                                                              TextAlign.center,
                                                          style: TextStyle(
                                                            color:
                                                                drawerTextColor,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Inter-Regular',
                                                          ),
                                                          maxFontSize: 16,
                                                          minFontSize: 12,
                                                          maxLines: 1,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : Container(
                                          color: transparentColor,
                                          child: SingleChildScrollView(
                                            controller: scrollController,
                                            scrollDirection: Axis.horizontal,
                                            child: Row(
                                              children: [
                                                Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.86,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      "$passcode0"));
                                                          CustomToast.showToast(
                                                            fontSize: 12,
                                                            message:
                                                                "$passcode0 copied to clipboard",
                                                          );
                                                        },
                                                        child: Tooltip(
                                                          message: "$passcode0",
                                                          child: Text(
                                                            "Passcode ${passcode0 ?? '--'}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color:
                                                                  orangeColor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Syne-Bold',
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      Tooltip(
                                                        message:
                                                            "${widget.multipleData?["destin_address0"]}",
                                                        child: Text(
                                                          "${widget.multipleData?["destin_address0"]}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Syne-Bold',
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: size.height *
                                                              0.03),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/black-location-icon.svg',
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01),
                                                              Tooltip(
                                                                message:
                                                                    "${widget.distance} $distanceUnit",
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      transparentColor,
                                                                  width:
                                                                      size.width *
                                                                          0.18,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "${widget.distance} $distanceUnit",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          drawerTextColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                    maxFontSize:
                                                                        16,
                                                                    minFontSize:
                                                                        12,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/black-clock-icon.svg',
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01),
                                                              Tooltip(
                                                                message:
                                                                    "${widget.multipleData?["destin_time0"]}",
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      transparentColor,
                                                                  width:
                                                                      size.width *
                                                                          0.38,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "${widget.multipleData?["destin_time0"]}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          drawerTextColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                    maxFontSize:
                                                                        16,
                                                                    minFontSize:
                                                                        12,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/black-naira-icon.svg',
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01),
                                                              Tooltip(
                                                                message:
                                                                    "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      transparentColor,
                                                                  width:
                                                                      size.width *
                                                                          0.2,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          drawerTextColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                    maxFontSize:
                                                                        16,
                                                                    minFontSize:
                                                                        12,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.04),
                                                Container(
                                                  color: transparentColor,
                                                  width: size.width * 0.85,
                                                  child: Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      GestureDetector(
                                                        onTap: () {
                                                          Clipboard.setData(
                                                              ClipboardData(
                                                                  text:
                                                                      "$passcode1"));
                                                          Fluttertoast.showToast(
                                                              msg:
                                                                  "$passcode1 copied to clipboard",
                                                              toastLength: Toast
                                                                  .LENGTH_SHORT,
                                                              gravity:
                                                                  ToastGravity
                                                                      .BOTTOM,
                                                              timeInSecForIosWeb:
                                                                  1,
                                                              backgroundColor:
                                                                  Colors.grey,
                                                              textColor:
                                                                  Colors.white,
                                                              fontSize: 16.0);
                                                        },
                                                        child: Tooltip(
                                                          message: "$passcode1",
                                                          child: Text(
                                                            "Passcode ${passcode1 ?? "--"}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color:
                                                                  orangeColor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Syne-Bold',
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                      ),
                                                      Tooltip(
                                                        message:
                                                            "${widget.multipleData?["destin_address1"]}",
                                                        child: Text(
                                                          "${widget.multipleData?["destin_address1"]}",
                                                          textAlign:
                                                              TextAlign.left,
                                                          style: TextStyle(
                                                            color: blackColor,
                                                            fontSize: 16,
                                                            fontFamily:
                                                                'Syne-Bold',
                                                          ),
                                                          maxLines: 2,
                                                          overflow: TextOverflow
                                                              .ellipsis,
                                                        ),
                                                      ),
                                                      SizedBox(
                                                          height: size.height *
                                                              0.03),
                                                      Row(
                                                        mainAxisAlignment:
                                                            MainAxisAlignment
                                                                .spaceBetween,
                                                        children: [
                                                          Column(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/black-location-icon.svg',
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01),
                                                              Tooltip(
                                                                message:
                                                                    "${widget.distance} $distanceUnit",
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      transparentColor,
                                                                  width:
                                                                      size.width *
                                                                          0.18,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "${widget.distance} $distanceUnit",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          drawerTextColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                    maxFontSize:
                                                                        16,
                                                                    minFontSize:
                                                                        12,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/black-clock-icon.svg',
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01),
                                                              Tooltip(
                                                                message:
                                                                    "${widget.multipleData?["destin_time1"]}",
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      transparentColor,
                                                                  width:
                                                                      size.width *
                                                                          0.38,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "${widget.multipleData?["destin_time1"]}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          drawerTextColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                    maxFontSize:
                                                                        16,
                                                                    minFontSize:
                                                                        12,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                          Column(
                                                            children: [
                                                              SvgPicture.asset(
                                                                'assets/images/black-naira-icon.svg',
                                                              ),
                                                              SizedBox(
                                                                  height:
                                                                      size.height *
                                                                          0.01),
                                                              Tooltip(
                                                                message:
                                                                    "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                child:
                                                                    Container(
                                                                  color:
                                                                      transparentColor,
                                                                  width:
                                                                      size.width *
                                                                          0.2,
                                                                  child:
                                                                      AutoSizeText(
                                                                    "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                    textAlign:
                                                                        TextAlign
                                                                            .center,
                                                                    style:
                                                                        TextStyle(
                                                                      color:
                                                                          drawerTextColor,
                                                                      fontSize:
                                                                          16,
                                                                      fontFamily:
                                                                          'Inter-Regular',
                                                                    ),
                                                                    maxFontSize:
                                                                        16,
                                                                    minFontSize:
                                                                        12,
                                                                    maxLines: 1,
                                                                    overflow:
                                                                        TextOverflow
                                                                            .ellipsis,
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                SizedBox(
                                                    width: size.width * 0.04),
                                                if (widget.multipleData![
                                                            "destin_address2"] !=
                                                        null &&
                                                    widget
                                                        .multipleData![
                                                            "destin_address2"]
                                                        .isNotEmpty)
                                                  Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.85,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text:
                                                                        "$passcode2"));
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "$passcode2 copied to clipboard",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                          },
                                                          child: Tooltip(
                                                            message:
                                                                "$passcode2",
                                                            child: Text(
                                                              "Passcode ${passcode2 ?? "--"}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    orangeColor,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Syne-Bold',
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        Tooltip(
                                                          message:
                                                              "${widget.multipleData?["destin_address2"]}",
                                                          child: Text(
                                                            "${widget.multipleData?["destin_address2"]}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Syne-Bold',
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                size.height *
                                                                    0.03),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-location-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "${widget.distance} $distanceUnit",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.18,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.distance} $distanceUnit",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-clock-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "${widget.multipleData?["destin_time2"]}",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.38,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.multipleData?["destin_time2"]}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-naira-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width:
                                                                        size.width *
                                                                            0.2,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                SizedBox(
                                                    width: size.width * 0.04),
                                                if (widget.multipleData![
                                                            "destin_address3"] !=
                                                        null &&
                                                    widget
                                                        .multipleData![
                                                            "destin_address3"]
                                                        .isNotEmpty)
                                                  Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.85,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text:
                                                                        "$passcode3"));
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "$passcode3 copied to clipboard",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                          },
                                                          child: Tooltip(
                                                            message:
                                                                "$passcode3",
                                                            child: Text(
                                                              "Passcode ${passcode3 ?? "--"}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    orangeColor,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Syne-Bold',
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        Tooltip(
                                                          message:
                                                              "${widget.multipleData?["destin_address3"]}",
                                                          child: Text(
                                                            "${widget.multipleData?["destin_address3"]}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Syne-Bold',
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                size.height *
                                                                    0.03),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-location-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "${widget.distance} $distanceUnit",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.18,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.distance} $distanceUnit",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-clock-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "${widget.multipleData?["destin_time3"]}",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.38,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.multipleData?["destin_time3"]}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-naira-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width:
                                                                        size.width *
                                                                            0.2,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                SizedBox(
                                                    width: size.width * 0.04),
                                                if (widget.multipleData![
                                                            "destin_address4"] !=
                                                        null &&
                                                    widget
                                                        .multipleData![
                                                            "destin_address4"]
                                                        .isNotEmpty)
                                                  Container(
                                                    color: transparentColor,
                                                    width: size.width * 0.85,
                                                    child: Column(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        GestureDetector(
                                                          onTap: () {
                                                            Clipboard.setData(
                                                                ClipboardData(
                                                                    text:
                                                                        "$passcode4"));
                                                            Fluttertoast.showToast(
                                                                msg:
                                                                    "$passcode4 copied to clipboard",
                                                                toastLength: Toast
                                                                    .LENGTH_SHORT,
                                                                gravity:
                                                                    ToastGravity
                                                                        .BOTTOM,
                                                                timeInSecForIosWeb:
                                                                    1,
                                                                backgroundColor:
                                                                    Colors.grey,
                                                                textColor:
                                                                    Colors
                                                                        .white,
                                                                fontSize: 16.0);
                                                          },
                                                          child: Tooltip(
                                                            message:
                                                                "$passcode4",
                                                            child: Text(
                                                              "Passcode ${passcode4 ?? "--"}",
                                                              textAlign:
                                                                  TextAlign
                                                                      .left,
                                                              style: TextStyle(
                                                                color:
                                                                    orangeColor,
                                                                fontSize: 16,
                                                                fontFamily:
                                                                    'Syne-Bold',
                                                              ),
                                                              maxLines: 2,
                                                              overflow:
                                                                  TextOverflow
                                                                      .ellipsis,
                                                            ),
                                                          ),
                                                        ),
                                                        Tooltip(
                                                          message:
                                                              "${widget.multipleData?["destin_address4"]}",
                                                          child: Text(
                                                            "${widget.multipleData?["destin_address4"]}",
                                                            textAlign:
                                                                TextAlign.left,
                                                            style: TextStyle(
                                                              color: blackColor,
                                                              fontSize: 16,
                                                              fontFamily:
                                                                  'Syne-Bold',
                                                            ),
                                                            maxLines: 2,
                                                            overflow:
                                                                TextOverflow
                                                                    .ellipsis,
                                                          ),
                                                        ),
                                                        SizedBox(
                                                            height:
                                                                size.height *
                                                                    0.03),
                                                        Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .spaceBetween,
                                                          children: [
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-location-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "${widget.distance} $distanceUnit",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.18,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.distance} $distanceUnit",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-clock-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "${widget.multipleData?["destin_time4"]}",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width: size
                                                                            .width *
                                                                        0.38,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "${widget.multipleData?["destin_time4"]}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            Column(
                                                              children: [
                                                                SvgPicture
                                                                    .asset(
                                                                  'assets/images/black-naira-icon.svg',
                                                                ),
                                                                SizedBox(
                                                                    height: size
                                                                            .height *
                                                                        0.01),
                                                                Tooltip(
                                                                  message:
                                                                      "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                  child:
                                                                      Container(
                                                                    color:
                                                                        transparentColor,
                                                                    width:
                                                                        size.width *
                                                                            0.2,
                                                                    child:
                                                                        AutoSizeText(
                                                                      "$currencyUnit${widget.multipleData?["total_charges"]}",
                                                                      textAlign:
                                                                          TextAlign
                                                                              .center,
                                                                      style:
                                                                          TextStyle(
                                                                        color:
                                                                            drawerTextColor,
                                                                        fontSize:
                                                                            16,
                                                                        fontFamily:
                                                                            'Inter-Regular',
                                                                      ),
                                                                      maxFontSize:
                                                                          16,
                                                                      minFontSize:
                                                                          12,
                                                                      maxLines:
                                                                          1,
                                                                      overflow:
                                                                          TextOverflow
                                                                              .ellipsis,
                                                                    ),
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                              ],
                                            ),
                                          ),
                                        ),
                                  widget.singleData != null
                                      ? SizedBox(height: size.height * 0.01)
                                      : SizedBox(height: size.height * 0.02),
                                  if (widget.multipleData != null &&
                                      widget.multipleData!.isNotEmpty)
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Container(
                                          width: 10,
                                          height: 10,
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: currentIndex == 0
                                                ? orangeColor
                                                : dotsColor,
                                          ),
                                        ),
                                        Container(
                                          width: 10,
                                          height: 10,
                                          margin: const EdgeInsets.symmetric(
                                              horizontal: 2),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: currentIndex == 1
                                                ? orangeColor
                                                : dotsColor,
                                          ),
                                        ),
                                        if (widget.multipleData![
                                                    "destin_address2"] !=
                                                null &&
                                            widget
                                                .multipleData![
                                                    "destin_address2"]
                                                .isNotEmpty)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 1),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: currentIndex == 2
                                                  ? orangeColor
                                                  : dotsColor,
                                            ),
                                          ),
                                        if (widget.multipleData![
                                                    "destin_address3"] !=
                                                null &&
                                            widget
                                                .multipleData![
                                                    "destin_address3"]
                                                .isNotEmpty)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 1),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: currentIndex == 3
                                                  ? orangeColor
                                                  : dotsColor,
                                            ),
                                          ),
                                        if (widget.multipleData![
                                                    "destin_address4"] !=
                                                null &&
                                            widget
                                                .multipleData![
                                                    "destin_address4"]
                                                .isNotEmpty)
                                          Container(
                                            width: 10,
                                            height: 10,
                                            margin: const EdgeInsets.symmetric(
                                                horizontal: 1),
                                            decoration: BoxDecoration(
                                              shape: BoxShape.circle,
                                              color: currentIndex == 4
                                                  ? orangeColor
                                                  : dotsColor,
                                            ),
                                          ),
                                      ],
                                    ),
                                  SizedBox(height: size.height * 0.02),
                                  GestureDetector(
                                      onTap: () async {
                                        final reasons =
                                            await fetchCancellationReasons(); // Fetch cancellation reasons
                                        showDialog(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (context) => cancelRide(
                                              context,
                                              reasons), // Pass reasons to cancelRide function
                                        );
                                      },
                                      child:
                                          buttonTransparent("CANCEL", context)),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Positioned(
                      //   top: 40,
                      //   left: 20,
                      //   child: GestureDetector(
                      //     onTap: () {
                      //       Navigator.pop(context);
                      //     },
                      //     child: SvgPicture.asset(
                      //       'assets/images/back-icon.svg',
                      //       fit: BoxFit.scaleDown,
                      //     ),
                      //   ),
                      // ),
                      Positioned(
                        top: 45,
                        right: 20,
                        child: GestureDetector(
                          onTap: () async {
                            await getAllSystemData();
                          },
                          child: const Icon(
                            Icons.refresh,
                            color: Colors.black,
                            size: 24.0,
                          ),
                        ),
                      ),
                    ],
                  )
                : null,
      ),
    );
  }

  bool isCanceling = false;
  Future<List<RideCancellationReason>> fetchCancellationReasons() async {
    final response = await http.post(
      Uri.parse(
          'https://deliverbygfl.com/api/get_bookings_cancellations_reasons'),
      headers: <String, String>{
        'Content-Type': 'application/json',
      },
      body: jsonEncode(<String, String>{
        'user_type': 'Customer',
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData['status'] == 'success') {
        final List<dynamic> data = responseData['data'];
        return data.map((reasonData) {
          return RideCancellationReason(
            id: reasonData['bookings_cancellations_reasons_id'].toString(),
            reason: reasonData['reason'],
          );
        }).toList();
      } else {
        throw Exception('Failed to fetch cancellation reasons');
      }
    } else {
      throw Exception('Failed to fetch cancellation reasons');
    }
  }

  cancelRide(BuildContext context, List<RideCancellationReason> reasons) {
    var size = MediaQuery.of(context).size;
    String? selectedReason;
    return StatefulBuilder(
      builder: (context, setState) => Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        insetPadding: const EdgeInsets.only(left: 20, right: 20),
        child: SizedBox(
          height: size.height * 0.7,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: FutureBuilder<List<RideCancellationReason>>(
              future: fetchCancellationReasons(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Center(child: CircularProgressIndicator()),
                    ],
                  );
                } else if (snapshot.hasError) {
                  return Text('Error: ${snapshot.error}');
                } else {
                  final cancellationReasons = snapshot.data!;
                  return Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Align(
                          alignment: Alignment.centerRight,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 5),
                            child: SvgPicture.asset(
                                "assets/images/close-icon.svg"),
                          ),
                        ),
                      ),
                      Text(
                        'Cancel Ride',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: orangeColor,
                          fontSize: 24,
                          fontFamily: 'Syne-Bold',
                        ),
                      ),
                      Text(
                        'Are you sure you want to cancel this ride?',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: blackColor,
                          fontSize: 18,
                          fontFamily: 'Syne-Regular',
                        ),
                      ),
                      // Display cancellation reasons as radio buttons
                      Column(
                        children: cancellationReasons.map((reason) {
                          return Transform.scale(
                            scale: 0.9,
                            child: RadioListTile<String>(
                              title: Text(
                                reason.reason,
                                style: TextStyle(color: blackColor),
                              ),
                              value: reason.id,
                              groupValue: selectedReason,
                              onChanged: (String? value) {
                                setState(() {
                                  selectedReason = value!;
                                });
                              },
                              activeColor: orangeColor,
                            ),
                          );
                        }).toList(),
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          GestureDetector(
                            onTap: () async {
                              if (selectedReason != null) {
                                setState(() {
                                  isLoading = true;
                                });
                                await cancelBooking(selectedReason!);
                                if (cancelBookingModel.status == "success") {
                                  timer?.cancel();
                                  Navigator.of(context).pushAndRemoveUntil(
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const HomePageScreen()),
                                    (Route<dynamic> route) => false,
                                  );
                                  setState(() {
                                    isLoading = false;
                                  });
                                } else {
                                  CustomToast.showToast(
                                    fontSize: 12,
                                    message:
                                        "You have already cancelled this booking.",
                                  );
                                }
                              } else {
                                CustomToast.showToast(
                                  fontSize: 12,
                                  message:
                                      "Please select a cancellation reason.",
                                );
                              }
                              setState(() {
                                isLoading = false;
                              });
                            },
                            child: isLoading
                                ? dialogButtonGradientSmallWithLoader(
                                    "Please wait...", context)
                                : Container(
                                    height: MediaQuery.of(context).size.height *
                                        0.06,
                                    width: MediaQuery.of(context).size.width *
                                        0.45,
                                    decoration: BoxDecoration(
                                      gradient: LinearGradient(
                                        begin: Alignment.centerRight,
                                        end: Alignment.centerLeft,
                                        stops: const [0.1, 1.5],
                                        colors: [
                                          orangeColor,
                                          yellowColor,
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Text(
                                        "Yes, Cancel Ride",
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          color: whiteColor,
                                          fontSize: 16,
                                          fontFamily: 'Syne-Medium',
                                        ),
                                      ),
                                    ),
                                  ),
                          ),
                        ],
                      ),
                    ],
                  );
                }
              },
            ),
          ),
        ),
      ),
    );
  }

  // cancelRide(BuildContext context) {
  //   var size = MediaQuery.of(context).size;
  //   return WillPopScope(
  //     onWillPop: () {
  //       return Future.value(false);
  //     },
  //     child: StatefulBuilder(
  //       builder: (context, setState) => Dialog(
  //         backgroundColor: Colors.white,
  //         shape: RoundedRectangleBorder(
  //           borderRadius: BorderRadius.circular(40),
  //         ),
  //         insetPadding: const EdgeInsets.only(left: 20, right: 20),
  //         child: SizedBox(
  //           height: size.height * 0.3,
  //           child: Padding(
  //             padding: const EdgeInsets.symmetric(horizontal: 20),
  //             child: Column(
  //               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
  //               children: [
  //                 GestureDetector(
  //                   onTap: () {
  //                     Navigator.pop(context);
  //                   },
  //                   child: Align(
  //                     alignment: Alignment.centerRight,
  //                     child: Padding(
  //                       padding: const EdgeInsets.only(top: 15),
  //                       child: SvgPicture.asset("assets/images/close-icon.svg"),
  //                     ),
  //                   ),
  //                 ),
  //                 SizedBox(height: size.height * 0.01),
  //                 Text(
  //                   'Cancel Ride',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     color: orangeColor,
  //                     fontSize: 24,
  //                     fontFamily: 'Syne-Bold',
  //                   ),
  //                 ),
  //                 Text(
  //                   'Are you sure, you want\nto cancel this ride?',
  //                   textAlign: TextAlign.center,
  //                   style: TextStyle(
  //                     color: blackColor,
  //                     fontSize: 18,
  //                     fontFamily: 'Syne-Regular',
  //                   ),
  //                 ),
  //                 SizedBox(height: size.height * 0.01),
  //                 Row(
  //                   mainAxisAlignment: MainAxisAlignment.spaceAround,
  //                   children: [
  //                     GestureDetector(
  //                       onTap: () {
  //                         Navigator.pop(context);
  //                       },
  //                       child:
  //                           dialogButtonTransparentGradientSmall("No", context),
  //                     ),
  //                     GestureDetector(
  //                       onTap: () async {
  //                         setState(() {
  //                           isLoading = true;
  //                         });
  //                         await cancelBooking();
  //                         if (cancelBookingModel.status == "success") {
  //                           timer?.cancel();
  //                           Navigator.of(context).pushAndRemoveUntil(
  //                               MaterialPageRoute(
  //                                   builder: (context) =>
  //                                       const HomePageScreen()),
  //                               (Route<dynamic> route) => false);
  //                           setState(() {
  //                             isLoading = false;
  //                           });
  //                         } else {
  //                           CustomToast.showToast(
  //                             fontSize: 12,
  //                             message:
  //                                 "You have already cancelled this booking.",
  //                           );
  //                           setState(() {
  //                             isLoading = false;
  //                           });
  //                         }
  //                       },
  //                       child: isLoading
  //                           ? dialogButtonGradientSmallWithLoader(
  //                               "Please wait...", context)
  //                           : dialogButtonGradientSmall("Yes", context),
  //                     ),
  //                   ],
  //                 ),
  //                 SizedBox(height: size.height * 0.01),
  //               ],
  //             ),
  //           ),
  //         ),
  //       ),
  //     ),
  //   );
  // }
}

class RideCancellationReason {
  final String id;
  final String reason;

  RideCancellationReason({required this.id, required this.reason});
}
