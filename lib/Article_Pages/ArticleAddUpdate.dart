// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import '../Utils/Utilities.dart';
import 'ArticleAddedUpdated.dart';

class ArticleAddUpdate extends StatefulWidget{
  final List<dynamic> articleList;
  final int index;
  final Map<String, dynamic> userData;
  final bool isUpdate;
  const ArticleAddUpdate({Key? key, required this.userData, required this.isUpdate, required this.articleList, required this.index}) : super(key: key);

  @override
  State<ArticleAddUpdate> createState() => _ArticleAddUpdateState();
}

class _ArticleAddUpdateState extends State<ArticleAddUpdate> {

  late TextEditingController _title = TextEditingController();
  late TextEditingController _description = TextEditingController();
  late TextEditingController _question1 = TextEditingController();
  late TextEditingController _question2 = TextEditingController();
  late TextEditingController _question3 = TextEditingController();


  final titleFocusNode = FocusNode();
  final descriptionFocusNode = FocusNode();
  final question1FocusNode = FocusNode();
  final question2FocusNode = FocusNode();
  final question3FocusNode = FocusNode();

  bool isLoading = false;

  final fireStore  = FirebaseFirestore.instance.collection('Articles');

  void addFirstArticle() {
    fireStore.doc(widget.userData['id']).set({'counter': 0});
  }

