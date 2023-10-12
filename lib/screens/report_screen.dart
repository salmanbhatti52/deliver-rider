import 'dart:io';
import 'dart:convert';
import 'package:lottie/lottie.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:file_picker/file_picker.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:deliver_client/widgets/buttons.dart';
import 'package:deliver_client/widgets/report_boxes.dart';
import 'package:deliver_client/models/search_rider_model.dart';
import 'package:deliver_client/screens/home/home_page_screen.dart';

class ReportScreen extends StatefulWidget {
  final SearchRiderData? riderData;
  final String? currentBookingId;
  const ReportScreen({
    super.key,
    this.riderData,
    this.currentBookingId,
  });

  @override
  State<ReportScreen> createState() => _ReportScreenState();
}

class _ReportScreenState extends State<ReportScreen> {
  TextEditingController otherController = TextEditingController();

  String? base64ImageString;
  String? base64VideoString;
  String? base64AudioString;

  Future<String?> pickImage() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['jpg', 'jpeg', 'png', 'gif'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      if (file.extension == 'jpg' ||
          file.extension == 'jpeg' ||
          file.extension == 'png' ||
          file.extension == 'gif') {
        // Read the file as bytes
        final Uint8List bytes = File(file.path!).readAsBytesSync();

        // Convert the bytes to a Base64 encoded string
        base64ImageString = base64Encode(bytes);
        print("Selected image file path: ${file.path}");
        print("base64ImageString: $base64AudioString");

        return base64ImageString;
      } else {
        // Handle unsupported file type
        Fluttertoast.showToast(
          msg: "Unspported file format!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: toastColor,
          textColor: whiteColor,
          fontSize: 12,
        );
      }
    } else {
      // User canceled the file picker
      return null;
    }
    return null; // Return null if no valid file was selected
  }

  Future<String?> pickVideo() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp4', 'mkv', 'mov', 'avi'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      if (file.extension == 'mp4' ||
          file.extension == 'mkv' ||
          file.extension == 'mov' ||
          file.extension == 'avi') {
        // Read the file as bytes
        final Uint8List bytes = File(file.path!).readAsBytesSync();

        // Convert the bytes to a Base64 encoded string
        base64VideoString = base64Encode(bytes);
        print("Selected video file path: ${file.path}");
        print("base64VideoString: $base64VideoString");

        return base64VideoString;
      } else {
        // Handle unsupported file type
        Fluttertoast.showToast(
          msg: "Unspported file format!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: toastColor,
          textColor: whiteColor,
          fontSize: 12,
        );
      }
    } else {
      // User canceled the file picker
      return null;
    }
    return null; // Return null if no valid file was selected
  }

  Future<String?> pickAudio() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['mp3', 'm4a', 'wav'],
    );

    if (result != null) {
      PlatformFile file = result.files.first;

      if (file.extension == 'mp3' ||
          file.extension == 'm4a' ||
          file.extension == 'wav') {
        // Read the file as bytes
        final Uint8List bytes = File(file.path!).readAsBytesSync();

        // Convert the bytes to a Base64 encoded string
        base64AudioString = base64Encode(bytes);
        print("Selected audio file path: ${file.path}");
        print("base64AudioString: $base64AudioString");

        return base64AudioString;
      } else {
        // Handle unsupported file type
        Fluttertoast.showToast(
          msg: "Unspported file format!",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          timeInSecForIosWeb: 2,
          backgroundColor: toastColor,
          textColor: whiteColor,
          fontSize: 12,
        );
      }
    } else {
      // User canceled the file picker
      return null;
    }
    return null; // Return null if no valid file was selected
  }

  // Future<void> pickImage() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['jpg', 'jpeg', 'png'],
  //   );

  //   if (result != null) {
  //     PlatformFile file = result.files.first;

  //     if (file.extension == 'jpg' ||
  //         file.extension == 'jpeg' ||
  //         file.extension == 'png') {
  //       // Handle the selected image file
  //       // Read the file as bytes
  //       print("Selected image file path: ${file.path}");
  //       final Uint8List bytes = File(file.path!).readAsBytesSync();
  //       // Convert the bytes to a Base64 encoded string
  //       String? base64ImageString = base64Encode(bytes);
  //       return base64ImageString;
  //     } else {
  //       // Handle unsupported file type
  //       Fluttertoast.showToast(
  //         msg: "Unspported file format!",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 2,
  //         backgroundColor: toastColor,
  //         textColor: whiteColor,
  //         fontSize: 12,
  //       );
  //     }
  //   } else {
  //     // User canceled the file picker
  //     return;
  //   }
  // }

  // Future<void> pickVideo() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['mp4', 'mkv', 'mov', 'avi'],
  //   );

  //   if (result != null) {
  //     PlatformFile file = result.files.first;

  //     if (file.extension == 'mp4' ||
  //         file.extension == 'mkv' ||
  //         file.extension == 'mov' ||
  //         file.extension == 'avi') {
  //       // Handle the selected video file
  //       // You can display the video thumbnail or do any other processing here
  //       print("Selected video file path: ${file.path}");
  //     } else {
  //       // Handle unsupported file type
  //       Fluttertoast.showToast(
  //         msg: "Unspported file format!",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 2,
  //         backgroundColor: toastColor,
  //         textColor: whiteColor,
  //         fontSize: 12,
  //       );
  //     }
  //   } else {
  //     // User canceled the file picker
  //     return;
  //   }
  // }

  // Future<void> pickAudio() async {
  //   FilePickerResult? result = await FilePicker.platform.pickFiles(
  //     type: FileType.custom,
  //     allowedExtensions: ['mp3', 'm4a', 'wav'],
  //   );

  //   if (result != null) {
  //     PlatformFile file = result.files.first;

  //     if (file.extension == 'mp3' ||
  //         file.extension == 'm4a' ||
  //         file.extension == 'wav') {
  //       // Handle the selected audio file
  //       // You can play the audio or do any other processing here
  //       print("Selected audio file path: ${file.path}");
  //     } else {
  //       // Handle unsupported file type
  //       Fluttertoast.showToast(
  //         msg: "Unspported file format!",
  //         toastLength: Toast.LENGTH_SHORT,
  //         gravity: ToastGravity.BOTTOM,
  //         timeInSecForIosWeb: 2,
  //         backgroundColor: toastColor,
  //         textColor: whiteColor,
  //         fontSize: 12,
  //       );
  //     }
  //   } else {
  //     // User canceled the file picker
  //     return;
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      child: Scaffold(
          backgroundColor: bgColor,
          appBar: AppBar(
            backgroundColor: bgColor,
            elevation: 0,
            scrolledUnderElevation: 0,
            leading: Padding(
              padding: const EdgeInsets.only(left: 20),
              child: GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: SvgPicture.asset(
                  'assets/images/back-icon.svg',
                  width: 22,
                  height: 22,
                  fit: BoxFit.scaleDown,
                ),
              ),
            ),
            title: Text(
              "Report Driver",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: blackColor,
                fontSize: 20,
                fontFamily: 'Syne-Bold',
              ),
            ),
            centerTitle: true,
          ),
          body: widget.riderData != null
              ? Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        SizedBox(height: size.height * 0.03),
                        Center(
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(10),
                            child: Container(
                              width: size.width * 0.4,
                              height: size.height * 0.2,
                              decoration: BoxDecoration(
                                color: transparentColor,
                              ),
                              child: FadeInImage(
                                placeholder: const AssetImage(
                                  "assets/images/user-profile.png",
                                ),
                                image: NetworkImage(
                                  '$imageUrl${widget.riderData!.profilePic}',
                                ),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.03),
                        Text(
                          '${widget.riderData!.firstName} ${widget.riderData!.lastName}',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            color: drawerTextColor,
                            fontSize: 17,
                            fontFamily: 'Syne-Bold',
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Card(
                          color: whiteColor,
                          elevation: 3,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(20),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/star-icon.svg',
                                    ),
                                    SizedBox(width: size.width * 0.02),
                                    Text(
                                      '${widget.riderData!.bookingsRatings}',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: drawerTextColor,
                                        fontSize: 14,
                                        fontFamily: 'Inter-Medium',
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/car-icon.svg',
                                    ),
                                    SizedBox(width: size.width * 0.02),
                                    Text(
                                      '${widget.riderData!.trips} Trips',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: drawerTextColor,
                                        fontSize: 14,
                                        fontFamily: 'Inter-Medium',
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  children: [
                                    SvgPicture.asset(
                                      'assets/images/arrival-time-icon.svg',
                                    ),
                                    SizedBox(width: size.width * 0.02),
                                    Text(
                                      '${widget.riderData!.experience}',
                                      textAlign: TextAlign.left,
                                      style: TextStyle(
                                        color: drawerTextColor,
                                        fontSize: 14,
                                        fontFamily: 'Inter-Medium',
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Select Reason',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: drawerTextColor,
                              fontSize: 16,
                              fontFamily: 'Syne-Bold',
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        const ReportBoxes(),
                        SizedBox(height: size.height * 0.02),
                        Container(
                          height: size.height * 0.15,
                          decoration: BoxDecoration(
                            color: filledColor,
                            borderRadius: BorderRadius.circular(10),
                            border: Border.all(
                              color: filledColor,
                              width: 1.0,
                            ),
                          ),
                          child: TextFormField(
                            controller: otherController,
                            cursorColor: orangeColor,
                            keyboardType: TextInputType.text,
                            maxLines: null,
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
                                fontSize: 12,
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
                              hintText: "Any Other Reason (Optional)",
                              hintStyle: TextStyle(
                                color: hintColor,
                                fontSize: 12,
                                fontFamily: 'Inter-Light',
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'Upload Evidence',
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: drawerTextColor,
                              fontSize: 16,
                              fontFamily: 'Syne-Bold',
                            ),
                          ),
                        ),
                        SizedBox(height: size.height * 0.02),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                pickImage();
                              },
                              child: Card(
                                color: whiteColor,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  color: transparentColor,
                                  width: size.width * 0.25,
                                  height: size.height * 0.12,
                                  child: SvgPicture.asset(
                                    'assets/images/evidence-picture-icon.svg',
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                pickVideo();
                              },
                              child: Card(
                                color: whiteColor,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  color: transparentColor,
                                  width: size.width * 0.25,
                                  height: size.height * 0.12,
                                  child: SvgPicture.asset(
                                    'assets/images/evidence-video-icon.svg',
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                pickAudio();
                              },
                              child: Card(
                                color: whiteColor,
                                elevation: 3,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Container(
                                  color: transparentColor,
                                  width: size.width * 0.25,
                                  height: size.height * 0.12,
                                  child: SvgPicture.asset(
                                    'assets/images/evidence-recording-icon.svg',
                                    fit: BoxFit.scaleDown,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(height: size.height * 0.04),
                        GestureDetector(
                          onTap: () {
                            showDialog(
                              context: context,
                              barrierDismissible: false,
                              builder: (context) => confirmDialog(),
                            );
                          },
                          child: buttonGradient("SUBMIT", context),
                        ),
                        SizedBox(height: size.height * 0.02),
                      ],
                    ),
                  ),
                )
              : Center(
                  child: Container(
                    width: 100,
                    height: 100,
                    color: transparentColor,
                    child: Lottie.asset(
                      'assets/images/loading-icon.json',
                      fit: BoxFit.cover,
                    ),
                  ),
                )),
    );
  }

  Widget confirmDialog() {
    var size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () {
        return Future.value(false);
      },
      child: Dialog(
        backgroundColor: Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(40),
        ),
        insetPadding: const EdgeInsets.only(left: 20, right: 20),
        child: SizedBox(
          height: size.height * 0.59,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Align(
                    alignment: Alignment.centerRight,
                    child: Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SvgPicture.asset("assets/images/close-icon.svg"),
                    ),
                  ),
                ),
                SvgPicture.asset("assets/images/customer-notice-icon.svg"),
                Text(
                  'Customer Notice!',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: orangeColor,
                    fontSize: 24,
                    fontFamily: 'Syne-Bold',
                  ),
                ),
                Text(
                  'Lorem ipsum dolor sit amet,\nconsetetur sadipscing elitr, sed\ndiam nonumy eirmod tempor\ninvidunt ut labore et dolore',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color: blackColor,
                    fontSize: 18,
                    fontFamily: 'Syne-Regular',
                  ),
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.of(context).pushAndRemoveUntil(
                        MaterialPageRoute(
                            builder: (context) => const HomePageScreen()),
                        (Route<dynamic> route) => false);
                  },
                  child: buttonGradient('OK', context),
                ),
                SizedBox(height: size.height * 0.01),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
