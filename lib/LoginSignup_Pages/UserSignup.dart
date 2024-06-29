// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:lawhub/Utils/Utilities.dart';
import 'package:lawhub/model/Province_City.dart';
import 'package:lawhub/services/Province_City.dart';
import 'package:lawhub/widgets/Fonts.dart';
import 'package:lawhub/widgets/Themes.dart';
import '../User_Pages/UserAppBar&NavBar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserSignup extends StatefulWidget {
  final String email;
  final String name;
  final String password;
  const UserSignup({super.key, required this.email, required this.name, required this.password});

  @override
  State<UserSignup> createState() => _UserSignupState();
}

class _UserSignupState extends State<UserSignup> {

  final fireStore  = FirebaseFirestore.instance.collection('Users');

  bool isPhoneValid = false;

  bool _isValidPhoneNumber(String phoneNumber) {
    RegExp phoneRegExp = RegExp(r'^\+\d{12}$');
    return phoneRegExp.hasMatch(phoneNumber);
  }

  List<String> dob = [];

  DateTime _dateTime = DateTime.now();
  var isSelected = true;
  void _showDatePicker() {
    showDatePicker(
      builder: (context, child) {
        return Theme(
          data: Theme.of(context).copyWith(
            colorScheme: const ColorScheme.highContrastLight(
              primary: Colors.blue,
              onPrimary: Colors.white,
              onSurface: Colors.black,
            ),
            textButtonTheme: TextButtonThemeData(
              style: TextButton.styleFrom(
                foregroundColor: Colors.blue, // button text color
              ),
            ),
          ),
          child: child!,
        );
      },
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1980),
      lastDate: DateTime.now(),
    ).then((value) {
      setState(() {
        _dateTime = value!;
        isSelected = false;
        dob.clear();
        dob.add(_dateTime.day.toString());
        dob.add(_dateTime.month.toString());
        dob.add(_dateTime.year.toString());
      });
    });
  }

  List<Provinces> provinceList = [];
  List<City> citiesList = [];
  List<City> tempList = [];

  String? province;
  String? cities;

  String? provinceText;
  String? cityText;

  var isLoading = true;
  var isProvinceSelected = true;
  var isCitySelected = true;

  populateDropDown() async {
    Temperatures data = await getData();
    provinceList = data.province;
    citiesList = data.cities;
    isLoading = false;
    setState(() {});
  }

  @override
  void initState() {
    populateDropDown();
    super.initState();
  }

  bool isDataLoading = false;
  void insertDataEmail(){
    fireStore.doc(widget.email).set({
      'id' : widget.email,
      'emailPhone': widget.email,
      'name' : widget.name,
      'dob' : dob,
      'province' : provinceText,
      'city' : cityText,
      'profilePic': 'null',
    }).then((value) => {
      setState(() {
        isDataLoading = false;
      }),
      Utilities().successMsg('Successfully Registered'),
      Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAppBarNavBar())),
    }).onError((error, stackTrace) => {
      setState(() {
        isDataLoading = false;
      }),
      Utilities().errorMsg(error.toString()),
    });
  }

  void insertDataPhone(){
    fireStore.doc('${widget.email}@gmail.com').set({
      'id' : '${widget.email}@gmail.com',
      'emailPhone': widget.email,
      'name' : widget.name,
      'dob' : dob,
      'province' : provinceText,
      'city' : cityText,
      'firstPass': widget.password,
      'password' : widget.password,
      'profilePic': 'null',
    }).then((value) => {
      setState(() {
        isDataLoading = false;
      }),
      Utilities().successMsg('Successfully Registered'),
      Navigator.push(context, MaterialPageRoute(builder: (context) => const UserAppBarNavBar())),
    }).onError((error, stackTrace) => {
      setState(() {
        isDataLoading = false;
      }),
      Utilities().errorMsg(error.toString()),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: Colors.blue,
        body: Stack(
          children: [
            Padding(
              padding: EdgeInsets.only(
                  top: 0.03 * MediaQuery.of(context).size.height),
              child: TopLogo(fontColor: Colors.white),
            ),
            SafeArea(
              child: CustomScrollView(
                slivers: [
                  SliverFillRemaining(
                    hasScrollBody: false,
                    child: Container(
                        margin: EdgeInsets.only(
                            top: 0.15 * MediaQuery.of(context).size.height),
                        width: double.infinity,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(45),
                                topRight: Radius.circular(45)),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black45,
                                  blurRadius: 15.0,
                                  spreadRadius: 5.0)
                            ]),
                        child: Column(
                          children: [
                            SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                      left: 0.08 *
                                          MediaQuery.of(context).size.width,
                                      top: 0.07 *
                                          MediaQuery.of(context).size.height),
                                  child: const BoldFont(text: "Complete Profile"),
                                )),
                            SizedBox(
                                width: double.infinity,
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    left: 0.08 *
                                        MediaQuery.of(context).size.width,
                                  ),
                                  child: const NormalFont(
                                      text:
                                          "Please Provide the Following information \nto complete account creation"),
                                )),
                            Container(
                              child: isLoading
                                  ? SizedBox(
                                      child: Padding(
                                        padding: EdgeInsets.only(top: 0.2 * MediaQuery.of(context).size.height),
                                        child: const SpinKitCircle(
                                            color: Colors.blue, size: 34),
                                      ))
                                  : Column(
                                      children: [
                                        SizedBox(
                                            width: 300,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                top: 0.07 *
                                                    MediaQuery.of(context).size.height,
                                              ),
                                              child: const NormalFont(
                                                  text:
                                                      "Select your Date of Birth"),
                                            )),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 0.01 *
                                                MediaQuery.of(context).size.height,
                                          ),
                                          child: MaterialButton(
                                            onPressed: _showDatePicker,
                                            child: Container(
                                              width: 300,
                                              height: 49,
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
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  isSelected
                                                      ? Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(left: 20),
                                                          child: Text(
                                                            'Date of Birth',
                                                            style: TextStyle(
                                                                fontFamily:
                                                                    'roboto',
                                                                color: Colors.grey
                                                                    .shade500,
                                                                fontSize: 16),
                                                          ),
                                                        )
                                                      : Padding(
                                                          padding:
                                                              const EdgeInsets
                                                                  .only(left: 20),
                                                          child: Text(
                                                              '${_dateTime.day}-${_dateTime.month}-${_dateTime.year}',
                                                            style: const TextStyle(
                                                                fontFamily:
                                                                'roboto',
                                                                color: Colors
                                                                    .black,
                                                                fontSize: 15),
                                                          ),
                                                          ),
                                                  Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            right: 10),
                                                    child: Icon(
                                                        Icons.arrow_drop_down,
                                                        size: 23,
                                                        color:
                                                            Colors.grey.shade700),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                            width: 300,
                                            child: Padding(
                                              padding: EdgeInsets.only(
                                                top: 0.03 *
                                                    MediaQuery.of(context).size.height,
                                              ),
                                              child: const NormalFont(
                                                  text:
                                                      "Select Province and City"),
                                            )),
                                        Padding(
                                          padding: EdgeInsets.only(
                                            top: 0.01 *
                                                MediaQuery.of(context).size.height,
                                          ),
                                          child: Container(
                                              width: 300,
                                              height: 49,
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
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    left: 20, right: 10),
                                                child: DropdownButton(
                                                  iconSize: 24.5,
                                                  hint: const Text(
                                                    "Select Province",
                                                    style: TextStyle(
                                                        fontFamily: 'roboto',
                                                        fontSize: 16,
                                                        color: Colors.grey),
                                                  ),
                                                  isExpanded: true,
                                                  underline: const SizedBox(),
                                                  value: province,
                                                  items: provinceList.map((e) {
                                                    return DropdownMenuItem(
                                                      value: e.id.toString(),
                                                      child: Text(e.name),
                                                    );
                                                  }).toList(),
                                                  onChanged: (newValue) {
                                                    setState(() {
                                                      cities = null;
                                                      province = newValue.toString();
                                                      tempList = citiesList.where((element) => element.provinceId.toString() == province.toString()).toList();
                                                      isProvinceSelected = false;
                                                      provinceText = provinceList[int.parse(province.toString()) - 1].name;
                                                     });

                                                  },

                                                ),
                                              )),
                                        ),
                                        isProvinceSelected
                                            ? const SizedBox()
                                            : Padding(
                                              padding: EdgeInsets.only(
                                                top: 0.03 *
                                                MediaQuery.of(context).size.height,
                                              ),
                                              child: Container(
                                                  width: 300,
                                                  height: 49,
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
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.only(
                                                            left: 20,
                                                            right: 10),
                                                    child: DropdownButton(
                                                      iconSize: 24.5,
                                                      hint: const Text(
                                                        "Select City",
                                                        style: TextStyle(
                                                            fontFamily:
                                                                'roboto',
                                                            fontSize: 16,
                                                            color:
                                                                Colors.grey),
                                                      ),
                                                      isExpanded: true,
                                                      underline:
                                                          const SizedBox(),
                                                      value: cities,
                                                      items:
                                                          tempList.map((e) {
                                                        return DropdownMenuItem(
                                                          value:
                                                              e.id.toString(),
                                                          child: Text(e.name),
                                                        );
                                                      }).toList(),
                                                      onChanged: (newValue) {
                                                        setState(() {
                                                          cities = newValue
                                                              .toString();
                                                          isCitySelected =
                                                              false;
                                                          cityText = tempList[int.parse(cities.toString()) - 1].name;
                                                        });
                                                      },
                                                    ),
                                                  )),
                                            ),
                                        isCitySelected
                                            ? const SizedBox()
                                            : Padding(
                                              padding: EdgeInsets.only(
                                                top: 0.03 * MediaQuery.of(context).size.height),
                                              child: SizedBox(
                                                  child: ElevatedButton(
                                                    onPressed: () {
                                                      setState(() {
                                                        isDataLoading = true;
                                                      });
                                                      if(_isValidPhoneNumber(widget.email)) {
                                                        insertDataPhone();
                                                      }
                                                      else {
                                                        insertDataEmail();
                                                      }
                                                    },
                                                    style: ElevatedButton.styleFrom(
                                                        fixedSize: const Size(200, 20),
                                                        backgroundColor: Colors.blue,
                                                        shape: RoundedRectangleBorder(
                                                            borderRadius: BorderRadius.circular(15))),
                                                    child: isDataLoading
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
                                                      : const Text('Next',
                                                        style: TextStyle(
                                                          color: Colors.white,
                                                          fontFamily:
                                                          'roboto',
                                                          fontSize: 16,
                                                          fontWeight:
                                                          FontWeight.bold,
                                                        )),
                                                  ),
                                                ),
                                            ),
                                      ],
                                    ),
                            ),
                          ],
                        )),
                  )
                ],
              ),
            )
          ],
        ));
  }
}