  void addToArticles() async {
    var doc = await FirebaseFirestore.instance.collection('Articles').doc(widget.userData['id']).get();
    int counter = doc['counter'];
    counter++;
    DocumentReference documentReference =
    fireStore.doc(widget.userData['id']);
    await documentReference.update({
      'Article$counter': [
        {'title': _title.text.toString()},
        {'description': _description.text.toString()},
        {'question1': _question1.text.toString()},
        {'question2': _question2.text.toString()},
        {'question3': _question3.text.toString()},
      ],
      'counter': counter,
    }).then((value) => {
      setState(() {
        isLoading = false;
        setState(() {
        });
      }),
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ArticleAddedUpdated(text: 'Added',)))
    }).onError((error, stackTrace) => {
      setState(() {
        isLoading = false;
      }),
      Utilities().errorMsg('Something Went Wrong'),
    });
  }

  void updateArticles() async {
    DocumentReference documentReference =
    fireStore.doc(widget.userData['id']);
    await documentReference.update({
      'Article${widget.index}': [
        {'title': _title.text.toString()},
        {'description': _description.text.toString()},
        {'question1': _question1.text.toString()},
        {'question2': _question2.text.toString()},
        {'question3': _question3.text.toString()},
      ],
    }).then((value) => {
      setState(() {
        isLoading = false;
        setState(() {
        });
      }),
      Navigator.push(context, MaterialPageRoute(builder: (context) => const ArticleAddedUpdated(text: 'Updated',)))
    }).onError((error, stackTrace) => {
      setState(() {
        isLoading = false;
      }),
      Utilities().errorMsg('Something Went Wrong'),
    });
  }

  final _form = GlobalKey<FormState>();

  @override
  void initState() {
    if(widget.isUpdate) {
      _title = TextEditingController(text: widget.articleList[0]['title']);
      _description = TextEditingController(text: widget.articleList[1]['description']);
      _question1 = TextEditingController(text: widget.articleList[2]['question1']);
      _question2 = TextEditingController(text: widget.articleList[3]['question2']);
      _question3 = TextEditingController(text: widget.articleList[4]['question3']);
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
            title: widget.isUpdate
              ? const Padding(
              padding: EdgeInsets.only(top: 13),
              child: Text(
                "Update Articles",
                style: TextStyle(
                    fontFamily: 'roboto',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white),
              ),
            )
              : const Padding(
              padding: EdgeInsets.only(top: 13),
              child: Text(
                "Add Articles",
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
        body: SingleChildScrollView(
          child: SizedBox(
            width: double.infinity,
            child: Form(
              key: _form,
              child: Column(
                children: [
                  const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 30,
                          top: 30,
                          bottom: 15,
                        ),
                        child: Text(
                          "Title:",
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
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
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: _title,
                          textAlignVertical: TextAlignVertical.center,
                          focusNode: titleFocusNode,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          maxLines: 4,
                          decoration: const InputDecoration(
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            hintText: "Enter Title of your Article",
                            focusColor: Colors.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Title your Article";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 30,
                          top: 30,
                          bottom: 25,
                        ),
                        child: Text(
                          "Description:",
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
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
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: _description,
                          textAlignVertical: TextAlignVertical.center,
                          focusNode: descriptionFocusNode,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          maxLines: 4,
                          decoration: const InputDecoration(
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            hintText: "Enter Description of your Article",
                            focusColor: Colors.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter Description of you Article";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 30,
                          top: 30,
                          bottom: 25,
                        ),
                        child: Text(
                          "What is alleged to have occurred?",
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
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
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: _question1,
                          textAlignVertical: TextAlignVertical.center,
                          focusNode: question1FocusNode,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          maxLines: 4,
                          decoration: const InputDecoration(
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            hintText: "Elaborate your Answer",
                            focusColor: Colors.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter your Answer";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 30,
                          top: 30,
                          bottom: 25,
                        ),
                        child: Text(
                          "What happened at court?",
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
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
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: _question2,
                          textAlignVertical: TextAlignVertical.center,
                          focusNode: question2FocusNode,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          maxLines: 4,
                          decoration: const InputDecoration(
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            hintText: "Elaborate your Answer",
                            focusColor: Colors.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter your Answer";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                      width: double.infinity,
                      child: Padding(
                        padding: EdgeInsets.only(
                          left: 30,
                          top: 30,
                          bottom: 25,
                        ),
                        child: Text(
                          "What was the result?",
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      )),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30),
                    child: Container(
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
                        padding: const EdgeInsets.only(left: 20, right: 20),
                        child: TextFormField(
                          controller: _question3,
                          textAlignVertical: TextAlignVertical.center,
                          focusNode: question3FocusNode,
                          style: const TextStyle(
                            fontSize: 15,
                          ),
                          maxLines: 4,
                          decoration: const InputDecoration(
                            focusedBorder: InputBorder.none,
                            border: InputBorder.none,
                            hintText: "Elaborate your Answer",
                            focusColor: Colors.black,
                          ),
                          validator: (value) {
                            if (value!.isEmpty) {
                              return "Please Enter your Answer";
                            }
                            return null;
                          },
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 30,
                  ),
                  GestureDetector(
                    onTap: () {
                      if (titleFocusNode.hasFocus) {
                        titleFocusNode.unfocus();
                      }
                      if (descriptionFocusNode.hasFocus) {
                        descriptionFocusNode.unfocus();
                      }
                      if (question1FocusNode.hasFocus) {
                        question1FocusNode.unfocus();
                      }
                      if (question2FocusNode.hasFocus) {
                        question2FocusNode.unfocus();
                      }
                      if (question3FocusNode.hasFocus) {
                        question3FocusNode.unfocus();
                      }
                    },
                    child: SizedBox(
                      width: double.infinity,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          InkWell(
                            onTap: () async {
                              if (titleFocusNode.hasFocus) {
                                titleFocusNode.unfocus();
                              }
                              if (descriptionFocusNode.hasFocus) {
                                descriptionFocusNode.unfocus();
                              }
                              if (question1FocusNode.hasFocus) {
                                question1FocusNode.unfocus();
                              }
                              if (question2FocusNode.hasFocus) {
                                question2FocusNode.unfocus();
                              }
                              if (question3FocusNode.hasFocus) {
                                question3FocusNode.unfocus();
                              }
                              if(_form.currentState!.validate()) {
                                setState(() {
                                  isLoading = true;
                                });
                                if(widget.isUpdate) {
                                  updateArticles();
                                }
                                else {
                                  var  documentCheck = await FirebaseFirestore.instance.collection('Articles').doc(widget.userData['id']).get();
                                  if(documentCheck.exists) {
                                    addToArticles();
                                  }
                                  else {
                                    addFirstArticle();
                                    addToArticles();
                                  }
                                }
                              }
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
                  const SizedBox(
                    height: 20,
                  ),
                ],
              ),
            ),
          ),
        ),


    );
  }
}