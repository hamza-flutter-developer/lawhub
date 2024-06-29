// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Article_Pages/ArticleExplained.dart';
import 'ArticleAddUpdate.dart';

class ArticleView extends StatefulWidget{
  final Map<String, dynamic> userData;
  final bool isUser;
  const ArticleView({Key? key, required this.isUser, required this.userData}) : super(key: key);

  @override
  State<ArticleView> createState() => _ArticleViewState();
}

class _ArticleViewState extends State<ArticleView> {

  bool isLoading = true;
  bool isArticleAvailable = false;

  Future<void> checkArticles() async {
    var documentCheck = await FirebaseFirestore.instance.collection('Articles').doc(widget.userData['id']).get();
    if (!documentCheck.exists) {
      setState(() {
        isLoading = false;
        isArticleAvailable = false;
      });
    } else {
      fetchAllArticles().then((data) {
        setState(() {
          isArticleAvailable = true;
          int counter = data['counter'];
          for (int i = 1; i <= counter; i++) {
            articleList.add(data['Article$i']);
          }
          isLoading = false;
        });
      }).catchError((error) {
        setState(() {
          isLoading = false;
          isArticleAvailable = false;
        });
      });
    }
  }

  Future<DocumentSnapshot> fetchAllArticles() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Articles')
        .doc(widget.userData['id'])
        .get();
    return userSnapshot;
  }

  List<dynamic> articleList = [];

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
      body: isLoading
          ? Center(
        child: Container(
            color: Colors.white,
            child: const SpinKitCircle(
                color: Colors.blue, size: 34) ),
      )
          : SingleChildScrollView(
        physics: const ScrollPhysics(),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            const SizedBox(height: 30),
            isArticleAvailable
                ? ListView.builder(
              itemBuilder: (context, index) {
                var itemData = articleList[index];
                return Padding(
                  padding: const EdgeInsets.only(left: 26.2, right: 26.2, bottom: 13),
                  child: Container(
                    constraints: const BoxConstraints(maxWidth: 360),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: const BorderRadius.all(Radius.circular(15)),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black12.withOpacity(0.35),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        )
                      ],
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.isUser
                              ? SizedBox(
                            width: 320,
                            height: 41,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Text(
                                  'Article # ${(index + 1).toString()}',
                                  style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          )
                              : SizedBox(
                            width: 320,
                            height: 41,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                const SizedBox(width: 48),
                                Text(
                                  'Article # ${(index + 1).toString()}',
                                  style: const TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                PopupMenuButton(
                                  icon: const Icon(Icons.more_vert),
                                  itemBuilder: (BuildContext context) {
                                    return [
                                      const PopupMenuItem(
                                        value: 'edit',
                                        child: Text('Edit'),
                                      ),
                                      const PopupMenuItem(
                                        value: 'delete',
                                        child: Text('Delete'),
                                      ),
                                    ];
                                  },
                                  onSelected: (value) {
                                    if (value == 'edit') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ArticleAddUpdate(
                                            userData: widget.userData,
                                            isUpdate: true,
                                            articleList: articleList[index],
                                            index: index + 1,
                                          ),
                                        ),
                                      );
                                    }
                                    if (value == 'delete') {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ArticleExplained(
                                            articleList: articleList[index],
                                            index: index + 1,
                                            isDelete: true,
                                            userData: widget.userData,
                                          ),
                                        ),
                                      );
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Title:',
                            style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            itemData[0]['title'].toString(),
                            style: const TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          const Text(
                            'Description:',
                            style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 16,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            itemData[1]['description'],
                            style: const TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 16,
                            ),
                          ),
                          const SizedBox(height: 20),
                          SizedBox(
                            width: 360,
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                ElevatedButton(
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => ArticleExplained(
                                          articleList: articleList[index],
                                          index: index + 1,
                                          isDelete: false,
                                          userData: widget.userData,
                                        ),
                                      ),
                                    );
                                  },
                                  style: ElevatedButton.styleFrom(
                                    fixedSize: const Size(130, 40),
                                    backgroundColor: Colors.blue,
                                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                                  ),
                                  child: const Text(
                                    'Read More',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontFamily: 'roboto',
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              },
              itemCount: articleList.length,
              physics: const NeverScrollableScrollPhysics(),
              shrinkWrap: true,
            )
                : Padding(
              padding: const EdgeInsets.only(top: 10),
              child: SizedBox(
                width: double.infinity,
                child: Center(
                  child: Text(
                    widget.isUser ? 'Lawyer haven\'t Uploaded any Article yet' : 'You haven\'t Uploaded any Article yet',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 16,
                      color: Colors.grey.shade500,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      )
    );

  }
}