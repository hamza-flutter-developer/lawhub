// ignore_for_file: file_names

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/User_Pages/UserLawyerProfile.dart';

final List<String> lawyerCategories = [
  'Family Law', 'Civil Law', 'Criminal Law',
  'Medical Law', 'Business Law', 'Tax Law',
  'Consumer Protection', 'Rent Law', 'Harassment Law',
  'Cyber Crime', 'Real Estate', 'Banking Law',
  'Intellectual Property', 'Immigration',
  'Constitutional Law', 'Employment & Labour',
  'International Law', 'Environment Law', 'Human Rights',
  'Defamation Law', 'Arbitration', 'Construction Law',
];

// ignore: must_be_immutable
class UserHomePage extends StatefulWidget {
  final Map<String, dynamic> userData;
  List<Map<String, dynamic>> dataList;
  UserHomePage({super.key, required this.dataList, required this.userData});

  @override
  State<UserHomePage> createState() => _UserHomePageState();
}

class _UserHomePageState extends State<UserHomePage> {

  final TextEditingController _searchController = TextEditingController();
  late FocusNode _focusNode;
  bool isCancelPressed = false;

  bool isSpecificCategorySelected = false;
  String? categorySelected;
  List<Map<String, dynamic>> specificCategory = [];

  void fetchLawyersByExpertise(String expertise) {
    setState(() {
      specificCategory = [];
    });
    for(int i = 0; i < widget.dataList.length; i++) {
      Map<String, dynamic> itemData = widget.dataList[i];
      for(int j = 0; j < itemData['expertise'].length; j++) {
        if(itemData['expertise'][j] == expertise) {
          specificCategory.add(itemData);
        }
      }
    }
  }

  List<Map<String, dynamic>> topRattedLawyers = [];
  void fetchTopRatedLawyers() {
    topRattedLawyers = widget.dataList;
    topRattedLawyers.sort((a, b) => b['ratting'].compareTo(a['ratting']));
  }

  List<Map<String, dynamic>> nearbyLawyers = [];
  void fetchNearbyLawyers() {
    setState(() {
      nearbyLawyers = [];
    });
    for(int i = 0; i < widget.dataList.length; i++) {
      Map<String, dynamic> itemData = widget.dataList[i];
      if(itemData['city'] == widget.userData['city']) {
        nearbyLawyers.add(itemData);
      }
    }
  }

