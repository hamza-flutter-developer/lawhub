// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Article_Pages/ArticleAddedUpdated.dart';

class ArticleExplained extends StatefulWidget{
  final Map<String, dynamic> userData;
  final List<dynamic> articleList;
  final bool isDelete;
  final int index;
  const ArticleExplained({Key? key, required this.articleList, required this.isDelete, required this.userData, required this.index}) : super(key: key);

  @override
  State<ArticleExplained> createState() => _ArticleExplainedState();
}

class _ArticleExplainedState extends State<ArticleExplained> {

  bool isLoading = false;

  void addFirstArticle() {
    FirebaseFirestore.instance.collection('Articles').doc(widget.userData['id']).set({'counter': 0});
  }

  Future<void> checkArticles() async {
    fetchAllArticles().then((data) {
      int counter = data['counter'];
      for (int i = 1; i <= counter; i++) {
        tempArticleList.add(data['Article$i']);
      }
      setState(() {
      });
    });
  }

  Future<DocumentSnapshot> fetchAllArticles() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Articles')
        .doc(widget.userData['id'])
        .get();
    return userSnapshot;
  }

  List<dynamic> tempArticleList = [];

  void deleteFromFavourite() async {
    var documentSnapshot = await FirebaseFirestore.instance.collection('Articles').doc(widget.userData['id']).get();
    int counter = documentSnapshot['counter'];
    if (counter == 1) {
      await FirebaseFirestore.instance.collection('Articles').doc(widget.userData['id']).delete();
    }
    else {
      FirebaseFirestore.instance.collection('Articles').doc(widget.userData['id']).delete();
      addFirstArticle();
      DocumentReference documentReference =
      FirebaseFirestore.instance.collection('Articles').doc(widget.userData['id']);
      int controller = 1;
      for (int i = 0; i < counter; i++) {
        var itemData = tempArticleList[i];
        if(i+1 == widget.index) {
          continue;
        }
        else {
          await documentReference.update({
            'Article$controller': [
              {'title': itemData[0]['title']},
              {'description': itemData[1]['description']},
              {'question1': itemData[2]['question1']},
              {'question2': itemData[3]['question2']},
              {'question3': itemData[4]['question3']},
            ],
            'counter': controller,
          });
          controller++;
        }
      }
    }
    setState(() {
      isLoading = false;
    });
    // ignore: use_build_context_synchronously
    Navigator.push(context, MaterialPageRoute(builder: (context) => const ArticleAddedUpdated(text: 'Deleted')));
  }

  @override
  void initState() {
    checkArticles();
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
                "Articles",
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
          child: Padding(
            padding: const EdgeInsets.only(top: 30,left: 20,right: 20,bottom: 15),
            child: SizedBox(
              width: double.infinity,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Title:',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(widget.articleList[0]['title'],
                    style: const TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 15.5,
                      color: Colors.black,
                      height: 1.7,
                      wordSpacing: 1.5,
                    ),),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('Description:',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(widget.articleList[1]['description'],
                    style: const TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 15.5,
                      color: Colors.black,
                      height: 1.7,
                      wordSpacing: 1.5,
                    ),),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('What is alleged to have occurred?',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(widget.articleList[2]['question1'],
                    style: const TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 15.5,
                      color: Colors.black,
                      height: 1.7,
                      wordSpacing: 1.5,
                    ),),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('What happened at court?',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(widget.articleList[3]['question2'],
                    style: const TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 15.5,
                      color: Colors.black,
                      height: 1.7,
                      wordSpacing: 1.5,
                    ),),
                  const SizedBox(
                    height: 30,
                  ),
                  const Text('What was the result?',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      wordSpacing: 2,
                    ),),
                  const SizedBox(
                    height: 10,
                  ),
                  Text(widget.articleList[4]['question3'],
                    style: const TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 15.5,
                      color: Colors.black,
                      height: 1.7,
                      wordSpacing: 1.5,
                    ),),
                  const SizedBox(
                    height: 30,
                  ),
                  widget.isDelete
                  ? SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          onTap: () {
                            setState(() {
                              isLoading = true;
                            });
                            deleteFromFavourite();
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
                                : const Center(child: Text('Delete',
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
                  )
                  : const SizedBox(),

                ],
              ),
            ),
          ),
        )
    );
  }
}