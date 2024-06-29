import 'package:flutter/material.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Article_Pages/ArticleAddUpdate.dart';
import 'package:lawhub/Article_Pages/ArticlesView.dart';

class ManageArticles extends StatelessWidget{
  final Map<String, dynamic> userData;
  final bool isUser;
  const ManageArticles({Key? key, required this.isUser, required this.userData}) : super(key: key);
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
                    bottom: 30,
                  ),
                  child: Text(
                    "Manage Your Articles:",
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                )),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ArticleView(isUser: isUser,userData: userData,)));
              },
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Icon(Icons.newspaper,size: 25,),
                        ),
                        SizedBox(width: 20,),
                        Text('My Articles', style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 16
                        ),),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(FontAwesomeIcons.caretRight,size: 15,),
                    )
                  ],
                ),
              ),
            ),
            const SizedBox(
              height: 30,
            ),
            InkWell(
              onTap: () {
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => ArticleAddUpdate(userData: userData, index: 0, isUpdate: false, articleList: const [],)));
              },
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
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: 20),
                          child: Icon(FontAwesomeIcons.pen,size: 22,),
                        ),
                        SizedBox(width: 23,),
                        Text('Add Article', style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 16
                        ),),],
                    ),
                    Padding(
                      padding: EdgeInsets.only(right: 20),
                      child: Icon(FontAwesomeIcons.caretRight,size: 15,),
                    )
                  ],
                ),
              ),
            ),
          ],
        ),
      ),

    );
  }

}