  @override
  void initState() {
    fetchTopRatedLawyers();
    fetchNearbyLawyers();
    _focusNode = FocusNode();
    _focusNode.addListener(() {
      setState(() {
        if(_focusNode.hasFocus) {
          isCancelPressed = true;
        }
      });
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Padding(
                padding: const EdgeInsets.only(left: 25,right: 25,top: 15),
                child: Row(
                  children: [
                    Expanded(
                      child: Container(
                        decoration: const BoxDecoration(
                          color: Colors.black12,
                          borderRadius: BorderRadius.all(Radius.circular(30)),
                        ),
                        child: TextField(
                          controller: _searchController,
                          focusNode: _focusNode,
                          style: const TextStyle(
                            fontFamily: 'roboto',
                            fontSize:15,
                          ),
                          decoration: InputDecoration(
                            isDense: true,
                            contentPadding: const EdgeInsets.symmetric(vertical: 5),
                            border: InputBorder.none,
                            focusedBorder: const OutlineInputBorder(
                                borderSide: BorderSide(
                                    color: Colors.grey
                                ),
                                borderRadius: BorderRadius.all(Radius.circular(30))),
                            prefixIcon: const Padding(
                              padding: EdgeInsets.only(left: 15, right: 15),
                              child: Icon(Icons.search, size: 20, color: Colors.grey),
                            ),
                            prefixIconConstraints: const BoxConstraints(minHeight: 10),
                            hintText: 'Search...',
                            hintStyle: const TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 18,
                                color: Colors.grey),
                            suffixIcon: Padding(
                              padding: const EdgeInsets.only(right: 15),
                              child: InkWell(
                                onTap: () {
                                  _searchController.clear();
                                  setState(() {

                                  });
                                },
                                child: const Icon(
                                  Icons.clear,
                                  size: 19,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                            suffixIconConstraints: const BoxConstraints(minHeight: 10),
                          ),
                          onChanged: (String value) {
                            setState(() {

                            });
                          },
                        ),
                      ),
                    ),
                    Visibility(
                      visible: isCancelPressed,
                      child: Padding(
                        padding: const EdgeInsets.only(left: 10.0),
                        child: InkWell(
                          onTap: () {
                            _searchController.clear();
                            setState(() {
                              _focusNode.unfocus();
                              isCancelPressed = false;
                              setState(() {

                              });
                            });
                          },
                          child: const Text('Cancel', style: TextStyle(color: Colors.blue)),
                        ),
                      ),
                    ),
                  ],
                )
            ),
            isCancelPressed
            ? Column(
              children: [
                _searchController.text.isEmpty
                ? const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(
                          left: 30,
                          bottom: 15,
                          top: 15,
                      ),
                      child: Text(
                        'All Lawyers',
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ))
                : const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 30,
                        bottom: 15,
                        top: 15,
                      ),
                      child: Text(
                        'Results',
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                ListView.builder(
                  itemBuilder: (context, index) {
                    Map<String, dynamic> itemData = widget.dataList[index];

                    final name = itemData['name'].toString();
                    if(_searchController.text.isEmpty) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15,right: 20,left: 20),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserLawyerProfile(lawyerData: itemData,userData: widget.userData,)));
                          },
                          child: Container(
                            width: 200,
                            height: 120,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(Radius.circular(25)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.only(left: 15),
                                        child: Container(
                                          height: 90,
                                          width: 90,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: const BorderRadius.all(Radius.circular(25)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12.withOpacity(0.35),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                )
                                              ]
                                          ),
                                          child: itemData['profilePic'] != 'null'
                                              ? ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                                            child: Image.network(itemData['profilePic'],
                                              height: 70,
                                              width: 70,
                                              fit: BoxFit.fitHeight,

                                            ),
                                          )
                                              : Container(
                                            height: 70,
                                            width: 70,
                                            decoration: BoxDecoration(
                                              color:  Colors.white,
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            child: const Icon(
                                              FontAwesomeIcons.userTie,
                                              size: 60,
                                              color: Colors.black,
                                            ),
                                          ),
                                        )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(itemData['name'],style: const TextStyle(
                                            fontFamily: 'roboto',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Text(itemData['expertise'][0],style: const TextStyle(
                                            fontFamily: 'roboto',
                                            fontSize: 14,

                                          ),),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            '${DateTime.now().year - int.parse(itemData['practicingYear'])}+ Years Experience',
                                            style: const TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 13,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 18,
                                              ),
                                              Text(
                                                itemData['city'],
                                                style: const TextStyle(
                                                  fontFamily: 'roboto',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                    (itemData['ratting']+0.0).toString().substring(0,3),
                                          style: const TextStyle(
                                            fontFamily: 'roboto',
                                            fontWeight: FontWeight.w600,
                                            color: Colors.amberAccent,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amberAccent,
                                          size: 18,
                                        ),

                                      ],
                                    )
                                ),

                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    else if(name.toLowerCase().contains(_searchController.text.toLowerCase().toString())) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 15,right: 20,left: 20),
                        child: InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserLawyerProfile(lawyerData: itemData,userData: widget.userData,)));
                          },
                          child: Container(
                            width: 200,
                            height: 120,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: const BorderRadius.all(Radius.circular(25)),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.35),
                                    blurRadius: 8,
                                    offset: const Offset(0, 2),
                                  )
                                ]
                            ),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Row(
                                  children: [
                                    Padding(
                                        padding: const EdgeInsets.only(left: 15),
                                        child: Container(
                                          height: 90,
                                          width: 90,
                                          decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius: const BorderRadius.all(Radius.circular(25)),
                                              boxShadow: [
                                                BoxShadow(
                                                  color: Colors.black12.withOpacity(0.35),
                                                  blurRadius: 8,
                                                  offset: const Offset(0, 2),
                                                )
                                              ]
                                          ),
                                          child: itemData['profilePic'] != 'null'
                                              ? ClipRRect(
                                            borderRadius: const BorderRadius.all(Radius.circular(25)),
                                            child: Image.network(itemData['profilePic'],
                                              height: 70,
                                              width: 70,
                                              fit: BoxFit.fitHeight,

                                            ),
                                          )
                                              : Container(
                                            height: 70,
                                            width: 70,
                                            decoration: BoxDecoration(
                                              color:  Colors.white,
                                              borderRadius: BorderRadius.circular(25),
                                            ),
                                            child: const Icon(
                                              FontAwesomeIcons.userTie,
                                              size: 60,
                                              color: Colors.black,
                                            ),
                                          ),
                                        )
                                    ),
                                    Padding(
                                      padding: const EdgeInsets.only(left: 20),
                                      child: Column(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(itemData['name'],style: const TextStyle(
                                            fontFamily: 'roboto',
                                            fontWeight: FontWeight.bold,
                                            fontSize: 16,
                                          ),),
                                          const SizedBox(
                                            height: 3,
                                          ),
                                          Text(itemData['expertise'][0],style: const TextStyle(
                                            fontFamily: 'roboto',
                                            fontSize: 14,

                                          ),),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Text(
                                            '${DateTime.now().year - int.parse(itemData['practicingYear'])}+ Years Experience',
                                            style: const TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 13,
                                              color: Colors.blue,
                                            ),
                                          ),
                                          const SizedBox(
                                            height: 5,
                                          ),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.location_on,
                                                size: 18,
                                              ),
                                              Text(
                                                itemData['city'],
                                                style: const TextStyle(
                                                  fontFamily: 'roboto',
                                                  fontWeight: FontWeight.w600,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          )
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                                Padding(
                                    padding: const EdgeInsets.only(right: 20),
                                    child: Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          itemData['ratting'].toString(),
                                          style: const TextStyle(
                                            fontFamily: 'roboto',
                                            fontWeight: FontWeight.w600,
                                            color: Colors.amberAccent,
                                            fontSize: 15,
                                          ),
                                        ),
                                        const SizedBox(
                                          width: 3,
                                        ),
                                        const Icon(
                                          Icons.star,
                                          color: Colors.amberAccent,
                                          size: 18,
                                        ),

                                      ],
                                    )
                                ),

                              ],
                            ),
                          ),
                        ),
                      );
                    }
                    else {
                      return Container();
                    }

                  },
                  itemCount: widget.dataList.length,
                  physics: const NeverScrollableScrollPhysics(),
                  shrinkWrap: true,
                )
              ],
            )
            : Column(
              children: [
                isSpecificCategorySelected
                    ? SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                      child: Row(
                        children: lawyerCategories.map((category) {
                          return categorySelected == category
                              ? Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0.1,
                                    blurRadius: 10, // changes position of shadow
                                  ),
                                ]),
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    categorySelected = null;
                                    isSpecificCategorySelected = false;
                                  });
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10))),
                                child: Text(category,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'roboto',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ))),
                          )
                              : Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0.1,
                                    blurRadius: 10, // changes position of shadow
                                  ),
                                ]),
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    categorySelected = category;
                                    isSpecificCategorySelected = true;
                                  });
                                  fetchLawyersByExpertise(category);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10))),
                                child: Text(category,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'roboto',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ))),
                          );
                        }).toList(),
                      ),
                    )
                )
                    : SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10,vertical: 7),
                      child: Row(
                        children: lawyerCategories.map((category) {
                          return Container(
                            margin: const EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                            decoration: BoxDecoration(
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.grey.withOpacity(0.5),
                                    spreadRadius: 0.1,
                                    blurRadius: 10, // changes position of shadow
                                  ),
                                ]),
                            child: ElevatedButton(
                                onPressed: () {
                                  setState(() {
                                    categorySelected = category;
                                    isSpecificCategorySelected = true;
                                  });
                                  fetchLawyersByExpertise(category);
                                },
                                style: ElevatedButton.styleFrom(
                                    backgroundColor: Colors.white,
                                    shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(10))),
                                child: Text(category,
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontFamily: 'roboto',
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                    ))),
                          );
                        }).toList(),
                      ),
                    )
                ),
                isSpecificCategorySelected
                    ? Column(
                  children: [
                    SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: const EdgeInsets.only(
                              left: 30,
                              bottom: 15
                          ),
                          child: Text(
                            categorySelected!,
                            style: const TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                    specificCategory.isNotEmpty
                        ? ListView.builder(
                      itemBuilder: (context, index) {
                        Map<String, dynamic> itemData = specificCategory[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 15,right: 20,left: 20),
                          child: InkWell(
                            onTap: () {
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => UserLawyerProfile(lawyerData: itemData,userData: widget.userData,)));
                            },
                            child: Container(
                              width: 200,
                              height: 120,
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: const BorderRadius.all(Radius.circular(25)),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.black12.withOpacity(0.35),
                                      blurRadius: 8,
                                      offset: const Offset(0, 2),
                                    )
                                  ]
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                children: [
                                  Row(
                                    children: [
                                      Padding(
                                          padding: const EdgeInsets.only(left: 15),
                                          child: Container(
                                            height: 90,
                                            width: 90,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius: const BorderRadius.all(Radius.circular(25)),
                                                boxShadow: [
                                                  BoxShadow(
                                                    color: Colors.black12.withOpacity(0.35),
                                                    blurRadius: 8,
                                                    offset: const Offset(0, 2),
                                                  )
                                                ]
                                            ),
                                            child: itemData['profilePic'] != 'null'
                                                ? ClipRRect(
                                              borderRadius: const BorderRadius.all(Radius.circular(25)),
                                              child: Image.network(itemData['profilePic'],
                                                height: 70,
                                                width: 70,
                                                fit: BoxFit.fitHeight,

                                              ),
                                            )
                                                : Container(
                                              height: 70,
                                              width: 70,
                                              decoration: BoxDecoration(
                                                color:  Colors.white,
                                                borderRadius: BorderRadius.circular(25),
                                              ),
                                              child: const Icon(
                                                FontAwesomeIcons.userTie,
                                                size: 60,
                                                color: Colors.black,
                                              ),
                                            ),
                                          )
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(left: 20),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(itemData['name'],style: const TextStyle(
                                              fontFamily: 'roboto',
                                              fontWeight: FontWeight.bold,
                                              fontSize: 16,
                                            ),),
                                            const SizedBox(
                                              height: 3,
                                            ),
                                            Text(categorySelected!,style: const TextStyle(
                                              fontFamily: 'roboto',
                                              fontSize: 14,

                                            ),),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              '${DateTime.now().year - int.parse(itemData['practicingYear'])}+ Years Experience',
                                              style: const TextStyle(
                                                fontFamily: 'roboto',
                                                fontSize: 13,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                const Icon(
                                                  Icons.location_on,
                                                  size: 18,
                                                ),
                                                Text(
                                                  itemData['city'],
                                                  style: const TextStyle(
                                                    fontFamily: 'roboto',
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                  ),
                                                ),
                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                  Padding(
                                      padding: const EdgeInsets.only(right: 20),
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            itemData['ratting'].toString(),
                                            style: const TextStyle(
                                              fontFamily: 'roboto',
                                              fontWeight: FontWeight.w600,
                                              color: Colors.amberAccent,
                                              fontSize: 15,
                                            ),
                                          ),
                                          const SizedBox(
                                            width: 3,
                                          ),
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amberAccent,
                                            size: 18,
                                          ),

                                        ],
                                      )
                                  ),

                                ],
                              ),
                            ),
                          ),
                        );
                      },
                      itemCount: specificCategory.length,
                      physics: const NeverScrollableScrollPhysics(),
                      shrinkWrap: true,
                    )
                        : Padding(
                      padding: const EdgeInsets.only(top: 10),
                      child: SizedBox(child: Text('No Lawyer available for this Expertise!', style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 16,
                          color: Colors.grey.shade500),),),
                    )
                  ],
                )
                    : Column(
                  children: [
                    const SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 30,
                          ),
                          child: Text(
                            "Top Rated Lawyers",
                            style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                    CarouselSlider.builder(
                      itemCount: 6,
                      itemBuilder: (context, index, realIndex) {
                        Map<String, dynamic> itemData = topRattedLawyers[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserLawyerProfile(lawyerData: itemData,userData: widget.userData,)));
                          },
                          child: Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: Stack(
                              children: [
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 160,
                                      width: 280,
                                      decoration: BoxDecoration(boxShadow: [
                                        BoxShadow(
                                          color: Colors.black12.withOpacity(0.2),
                                          spreadRadius: 4,
                                          blurRadius: 15,
                                          offset: const Offset(0, 3),
                                        )
                                      ]),
                                      child: itemData['profilePic'] != 'null'
                                          ? ClipRRect(
                                        borderRadius: BorderRadius.circular(10),
                                        child: Image.network(itemData['profilePic'],
                                            fit: BoxFit.fill),
                                      )
                                          : Container(
                                        height: 160,
                                        width: 280,
                                        decoration: BoxDecoration(
                                          color:  Colors.white,
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: const Icon(
                                          FontAwesomeIcons.userTie,
                                          size: 100,
                                          color: Colors.black,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Container(
                                      height: 80,
                                      margin: const EdgeInsets.only(top: 130),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          borderRadius:
                                          const BorderRadius.all(Radius.circular(20)),
                                          boxShadow: [
                                            BoxShadow(
                                              color: Colors.black12.withOpacity(0.2),
                                              spreadRadius: 4,
                                              blurRadius: 15,
                                              offset: const Offset(0, 3),
                                            )
                                          ]),
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 10),
                                        child: Column(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              itemData['name'],
                                              style: const TextStyle(
                                                fontFamily: 'roboto',
                                                fontWeight: FontWeight.bold,
                                                fontSize: 15,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                              '${DateTime.now().year - int.parse(itemData['practicingYear'])}+ Years Experience',
                                              style: const TextStyle(
                                                fontFamily: 'roboto',
                                                fontWeight: FontWeight.w600,
                                                fontSize: 11.5,
                                                color: Colors.blue,
                                              ),
                                            ),
                                            const SizedBox(height: 5,),
                                            Row(
                                              mainAxisAlignment: MainAxisAlignment.center,
                                              children: [
                                                Text(
                                                  (itemData['ratting']+0.0).toString().substring(0,3),
                                                  style: const TextStyle(
                                                    fontFamily: 'roboto',
                                                    fontWeight: FontWeight.w600,
                                                    color: Colors.amberAccent,
                                                    fontSize: 15,
                                                  ),
                                                ),
                                                const SizedBox(
                                                  width: 3,
                                                ),
                                                const Icon(
                                                  Icons.star,
                                                  color: Colors.amberAccent,
                                                  size: 18,
                                                ),

                                              ],
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                      options: CarouselOptions(
                        height: 285,
                        autoPlay: true,
                        enlargeCenterPage: true,
                        enableInfiniteScroll: false,
                        animateToClosest: true,
                        autoPlayAnimationDuration: const Duration(seconds: 3),
                        onPageChanged: (index, reason) {
                          // Handle page change event
                        },
                      ),
                    ),
                    const SizedBox(
                        width: double.infinity,
                        child: Padding(
                          padding: EdgeInsets.only(
                            left: 30,
                          ),
                          child: Text(
                            "Nearby You",
                            style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        )),
                    const SizedBox(
                      height: 15,
                    ),
                    GridView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                        crossAxisCount: 2,
                      ),
                      itemCount: nearbyLawyers.length,
                      itemBuilder: (context, index) {
                        Map<String, dynamic> itemData = nearbyLawyers[index];
                        return InkWell(
                          onTap: () {
                            Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) => UserLawyerProfile(lawyerData: itemData, userData: widget.userData,)));
                          },
                          child: Column(
                            children: [
                              Container(
                                decoration: BoxDecoration(boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12.withOpacity(0.2),
                                    spreadRadius: 4,
                                    blurRadius: 15,
                                    offset: const Offset(0, 3),
                                  )
                                ]),
                                child: itemData['profilePic'] != 'null'
                                    ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.network(itemData['profilePic'],
                                      width: 160,
                                      height: 100,
                                      fit: BoxFit.fill),
                                )
                                    : Container(
                                  width: 160,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    color:  Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                  child: const Icon(
                                    FontAwesomeIcons.userTie,
                                    size: 60,
                                    color: Colors.black,
                                  ),
                                ),
                              ),
                              const SizedBox(height: 6,),
                              Text(itemData['name'], style: const TextStyle(
                                fontFamily: 'roboto',
                                fontWeight: FontWeight.bold,
                                fontSize: 17,
                              ),),
                              const SizedBox(height: 5,),
                              SizedBox(
                                width: 180,
                                child: Padding(
                                  padding: const EdgeInsets.only(left: 7),
                                  child: Text(itemData['expertise'][0], style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.blue,
                                  ),),
                                ),
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}
