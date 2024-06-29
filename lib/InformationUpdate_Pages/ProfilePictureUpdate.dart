// ignore_for_file: file_names

import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:image_picker/image_picker.dart';
import 'package:lawhub/Utils/Utilities.dart';
import '../Lawyer_Pages/LawyerAppBar&NavBar.dart';
import '../User_Pages/UserAppBar&NavBar.dart';

class ProfilePictureUpdate extends StatefulWidget{
  final Map<String, dynamic> userData;
  final bool isUser;
  const ProfilePictureUpdate({super.key, required this.isUser,  required this.userData});

  @override
  State<ProfilePictureUpdate> createState() => _ProfilePictureUpdateState();
}

class _ProfilePictureUpdateState extends State<ProfilePictureUpdate> {

  bool isLoadingUpload = false;

  bool isLoadingDelete = false;

  File? _image;

  final picker = ImagePicker();

  Future getImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    } else {
    }
  }

  Future uploadImageToFirebase(File imageFile) async {
    try {
      String fileName = widget.userData['id'];
      firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(fileName);
      await ref.putFile(imageFile);
      String imageUrl = await ref.getDownloadURL();
      if(widget.isUser) {
        await FirebaseFirestore.instance.collection('Users').doc(widget.userData['id']).update({'profilePic': imageUrl}).then((value){
          setState(() {
            isLoadingUpload = false;
          });
          Utilities().successMsg("Your Profile Picture has been Uploaded Successfully");
        }).onError((error, stackTrace) {
          setState(() {
            isLoadingUpload = false;
          });
          Utilities().errorMsg("Something went wrong! please Try again");
        });
      }
      else {
        await FirebaseFirestore.instance.collection('Lawyers').doc(widget.userData['id']).update({'profilePic': imageUrl}).then((value){
          setState(() {
            isLoadingUpload = false;
          });
          Utilities().successMsg("Your Profile Picture has been Uploaded Successfully");
        }).onError((error, stackTrace) {
          setState(() {
            isLoadingUpload = false;
          });
          Utilities().errorMsg("Something went wrong! please Try again");
        });
      }
    } catch (e) {
      Utilities().errorMsg("Error uploading image to Server");
    }
  }

  Future deleteImage() async {
    try {
      firebase_storage.Reference ref = firebase_storage
          .FirebaseStorage.instance
          .ref()
          .child('profile_pictures')
          .child(widget.userData['id']);
      ref.delete();
      if(widget.isUser) {
        await FirebaseFirestore.instance.collection('Users').doc(widget.userData['id']).update({'profilePic': 'null'}).then((value){
          setState(() {
            isLoadingDelete = false;
          });
          Utilities().successMsg("Your Profile Picture has been Deleted Successfully");
        }).onError((error, stackTrace) {
          setState(() {
            isLoadingDelete = false;
          });
          Utilities().errorMsg("Something went wrong! please Try again");
        });
      }
      else {
        await FirebaseFirestore.instance.collection('Lawyers').doc(widget.userData['id']).update({'profilePic': 'null'}).then((value){
          setState(() {
            isLoadingDelete = false;
          });
          Utilities().successMsg("Your Profile Picture has been Deleted Successfully");
        }).onError((error, stackTrace) {
          setState(() {
            isLoadingDelete = false;
          });
          Utilities().errorMsg("Something went wrong! please Try again");
        });
      }
    } catch (e) {
      Utilities().errorMsg("Error uploading image to Server");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60.0),
        child: AppBar(
          toolbarHeight: 70,
          backgroundColor: Colors.blue,
          leading: const SizedBox(),
          title: const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text(
              "Profile Picture",
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
      body: SizedBox(
        width: double.infinity,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
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
                    "Select your Profile Picture:",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            Padding(
              padding: EdgeInsets.only(
                  top: 0.045 * MediaQuery.of(context).size.height,
                  bottom: 0.03 * MediaQuery.of(context).size.height,
              ),
              child: GestureDetector(
                onTap: () {
                  getImage();
                },
                child: CircleAvatar(
                  radius: 80,
                  backgroundColor: Colors.grey[300],
                  backgroundImage: _image != null ? FileImage(_image!) : null,
                  child: _image == null
                      ? widget.userData['profilePic'] != 'null'
                        ? ClipRRect(
                    borderRadius: const BorderRadius.all(Radius.circular(80)),
                    child: SizedBox(
                      height: 200,
                      width: 200,
                      child: Image.network(widget.userData['profilePic'],
                        fit: BoxFit.fitHeight,
                        filterQuality: FilterQuality.high,

                      ),
                    ),
                  )
                        : const SizedBox(
                    height: 150,
                    width: 150,
                    child: Icon(
                      Icons.person,
                      size: 90,
                      color: Colors.grey,
                    ),
                  )
                      : null,
                ),
              ),
            ),
            widget.userData['profilePic'] == 'null'
            ? ElevatedButton(
              onPressed: () async {
                setState(() {
                  isLoadingUpload = true;
                });
                if(_image != null) {
                  uploadImageToFirebase(_image!);
                }
                else {
                  setState(() {
                    isLoadingUpload = false;
                  });
                  Utilities().errorMsg("Please Select Image");
                }
              },
              style: ElevatedButton.styleFrom(
                  fixedSize: const Size(200, 20),
                  backgroundColor: Colors.blue,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15))),
              child: isLoadingUpload
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
                  : const Text('Upload',
                  style: TextStyle(
                    color: Colors.white,
                    fontFamily: 'roboto',
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  )),
            )
            : Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoadingUpload = true;
                    });
                    if(_image != null) {
                      uploadImageToFirebase(_image!);
                    }
                    else {
                      setState(() {
                        isLoadingUpload = false;
                      });
                      Utilities().errorMsg("Please Select Image");
                    }
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(100, 20),
                      backgroundColor: Colors.lightGreen,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: isLoadingUpload
                      ? Container(
                      color: Colors.lightGreen,
                      height: 20,
                      width: 20,
                      child: const SpinKitCircle(color: Colors.white,size: 20))
                      : const Text('Update',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
                ElevatedButton(
                  onPressed: () async {
                    setState(() {
                      isLoadingDelete = true;
                    });
                    deleteImage();
                  },
                  style: ElevatedButton.styleFrom(
                      fixedSize: const Size(100, 20),
                      backgroundColor: Colors.deepOrangeAccent,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15))),
                  child: isLoadingDelete
                      ? Container(
                      color: Colors.deepOrangeAccent,
                      height: 20,
                      width: 20,
                      child: const SpinKitCircle(color: Colors.white,size: 20))
                      : const Text('Delete',
                      style: TextStyle(
                        color: Colors.white,
                        fontFamily: 'roboto',
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      )),
                ),
              ],
            )

          ],
        ),
      ),
      floatingActionButton:
      widget.isUser
          ? Padding(
        padding: const EdgeInsets.only(left: 35),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const UserAppBarNavBar()));
                },
                child: Container(
                  height: 40,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: const Center(child: Text('Home',
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
      )
          : Padding(
        padding: const EdgeInsets.only(left: 35),
        child: SizedBox(
          width: double.infinity,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              InkWell(
                onTap: () {
                  Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) =>
                          const LawyerAppbarNavBar()));
                },
                child: Container(
                  height: 40,
                  width: 300,
                  decoration: BoxDecoration(
                      color: Colors.blue,
                      borderRadius: BorderRadius.circular(15)
                  ),
                  child: const Center(child: Text('Home',
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