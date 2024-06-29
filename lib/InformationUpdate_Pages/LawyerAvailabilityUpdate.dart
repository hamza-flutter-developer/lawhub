// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'InfoUpdated.dart';

class LawyerAvailabilityUpdate extends StatefulWidget{
  final Map<String, dynamic> userData;
  final bool isUser;
  const LawyerAvailabilityUpdate({super.key, required this.isUser, required this.userData});

  @override
  State<LawyerAvailabilityUpdate> createState() => _LawyerAvailabilityUpdateState();
}

class _LawyerAvailabilityUpdateState extends State<LawyerAvailabilityUpdate> {

  Map<String, bool> selectedDays = {
    'Monday': false,
    'Tuesday': false,
    'Wednesday': false,
    'Thursday': false,
    'Friday': false,
    'Saturday': false,
  };

  Map<String, String?> selectedTimeSlots = {
    'Monday': null,
    'Tuesday': null,
    'Wednesday': null,
    'Thursday': null,
    'Friday': null,
    'Saturday': null,
  };

  List<String> timeSlots = [
    '7:00 AM - 2.00 PM',
    '7:00 AM - 12:00 PM',
    '8:00 AM - 3.00 PM',
    '8:00 AM - 1:00 PM',
  ];

  bool isLoading = false;

  void storeAvailabilityInFirestore(Map<String, bool> selectedDays, Map<String, String?> selectedTimeSlots) async {
    List<Map<String, dynamic>> availabilityList = [];
    selectedDays.forEach((day, isSelected) {
      if (isSelected) {
        String? timeSlot = selectedTimeSlots[day];
        if (timeSlot != null) {
          availabilityList.add({'day': day, 'timeSlot': timeSlot});
        }
      }
    });
    await FirebaseFirestore.instance.collection('Lawyers').doc(widget.userData['id']).update({'availability': availabilityList}).then((value) {
      Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) =>
                  UserInfoUpdated(text: 'Availability', isUser: widget.isUser)));
      setState(() {
        isLoading = false;
      });
    });
  }

  @override
  void initState() {
    for (int i = 0; i < widget.userData['availability'].length; i++) {
      String day = widget.userData['availability'][i]['day'];
      if (selectedDays.containsKey(day)) {
        selectedDays[day] = true;
        selectedTimeSlots[day] = widget.userData['availability'][i]['timeSlot'];
      }
    }
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          toolbarHeight: 70,
          leadingWidth: 40,
          backgroundColor: Colors.blue,
          leading: Padding(
            padding: const EdgeInsets.only(top: 8,left: 10),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white,),
              onPressed: () {
                // Navigate back to the previous page or screen
                Navigator.of(context).pop();
              },
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text(
              "Availability Update",
              style: TextStyle(
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  color: Colors.white),
            ),
          ),
          centerTitle: true,

          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)),
          ),
        ),
      ),
      body: Column(
        children: [
          const SizedBox(
            width: double.infinity,
            child: Padding(
              padding: EdgeInsets.only(
                left: 30,
                top: 40,
              ),
              child: Text(
                "Select your Office Days and Time:",
                style: TextStyle(
                  fontFamily: 'roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(30),
              children: selectedDays.keys.map((day) {
                return Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Container(
                    height: 55,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(15),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.5),
                          spreadRadius: 2,
                          blurRadius: 7,
                          offset: const Offset(1, 1), // changes position of shadow
                        )
                      ],),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Checkbox(
                          checkColor: Colors.white,
                          activeColor: Colors.blue,
                          value: selectedDays[day],
                          onChanged: (value) {
                            setState(() {
                              selectedDays[day] = value!;
                            });
                          },
                        ),
                        const SizedBox(width: 2),
                        Text(
                          day,
                          style: const TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 15,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const Spacer(),
                        selectedDays[day] ?? false
                            ? DropdownButton<String>(
                          isExpanded: false,
                          underline: const SizedBox(),
                          value: selectedTimeSlots[day],
                          hint: const Padding(
                            padding: EdgeInsets.only(left: 60),
                            child: Text('Time Slot', style: TextStyle(fontSize: 14),),),
                          items: timeSlots.map((slot) {
                            return DropdownMenuItem<String>(
                              value: slot,
                              child: Text(slot, style: const TextStyle(fontSize: 14)),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedTimeSlots[day] = value;
                            });
                          },
                        )
                            : const SizedBox(),
                        const SizedBox(width: 15),
                      ],
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ],
      ),
      floatingActionButton:
      Padding(
        padding: const EdgeInsets.only(left: 35),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  setState(() {
                    isLoading = true;
                  });
                  storeAvailabilityInFirestore(selectedDays, selectedTimeSlots);
                },
                child: Container(
                  height: 40,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: isLoading
                      ? Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                          color: Colors.blue,
                          height: 20,
                          width: 20,
                          child: const SpinKitCircle(color: Colors.white,size: 20)),
                      const SizedBox(width: 5,),
                      const Text('Loading',
                          style: TextStyle(
                            color: Colors.white,
                            fontFamily: 'roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ],
                  )
                      : const Center(child: Text('Next',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'roboto',
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      )),),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}