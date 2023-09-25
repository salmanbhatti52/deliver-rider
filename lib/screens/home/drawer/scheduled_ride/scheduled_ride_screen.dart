import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:deliver_client/utils/colors.dart';

class ScheduledRideScreen extends StatefulWidget {
  final int? selectedRadio;
  const ScheduledRideScreen({super.key, this.selectedRadio});

  @override
  State<ScheduledRideScreen> createState() => _ScheduledRideScreenState();
}

class _ScheduledRideScreenState extends State<ScheduledRideScreen> {
  DateTime? selectedDate;
  DateTime? selectedTime;

  @override
  Widget build(BuildContext context) {
    // var size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        backgroundColor: bgColor,
        elevation: 0,
        scrolledUnderElevation: 0,
        leading: GestureDetector(
          onTap: () {
            Navigator.pop(context);
          },
          child: Padding(
            padding: const EdgeInsets.only(left: 20),
            child: SvgPicture.asset(
              'assets/images/back-icon.svg',
              width: 22,
              height: 22,
              fit: BoxFit.scaleDown,
            ),
          ),
        ),
        title: Text(
          "Scheduled Rides",
          textAlign: TextAlign.center,
          style: TextStyle(
            color: blackColor,
            fontSize: 20,
            fontFamily: 'Syne-Bold',
          ),
        ),
        centerTitle: true,
      ),
    );
  }
}
