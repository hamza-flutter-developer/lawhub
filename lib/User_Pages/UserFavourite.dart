// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'UserLawyerProfile.dart';

// ignore: must_be_immutable
class UserFav extends StatefulWidget{
  final Map<String, dynamic> userData;
  List<Map<String, dynamic>> dataList;
  UserFav({super.key, required this.dataList, required this.userData});

  @override
  State<UserFav> createState() => _UserFavState();
}

class _UserFavState extends State<UserFav> {

  final TextEditingController _searchController = TextEditingController();
  late FocusNode _focusNode;
  bool isCancelPressed = false;

  bool isLoading = true;
  bool isFavAvailable = false;

  Future<void> checkFavouriteLawyers() async {
    var documentCheck = await FirebaseFirestore.instance.collection('Favourite').doc(FirebaseAuth.instance.currentUser!.email).get();
    if(!documentCheck.exists) {
      setState(() {
        isLoading = false;
        isFavAvailable = false;
      });
    }
    else {
      setState(() {
        isFavAvailable = true;
        fetchAllFavouriteLawyerData().then((data) {
          setState(() {
            favDataList = data;
            for (int i = 1; i <= favDataList['counter']; i++) {
              String lawyerId = favDataList['LawyerID$i'];
              for (int j = 0; j < widget.dataList.length; j++) {
                Map<String, dynamic> data = widget.dataList[j];
                if (lawyerId == data['id']) {
                  dataList.add(data);
                  break;
                }
              }
            }
            setState(() {
              isLoading = false;
            });
          });
        });
      });
    }
  }

  Future<Map<String, dynamic>> fetchAllFavouriteLawyerData() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Favourite')
        .doc(FirebaseAuth.instance.currentUser!.email)
        .get();

    Map<String, dynamic> favLawyerData = userSnapshot.data() as Map<String, dynamic>;
    return favLawyerData;
  }

  late Map<String, dynamic> favDataList;

  List<Map<String, dynamic>> dataList = [];

  @override
  void initState() {
    checkFavouriteLawyers();
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
        physics: const ScrollPhysics(),
        child: Column(
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
            const SizedBox(
                width: double.infinity,
                child: Padding(
                  padding: EdgeInsets.only(
                    left: 30,
                    top: 20,
                  ),
                  child: Text(
                    "Favourite",
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
            isLoading
            ? Container(
                height: 500,
                width: double.infinity,
                color: Colors.white,
                child: const Center(child: SpinKitCircle(
                    color: Colors.blue, size: 34),) )
            : isFavAvailable
              ? ListView.builder(
              itemBuilder: (context, index) {
                Map<String, dynamic> itemData = dataList[index];

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
                        width: 270,
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
                            const Padding(
                              padding: EdgeInsets.only(right: 25),
                              child: Icon(FontAwesomeIcons.solidHeart,color: Colors.redAccent,size: 27,),
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
                        width: 270,
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
                            const Padding(
                              padding: EdgeInsets.only(right: 25),
                              child: Icon(FontAwesomeIcons.solidHeart,color: Colors.redAccent,size: 27,),
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
              itemCount: dataList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            )
              : Padding(
                padding: const EdgeInsets.only(top: 10),
                child: SizedBox(child: Text('You haven\'t Favourited any Lawyer yet', style: TextStyle(
                  fontFamily: 'roboto',
                  fontSize: 16,
                  color: Colors.grey.shade500),),),
              )
          ],
        ),
      ),

    );
  }
}