// ignore_for_file: avoid_print

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';
import 'package:deliver_client/utils/baseurl.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deliver_client/models/get_reason_model.dart';

// Widget reportBoxes(BuildContext context, title1, title2, title3, title4) {

// }

class ReportBoxes extends StatefulWidget {
  const ReportBoxes({super.key});

  @override
  State<ReportBoxes> createState() => _ReportBoxesState();
}

class _ReportBoxesState extends State<ReportBoxes> {
  bool isSelected1 = false;
  bool isSelected2 = false;
  bool isSelected3 = false;
  bool isSelected4 = false;

  GetReasonModel getReasonModel = GetReasonModel();

  getReason() async {
    try {
      String apiUrl = "$baseUrl/get_bookings_reports_reasons";
      print("apiUrl: $apiUrl");
      final response = await http.get(
        Uri.parse(apiUrl),
        headers: {
          'Accept': 'application/json',
        },
      );
      final responseString = response.body;
      print("response: $responseString");
      print("statusCode: ${response.statusCode}");
      if (response.statusCode == 200) {
        getReasonModel = getReasonModelFromJson(responseString);
        print('getReasonModel status: ${getReasonModel.status}');
        print('getSupportAdminModel length: ${getReasonModel.data!.length}');
        setState(() {});
      }
    } catch (e) {
      print('Something went wrong = ${e.toString()}');
      return null;
    }
  }

  @override
  void initState() {
    super.initState();
    getReason();
  }

  @override
  Widget build(BuildContext context) {
    var size = MediaQuery.of(context).size;
    return Column(
      children: [
        ListView.builder(
          physics: const BouncingScrollPhysics(),
          shrinkWrap: true,
          scrollDirection: Axis.vertical,
          itemCount: 2,
          itemBuilder: (BuildContext context, int index) {
            return GestureDetector(
              onTap: () {
                setState(() {
                  isSelected1 = true;
                  isSelected2 = false;
                  isSelected3 = false;
                  isSelected4 = false;
                });
              },
              child: Card(
                color: whiteColor,
                elevation: 3,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Container(
                  color: transparentColor,
                  width: size.width,
                  height: size.height * 0.07,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 20),
                    child: Row(
                      children: [
                        Container(
                          color: transparentColor,
                          width: size.width * 0.65,
                          child: AutoSizeText(
                            "title1",
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              color: drawerTextColor,
                              fontSize: 16,
                              fontFamily: 'Syne-Medium',
                            ),
                            minFontSize: 16,
                            maxFontSize: 16,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                        ),
                        const Spacer(),
                        isSelected1 == true
                            ? GestureDetector(
                                onTap: () {
                                  setState(() {
                                    isSelected1 = false;
                                  });
                                },
                                child: SvgPicture.asset(
                                  'assets/images/round-checkmark-icon.svg',
                                  fit: BoxFit.scaleDown,
                                ),
                              )
                            : const SizedBox(),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
        // GestureDetector(
        //   onTap: () {
        //     setState(() {
        //       isSelected1 = false;
        //       isSelected2 = true;
        //       isSelected3 = false;
        //       isSelected4 = false;
        //     });
        //   },
        //   child: Card(
        //     color: whiteColor,
        //     elevation: 3,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     child: Container(
        //       color: transparentColor,
        //       width: size.width,
        //       height: size.height * 0.07,
        //       child: Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 20),
        //         child: Row(
        //           children: [
        //             Container(
        //               color: transparentColor,
        //               width: size.width * 0.65,
        //               child: AutoSizeText(
        //                 "title2",
        //                 textAlign: TextAlign.left,
        //                 style: TextStyle(
        //                   color: drawerTextColor,
        //                   fontSize: 16,
        //                   fontFamily: 'Syne-Medium',
        //                 ),
        //                 minFontSize: 16,
        //                 maxFontSize: 16,
        //                 maxLines: 1,
        //                 overflow: TextOverflow.ellipsis,
        //               ),
        //             ),
        //             const Spacer(),
        //             isSelected2 == true
        //                 ? GestureDetector(
        //                     onTap: () {
        //                       setState(() {
        //                         isSelected2 = false;
        //                       });
        //                     },
        //                     child: SvgPicture.asset(
        //                       'assets/images/round-checkmark-icon.svg',
        //                       fit: BoxFit.scaleDown,
        //                     ),
        //                   )
        //                 : const SizedBox(),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // GestureDetector(
        //   onTap: () {
        //     setState(() {
        //       isSelected1 = false;
        //       isSelected2 = false;
        //       isSelected3 = true;
        //       isSelected4 = false;
        //     });
        //   },
        //   child: Card(
        //     color: whiteColor,
        //     elevation: 3,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     child: Container(
        //       color: transparentColor,
        //       width: size.width,
        //       height: size.height * 0.07,
        //       child: Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 20),
        //         child: Row(
        //           children: [
        //             Container(
        //               color: transparentColor,
        //               width: size.width * 0.65,
        //               child: AutoSizeText(
        //                 "title3",
        //                 textAlign: TextAlign.left,
        //                 style: TextStyle(
        //                   color: drawerTextColor,
        //                   fontSize: 16,
        //                   fontFamily: 'Syne-Medium',
        //                 ),
        //                 minFontSize: 16,
        //                 maxFontSize: 16,
        //                 maxLines: 1,
        //                 overflow: TextOverflow.ellipsis,
        //               ),
        //             ),
        //             const Spacer(),
        //             isSelected3 == true
        //                 ? GestureDetector(
        //                     onTap: () {
        //                       setState(() {
        //                         isSelected3 = false;
        //                       });
        //                     },
        //                     child: SvgPicture.asset(
        //                       'assets/images/round-checkmark-icon.svg',
        //                       fit: BoxFit.scaleDown,
        //                     ),
        //                   )
        //                 : const SizedBox(),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
        // GestureDetector(
        //   onTap: () {
        //     setState(() {
        //       isSelected1 = false;
        //       isSelected2 = false;
        //       isSelected3 = false;
        //       isSelected4 = true;
        //     });
        //   },
        //   child: Card(
        //     color: whiteColor,
        //     elevation: 3,
        //     shape: RoundedRectangleBorder(
        //       borderRadius: BorderRadius.circular(10),
        //     ),
        //     child: Container(
        //       color: transparentColor,
        //       width: size.width,
        //       height: size.height * 0.07,
        //       child: Padding(
        //         padding: const EdgeInsets.symmetric(horizontal: 20),
        //         child: Row(
        //           children: [
        //             Container(
        //               color: transparentColor,
        //               width: size.width * 0.65,
        //               child: AutoSizeText(
        //                 "title4",
        //                 textAlign: TextAlign.left,
        //                 style: TextStyle(
        //                   color: drawerTextColor,
        //                   fontSize: 16,
        //                   fontFamily: 'Syne-Medium',
        //                 ),
        //                 minFontSize: 16,
        //                 maxFontSize: 16,
        //                 maxLines: 1,
        //                 overflow: TextOverflow.ellipsis,
        //               ),
        //             ),
        //             const Spacer(),
        //             isSelected4 == true
        //                 ? GestureDetector(
        //                     onTap: () {
        //                       setState(() {
        //                         isSelected4 = false;
        //                       });
        //                     },
        //                     child: SvgPicture.asset(
        //                       'assets/images/round-checkmark-icon.svg',
        //                       fit: BoxFit.scaleDown,
        //                     ),
        //                   )
        //                 : const SizedBox(),
        //           ],
        //         ),
        //       ),
        //     ),
        //   ),
        // ),
      ],
    );
  }
}
