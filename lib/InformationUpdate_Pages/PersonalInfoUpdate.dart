// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/InformationUpdate_Pages/InfoUpdated.dart';
import 'package:lawhub/model/Province_City.dart';
import 'package:lawhub/services/Province_City.dart';
import 'package:multiselect/multiselect.dart';


class UserPersonalInfoUpdate extends StatefulWidget{
  final Map<String, dynamic> userData;
  final bool isUser;
  const UserPersonalInfoUpdate({Key? key, required this.isUser, required this.userData}) : super(key: key);

  @override
  State<UserPersonalInfoUpdate> createState() => _UserPersonalInfoUpdateState();
}

class _UserPersonalInfoUpdateState extends State<UserPersonalInfoUpdate> {

  late final TextEditingController _nameController = TextEditingController(text: widget.userData['name']);

  final _form = GlobalKey<FormState>();

  late List dob = [widget.userData['dob'][0], widget.userData['dob'][1], widget.userData['dob'][2]];

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
        debugPrint(dob.toString());
        dob[0] = _dateTime.day.toString();
        dob[1] = _dateTime.month.toString();
        dob[2] = _dateTime.year.toString();
        debugPrint(dob.toString());
      });
    });
  }

  List<Provinces> provinceList = [];
  List<City> citiesList = [];
  List<City> tempList = [];

  String? province;
  String? cities;

  late String provinceText = widget.userData['province'];
  late String cityText = widget.userData['city'];

  var isLoading = true;

  populateDropDown() async {
    Temperatures data = await getData();
    provinceList = data.province;
    citiesList = data.cities;
    isLoading = false;
    setState(() {});
  }

  var isProcessLoading = false;

  final licenseList = [
    {'id': 1, 'name': 'Lower Court'},
    {'id': 2, 'name': 'High Court'},
    {'id': 3, 'name': 'Supreme Court'},
  ];
  String? license;
  late String licenseText = widget.userData['license'];

  List<dynamic> yearList = [];
  String? year;
  late String practicingYear = widget.userData['practicingYear'];

  List<String> expertiseList = [
    'Consumer Protection', 'Harassment Law', 'Cyber Crime',
    'Family Law', 'Civil Law', 'Criminal Law', 'Real Estate',
    'Rent Law', 'Intellectual Property', 'Banking Law',
    'Medical Law', 'Business Law', 'Tax Law',
    'Immigration', 'Constitutional Law', 'Employment & Labour',
    'International Law', 'Environment Law', 'Human Rights',
    'Defamation Law', 'Arbitration', 'Construction Law',
  ];
  late List<String> selectedExpertise = [];

  @override
  void initState() {
    if(!widget.isUser) {
      for(int i = 0; i < widget.userData['expertise'].length; i++) {
        selectedExpertise.add(widget.userData['expertise'][i]);
      }
    }
    var y = 1;
    for(var i = 2022;i >= 1980;i--){

      yearList.add({'id': y,'year': i});
      y++;
    }
    populateDropDown();
    super.initState();
  }

  void _updateUserInformation() async {
    await FirebaseFirestore.instance.collection('Users').doc(widget.userData['id']).update({'name': _nameController.text.toString(), 'dob': dob, 'province': provinceText, 'city': cityText}).then((value) {
      setState(() {
        isProcessLoading = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoUpdated(text: 'Information',isUser: widget.isUser,)));
    });
  }

  void _updateLawyerInformation() async {
    await FirebaseFirestore.instance.collection('Lawyers').doc(widget.userData['id']).update({'name': _nameController.text.toString(), 'dob': dob, 'province': provinceText, 'city': cityText,'license' : licenseText, 'practicingYear' : practicingYear, 'expertise' : selectedExpertise,}).then((value) {
      setState(() {
        isProcessLoading = false;
      });
      Navigator.push(context, MaterialPageRoute(builder: (context) => UserInfoUpdated(text: 'Information',isUser: widget.isUser,)));
    });

    }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              "Personal Information Update",
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
      backgroundColor: Colors.white,
      body: isLoading
          ? const SizedBox(
        height: double.infinity,
          width: double.infinity,
          child: Center(
            child: SpinKitCircle(
                color: Colors.blue, size: 34),
          ))
          : widget.isUser
            ? SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 30,
                          top: 40,
                          bottom: 10,
                        ),
                        child: Text(
                          "Please Enter Your Details:",
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 0.03 * MediaQuery.of(context).size.height),
                    child: Form(
                        key: _form,
                        child: Padding(
                          padding:
                          EdgeInsets.symmetric(
                              horizontal: 0.1 *
                                  MediaQuery.of(context).size.width),
                          child: Column(
                            children: [
                              const SizedBox(
                                  width: 300,
                                  child: Text('Name:', style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),)),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
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
                                  padding: const EdgeInsets.only(left: 20),
                                  child: TextFormField(
                                    controller: _nameController,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    decoration: const InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter Name";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                  width: 300,
                                  child: Text('Date of Birth:', style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),)),
                              const SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: _showDatePicker,
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
                                          '${dob[0]}-${dob[1]}-${dob[2]}',
                                          style: const TextStyle(
                                              fontFamily:
                                              'roboto',
                                              color: Colors
                                                  .black,
                                              fontSize: 15),
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
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                  width: 300,
                                  child: Text('Province:', style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),)),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
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
                                      hint: Text(
                                        provinceText,
                                        style: const TextStyle(
                                            fontFamily:
                                            'roboto',
                                            color: Colors
                                                .black,
                                            fontSize: 15),
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
                                          provinceText = provinceList[int.parse(province.toString()) - 1].name;
                                        });

                                      },

                                    ),
                                  )),
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                  width: 300,
                                  child: Text('City:', style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),)),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
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
                                      hint: Text(
                                        cityText,
                                        style: const TextStyle(
                                            fontFamily:
                                            'roboto',
                                            color: Colors
                                                .black,
                                            fontSize: 15),
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
                                          cityText = tempList[int.parse(cities.toString()) - 1].name;
                                        });
                                      },
                                    ),
                                  )),
                            ],
                          ),
                        )),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 0.03 * MediaQuery.of(context).size.height),
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isProcessLoading = true;
                        });
                        _updateUserInformation();
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(300, 20),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: isProcessLoading
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
                            fontFamily: 'roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                  const SizedBox(height: 20,),

                ],
              ),
            )
          ],
        ),
      )
            : SafeArea(
        child: CustomScrollView(
          slivers: [
            SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: [
                  const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 30,
                          top: 40,
                          bottom: 10,
                        ),
                        child: Text(
                          "Please Enter Your Details:",
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 0.03 * MediaQuery.of(context).size.height),
                    child: Form(
                        key: _form,
                        child: Padding(
                          padding:
                          EdgeInsets.symmetric(
                              horizontal: 0.1 *
                                  MediaQuery.of(context).size.width),
                          child: Column(
                            children: [
                              const SizedBox(
                                  width: 300,
                                  child: Text('Name:', style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),)),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
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
                                  padding: const EdgeInsets.only(left: 20),
                                  child: TextFormField(
                                    controller: _nameController,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    decoration: const InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none
                                      ),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide.none
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value!.isEmpty) {
                                        return "Enter Name";
                                      }
                                      return null;
                                    },
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                  width: 300,
                                  child: Text('Date of Birth:', style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),)),
                              const SizedBox(
                                height: 10,
                              ),
                              InkWell(
                                onTap: _showDatePicker,
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
                                          '${dob[0]}-${dob[1]}-${dob[2]}',
                                          style: const TextStyle(
                                              fontFamily:
                                              'roboto',
                                              color: Colors
                                                  .black,
                                              fontSize: 15),
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
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                  width: 300,
                                  child: Text('License:', style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),)),
                              const SizedBox(
                                height: 10,
                              ),
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
                                      child: Center(
                                        child: DropdownButton(
                                          iconSize: 24.5,
                                          hint: Text(
                                            licenseText,
                                            style: const TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 15,
                                              color: Colors.black,),
                                          ),
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          value: license,
                                          items: licenseList.map((e) {
                                            return DropdownMenuItem(
                                              value: e['id'].toString(),
                                              child: Text(e['name'].toString()),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              license = newValue.toString();
                                              licenseText = licenseList[int.parse(license.toString()) - 1]['name'].toString();
                                            });
                                          },
                                        ),
                                      ),
                                    )),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                  width: 300,
                                  child: Text('Practicing Law Since:', style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),)),
                              const SizedBox(
                                height: 10,
                              ),
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
                                      child: Center(
                                        child: DropdownButton(
                                          hint: Text(
                                            practicingYear,
                                            style: const TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 15,
                                              color: Colors.black,),
                                          ),
                                          isExpanded: true,
                                          underline: const SizedBox(),
                                          value: year,
                                          items: yearList.map((e) {
                                            return DropdownMenuItem(
                                              value: e['id'].toString(),
                                              child: Text(e['year'].toString()),
                                            );
                                          }).toList(),
                                          onChanged: (newValue) {
                                            setState(() {
                                              year = newValue.toString();
                                              practicingYear = yearList[int.parse(year.toString())-1]['year'].toString();
                                            });
                                          },
                                        ),
                                      ),
                                    )),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                  width: 300,
                                  child: Text('Areas of Practice:', style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),)),
                              const SizedBox(
                                height: 10,
                              ),
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
                                    child: Padding(padding: const EdgeInsets.only(left: 20, right: 10),
                                      child: DropDownMultiSelect(
                                        hint: Text(
                                          "Select At-least 1 Area",
                                          style: TextStyle(
                                            fontFamily: 'roboto',
                                            fontSize: 16,
                                            color: Colors.grey.shade500,),
                                        ),
                                        decoration: const InputDecoration(
                                          border: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                        ),
                                        selected_values_style: const TextStyle(
                                          fontFamily: 'roboto',
                                          fontSize: 16,
                                        ),

                                        options: expertiseList,
                                        selectedValues: selectedExpertise,
                                        onChanged: (value) {
                                          setState(() {
                                            selectedExpertise = value;
                                          });
                                        },
                                      ),)

                                ),
                              ),
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                  width: 300,
                                  child: Text('Province:', style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),)),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
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
                                      hint: Text(
                                        provinceText,
                                        style: const TextStyle(
                                            fontFamily:
                                            'roboto',
                                            color: Colors
                                                .black,
                                            fontSize: 15),
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
                                          provinceText = provinceList[int.parse(province.toString()) - 1].name;
                                        });

                                      },

                                    ),
                                  )),
                              const SizedBox(
                                height: 20,
                              ),
                              const SizedBox(
                                  width: 300,
                                  child: Text('City:', style: TextStyle(
                                      fontFamily: 'roboto',
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16
                                  ),)),
                              const SizedBox(
                                height: 10,
                              ),
                              Container(
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
                                      hint: Text(
                                        cityText,
                                        style: const TextStyle(
                                            fontFamily:
                                            'roboto',
                                            color: Colors
                                                .black,
                                            fontSize: 15),
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
                                          cityText = tempList[int.parse(cities.toString()) - 1].name;
                                        });
                                      },
                                    ),
                                  )),
                            ],
                          ),
                        )),
                  ),
                  const Spacer(),
                  Padding(
                    padding: EdgeInsets.only(
                        top: 0.03 * MediaQuery.of(context).size.height),
                    child: ElevatedButton(
                      onPressed: () async {
                        setState(() {
                          isProcessLoading = true;
                        });
                        if(widget.isUser) {
                          _updateUserInformation();
                        }
                        else {
                          _updateLawyerInformation();
                        }
                      },
                      style: ElevatedButton.styleFrom(
                          fixedSize: const Size(300, 20),
                          backgroundColor: Colors.blue,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(15))),
                      child: isProcessLoading
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
                            fontFamily: 'roboto',
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          )),
                    ),
                  ),
                  const SizedBox(height: 20,),

                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}