// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// ignore: depend_on_referenced_packages
import 'package:intl/intl.dart';
import 'package:lawhub/Payment_Pages/PaymentSuccessful.dart';

class PaymentHistoryPage extends StatefulWidget{
  final bool isUser;
  const PaymentHistoryPage({Key? key, required this.isUser}) : super(key: key);

  @override
  State<PaymentHistoryPage> createState() => _PaymentHistoryPageState();
}

class Payments {
  final String tId;
  final String dateTime;
  final String amount;
  final String currency;
  final int index;

  Payments({
    required this.tId,
    required this.dateTime,
    required this.amount,
    required this.currency,
    required this.index
  });
}

class _PaymentHistoryPageState extends State<PaymentHistoryPage> {

  bool isLoading = true;
  bool isPaymentsAvailable = true;

  Future<void> checkPaymentsHistory() async {
    var doc = await FirebaseFirestore.instance.collection('Payments').doc(FirebaseAuth.instance.currentUser!.email.toString()).get();
    if(!doc.exists) {
      setState(() {
        isLoading = false;
        isPaymentsAvailable = false;
      });
    }
    else {
      fetchAllPayments().then((data) {
        int counter = data['counter'];
        for (int i = 1; i <= counter; i++) {
          paymentHistoryList.add(Payments(tId: data['transaction$i']['tId'], dateTime: data['transaction$i']['dateTime'], amount: data['transaction$i']['amount'], currency: data['transaction$i']['currency'], index: i+1));
        }
        setState(() {
          isLoading = false;
          isPaymentsAvailable = true;
        });
      }).catchError((error) {
        setState(() {
          isLoading = false;
        });
      });
    }
  }

  Future<DocumentSnapshot> fetchAllPayments() async {
    DocumentSnapshot userSnapshot = await FirebaseFirestore.instance
        .collection('Payments')
        .doc(FirebaseAuth.instance.currentUser!.email.toString())
        .get();
    return userSnapshot;
  }

  List<Payments> paymentHistoryList = [];

  @override
  void initState() {
    super.initState();
    checkPaymentsHistory();
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
                "Payments History",
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
            : isPaymentsAvailable
            ? SingleChildScrollView(
          physics: const ScrollPhysics(),
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
                      "All Transactions",
                      style: TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  )),
              ListView.builder(
                itemBuilder: (context, index) {
                  paymentHistoryList.sort((a, b) => b.index.compareTo(a.index));
                  var itemData = paymentHistoryList[index];
                  return InkWell(
                    onTap: () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => PaymentSuccessful(isUser: widget.isUser, tId: itemData.tId, currency: itemData.currency, amount: itemData.amount, dateTime: itemData.dateTime)));
                    },
                    child: Padding(
                      padding: const EdgeInsets.only(bottom: 15, right: 20, left: 20),
                      child: Container(
                        decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: const BorderRadius.all(Radius.circular(15)),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12.withOpacity(0.35),
                                blurRadius: 8,
                                offset: const Offset(0, 2),
                              )
                            ]
                        ),
                        child: Padding(
                          padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 20),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                itemData.amount+NumberFormat().simpleCurrencySymbol(itemData.currency),
                                style: const TextStyle(
                                  fontFamily: 'roboto',
                                  fontWeight: FontWeight.bold,
                                  fontSize: 16,
                                ),
                              ),
                              Text(
                                itemData.dateTime,
                                style: const TextStyle(
                                  fontFamily: 'roboto',
                                  fontSize: 16,
                                ),
                              )
                            ],
                          ),
                        ),
                      ),
                    ),
                  );

                },
                itemCount: paymentHistoryList.length,
                physics: const NeverScrollableScrollPhysics(),
                shrinkWrap: true,
              )
            ],
          ),
        )
            : Padding(
          padding: const EdgeInsets.only(top: 10),
          child: SizedBox(
            width: double.infinity,
            child: Center(
              child: Text('No Transactions Yet', style: TextStyle(
                  fontFamily: 'roboto',
                  fontSize: 16,
                  color: Colors.grey.shade500),),
            ),),
        )
    );
  }
}