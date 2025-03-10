// ignore_for_file: avoid_print

import 'package:deliver_client/widgets/inProgress_Detailed_list.dart';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:deliver_client/models/inprogress_ride_model.dart';

import '../models/update_booking_status_model.dart';

String? userId;

class InProgressList extends StatefulWidget {
  final int? index;
  final Map? singleData;
  final Map? multipleData;
  final String? passCode;
  final String? currentBookingId;
  final UpdateBookingStatusModel? riderData;
  final String? bookingDestinationId;

  const InProgressList({
    super.key,
    this.index,
    this.singleData,
    this.multipleData,
    this.passCode,
    this.currentBookingId,
    this.riderData,
    this.bookingDestinationId,
  });

  @override
  State<InProgressList> createState() => _InProgressListState();
}

class _InProgressListState extends State<InProgressList> {
  DateTime? timeAdded;
  bool isLoading = false;
  String? baseUrl = dotenv.env['BASE_URL'];
  String? imageUrl = dotenv.env['IMAGE_URL'];

  InProgressRideModel inProgressRideModel = InProgressRideModel();

  inProgressRides() async {
    try {
      setState(() {
        isLoading = true;
      });
      SharedPreferences sharedPref = await SharedPreferences.getInstance();
      userId = sharedPref.getString('userId');
      String apiUrl = "$baseUrl/get_bookings_ongoing_customers";
      debugPrint("apiUrl: $apiUrl");
      debugPrint("userId: $userId");
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
        body: {
          "users_customers_id": userId,
        },
      );
      final responseString = response.body;
      debugPrint("response: $responseString");
      debugPrint("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        inProgressRideModel = inProgressRideModelFromJson(responseString);
        debugPrint('inProgressRideModel status: ${inProgressRideModel.status}');
        setState(() {
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint('Something went wrong = ${e.toString()}');
      setState(() {
        isLoading = false;
      });
      return null;
    }
  }

  String formatTimeDifference(DateTime dateTime) {
    Duration difference = DateTime.now().difference(dateTime);

    if (difference.inDays >= 365) {
      int years = (difference.inDays / 365).floor();
      return "${years == 1 ? '1 year' : '$years years'} ago";
    } else if (difference.inDays >= 30) {
      int months = (difference.inDays / 30).floor();
      return "${months == 1 ? '1 month' : '$months months'} ago";
    } else if (difference.inDays >= 7) {
      int weeks = (difference.inDays / 7).floor();
      return "${weeks == 1 ? '1 week' : '$weeks weeks'} ago";
    } else if (difference.inDays > 0) {
      return "${difference.inDays == 1 ? '1 day' : '${difference.inDays} days'} ago";
    } else if (difference.inHours > 0) {
      return "${difference.inHours == 1 ? '1 hour' : '${difference.inHours} hours'} ago";
    } else if (difference.inMinutes > 0) {
      return "${difference.inMinutes == 1 ? '1 minute' : '${difference.inMinutes} mins'} ago";
    } else {
      return "Just now";
    }
  }

  @override
  void initState() {
    super.initState();
    inProgressRides();
    print("riderData: ${widget.riderData}");
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return isLoading
        ? Center(
            child: Container(
              width: 100,
              height: 100,
              color: transparentColor,
              child: Lottie.asset(
                'assets/images/loading-icon.json',
                fit: BoxFit.cover,
              ),
            ),
          )
        : inProgressRideModel.data != null
            ? ListView.builder(
                physics: const BouncingScrollPhysics(),
                shrinkWrap: true,
                scrollDirection: Axis.vertical,
                itemCount: inProgressRideModel.data?.length,
                itemBuilder: (BuildContext context, int index) {
                  int reverseIndex =
                      inProgressRideModel.data!.length - 1 - index;
                  timeAdded = DateTime.parse(
                      "${inProgressRideModel.data![reverseIndex].dateModified}");
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        formatTimeDifference(timeAdded!),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          color: sheetBarrierColor,
                          fontSize: 14,
                          fontFamily: 'Inter-Medium',
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                      Card(
                        color: whiteColor,
                        elevation: 5,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.only(
                            left: 15,
                            right: 10,
                            bottom: 15,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              SizedBox(height: size.height * 0.02),
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Container(
                                      color: transparentColor,
                                      width: 60,
                                      height: 65,
                                      child: inProgressRideModel.data![reverseIndex].bookingsFleet?[0].usersFleet?.profilePic != null
                                          ? FadeInImage(
                                        placeholder: const AssetImage("assets/images/user-profile.png"),
                                        image: NetworkImage(
                                          '$imageUrl${inProgressRideModel.data![reverseIndex].bookingsFleet?[0].usersFleet?.profilePic}',
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
                                      //     inProgressRideModel
                                      //                     .data![reverseIndex]
                                      //                     .bookingsFleet !=
                                      //                 null &&
                                      //             inProgressRideModel
                                      //                 .data![reverseIndex]
                                      //                 .bookingsFleet!
                                      //                 .isNotEmpty
                                      //         ? '$imageUrl${inProgressRideModel.data![reverseIndex].bookingsFleet?[0].usersFleet?.profilePic}'
                                      //         : 'default_image_url_here', // replace with your default image URL
                                      //   ),
                                      //   fit: BoxFit.cover,
                                      // ),
                                    ),
                                  ),
                                  SizedBox(width: size.width * 0.02),
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Container(
                                            color: transparentColor,
                                            width: size.width * 0.44,
                                            child: AutoSizeText(
                                              '${inProgressRideModel.data![reverseIndex].bookingsFleet?[0].usersFleet?.firstName} ${inProgressRideModel.data![reverseIndex].bookingsFleet?[0].usersFleet?.lastName}',
                                              textAlign: TextAlign.left,
                                              style: TextStyle(
                                                color: drawerTextColor,
                                                fontSize: 16,
                                                fontFamily: 'Syne-Bold',
                                              ),
                                              minFontSize: 16,
                                              maxFontSize: 16,
                                              maxLines: 1,
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          SizedBox(width: size.width * 0.04),
                                          Stack(
                                            children: [
                                              SvgPicture.asset(
                                                'assets/images/star-with-container-icon.svg',
                                                width: 45,
                                              ),
                                              Padding(
                                                padding: const EdgeInsets.only(
                                                  left: 20,
                                                  top: 1.5,
                                                ),
                                                child: Text(
                                                  '${inProgressRideModel.data![reverseIndex].bookingsFleet?[0].usersFleet?.bookingsRatings}',
                                                  textAlign: TextAlign.center,
                                                  style: TextStyle(
                                                    color: blackColor,
                                                    fontSize: 12,
                                                    fontFamily: 'Inter-Regular',
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: size.height * 0.01),
                                      Row(
                                        children: [
                                          Text(
                                            '${inProgressRideModel.data![reverseIndex].bookingsFleet?[0].usersFleetVehicles?.color} ',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: textHaveAccountColor,
                                              fontSize: 12,
                                              fontFamily: 'Inter-Regular',
                                            ),
                                          ),
                                          Text(
                                            '${inProgressRideModel.data![reverseIndex].bookingsFleet?[0].usersFleetVehicles?.model}',
                                            textAlign: TextAlign.left,
                                            style: TextStyle(
                                              color: textHaveAccountColor,
                                              fontSize: 12,
                                              fontFamily: 'Inter-Regular',
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: size.height * 0.005),
                                      Text(
                                        '${inProgressRideModel.data![reverseIndex].bookingsFleet?[0].usersFleetVehicles?.vehicleRegistrationNo}',
                                        textAlign: TextAlign.left,
                                        style: TextStyle(
                                          color: textHaveAccountColor,
                                          fontSize: 12,
                                          fontFamily: 'Inter-Regular',
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                              SizedBox(height: size.height * 0.01),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  Text(
                                    'Ride in progress with this\ncaptain',
                                    textAlign: TextAlign.left,
                                    style: TextStyle(
                                      color: blackColor,
                                      fontSize: 14,
                                      fontFamily: 'Inter-Regular',
                                    ),
                                  ),
                                  GestureDetector(
                                    onTap: () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) =>
                                              InProgressDetailedScreen(
                                            passCode: widget.passCode,
                                            singleData: widget.singleData,
                                            multipleData: widget.multipleData,
                                            riderData: widget.riderData,
                                            currentBookingId:
                                                inProgressRideModel
                                                    .data![reverseIndex]
                                                    .bookingsId
                                                    .toString(),
                                            bookingDestinationId:
                                                widget.bookingDestinationId,
                                          ),
                                        ),
                                      );
                                    },
                                    child: detailButtonGradientSmall(
                                        "See detail", context),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(height: size.height * 0.02),
                    ],
                  );
                },
              )
            : Padding(
                padding: const EdgeInsets.only(top: 180),
                child: Center(
                  child: Column(
                    children: [
                      Lottie.asset('assets/images/no-data-icon.json'),
                      SizedBox(height: size.height * 0.04),
                      Text(
                        "No Ride is In Progress",
                        style: TextStyle(
                          color: textHaveAccountColor,
                          fontSize: 24,
                          fontFamily: 'Syne-SemiBold',
                        ),
                      ),
                    ],
                  ),
                ),
              );
  }
}
