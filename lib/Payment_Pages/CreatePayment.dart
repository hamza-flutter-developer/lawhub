// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Payment_Pages/PaymentSuccessful.dart';
import 'package:lawhub/Utils/Utilities.dart';



class CreatePayment extends StatefulWidget{
  final bool isUser;
  const CreatePayment({super.key, required this.isUser});

  @override
  State<CreatePayment> createState() => _CreatePaymentState();
}

class _CreatePaymentState extends State<CreatePayment> {
  TextEditingController amountController = TextEditingController();
  TextEditingController nameController = TextEditingController();
  TextEditingController addressController = TextEditingController();
  TextEditingController cityController = TextEditingController();
  TextEditingController stateController = TextEditingController();
  TextEditingController countryController = TextEditingController();
  TextEditingController pinCodeController = TextEditingController();

  FocusNode amountFocusNode = FocusNode();
  FocusNode nameFocusNode = FocusNode();
  FocusNode addressFocusNode = FocusNode();
  FocusNode cityFocusNode = FocusNode();
  FocusNode stateFocusNode = FocusNode();
  FocusNode countryFocusNode = FocusNode();
  FocusNode pinCodeFocusNode = FocusNode();

  final currencyList = [
    {'id': 1, 'name': 'USD'},
    {'id': 2, 'name': 'INR'},
    {'id': 3, 'name': 'JPY'},
    {'id': 4, 'name': 'EUR'},
    {'id': 5, 'name': 'AUD'},
    {'id': 6, 'name': 'GBP'},
  ];
  String? selectedCurrency;
  String selectedCurrencyText = "USD";

  bool isLoading = false;

  String checkMonth(int index){
    switch (index) {
      case 1:
        return 'Jan';
      case 2:
        return 'Feb';
      case 3:
        return 'Mar';
      case 4:
        return 'Apr';
      case 5:
        return 'May';
      case 6:
        return 'Jun';
      case 7:
        return 'Jul';
      case 8:
        return 'Aug';
      case 9:
        return 'Sep';
      case 10:
        return 'Oct';
      case 11:
        return 'Nov';
      case 12:
        return 'Dec';
      default:
        return '';
    }
  }

  Future<void> _processPayment() async {
    final email = FirebaseAuth.instance.currentUser!.email.toString();
    final topUpAmount = double.parse(amountController.text);

    final now = DateTime.now();
    int minuteInt = now.minute;
    int hourInt = now.hour;
    int dayInt = now.day;
    int monthInt = now.month;

    String minute = minuteInt < 10 ? '0$minuteInt' : '$minuteInt';
    String hour = hourInt >= 12 ? '${hourInt - 12}' : '$hourInt';
    String amPm = hourInt >= 12 ? 'PM' : 'AM';
    String date = dayInt < 10 ? '0$dayInt' : '$dayInt';
    String month = checkMonth(monthInt);
    String year = now.year.toString();
    String dateTimeText = '$date $month $year, $hour:$minute $amPm';

    String generatedTId = 'TXN_${now.millisecondsSinceEpoch}';

    // Save to Payments collection
    var doc = await FirebaseFirestore.instance.collection('Payments').doc(email).get();
    if (doc.exists) {
      int counter = doc['counter'];
      counter++;
      await FirebaseFirestore.instance.collection('Payments').doc(email).update({
        'transaction$counter': {
          'tId': generatedTId,
          'amount': amountController.text,
          'currency': selectedCurrencyText,
          'dateTime': dateTimeText
        },
        'counter': counter
      });
    } else {
      await FirebaseFirestore.instance.collection('Payments').doc(email).set({
        'transaction1': {
          'tId': generatedTId,
          'amount': amountController.text,
          'currency': selectedCurrencyText,
          'dateTime': dateTimeText
        },
        'counter': 1
      });
    }

    // Top up wallet balance
    final walletRef = FirebaseFirestore.instance.collection('Wallets').doc(email);
    final walletDoc = await walletRef.get();
    final currentBalance = walletDoc.exists ? (walletDoc.data()?['balance'] ?? 0).toDouble() : 0.0;

    await walletRef.set({
      'balance': currentBalance + topUpAmount,
      'updatedAt': FieldValue.serverTimestamp(),
    }, SetOptions(merge: true));

    await walletRef.collection('transactions').add({
      'type': 'topup',
      'amount': topUpAmount,
      'otherPartyEmail': '',
      'otherPartyName': 'Payment Top-up',
      'otherPartyImage': 'null',
      'createdAt': FieldValue.serverTimestamp(),
    });

    setState(() {
      isLoading = false;
    });
    // ignore: use_build_context_synchronously
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => PaymentSuccessful(isUser: widget.isUser, tId: generatedTId, currency: selectedCurrencyText, amount: amountController.text, dateTime: dateTimeText)));
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
                "Make Payment",
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
            child: Column(
              children: [
                const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 30,
                        top: 40,
                      ),
                      child: Text(
                        "Add Details:",
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    )),
                const SizedBox(
                    width: double.infinity,
                    child: Padding(
                      padding: EdgeInsets.only(
                        left: 30,
                        right: 30
                      ),
                      child: Text(
                        "Please ensure that you enter your payment details accurately to avoid any processing errors. Double-check the information provided before submitting to ensure a smooth transaction. Thank you for your attention to detail!",
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 16,
                        ),
                        textAlign: TextAlign.justify,
                      ),
                    )),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                    child: Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Container(
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
                                  padding: const EdgeInsets.only(left: 25),
                                  child: TextFormField(
                                    focusNode: amountFocusNode,
                                    controller: amountController,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                        enabledBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide.none
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide.none
                                        ),
                                        hintText: 'Amount',
                                        hintStyle: TextStyle(
                                          fontFamily: 'roboto',
                                          fontSize: 16,
                                          color: Colors.grey.shade500,
                                        )
                                    ),
                                  )
                              ),
                            ),),
                            const SizedBox(width: 20,),
                            Container(
                                width: 100,
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
                                      hint: const Text('USD', style: TextStyle(
                                        color: Colors.black,
                                        fontSize: 16,
                                      ),),
                                      iconSize: 24.5,
                                      isExpanded: true,
                                      underline: const SizedBox(),
                                      value: selectedCurrency,
                                      items: currencyList.map((e) {
                                        return DropdownMenuItem(
                                          value: e['id'].toString(),
                                          child: Text(e['name'].toString()),
                                        );
                                      }).toList(),
                                      onChanged: (newValue) {
                                        setState(() {
                                          selectedCurrency = newValue.toString();
                                          selectedCurrencyText = currencyList[int.parse(selectedCurrency.toString()) - 1]['name'].toString();
                                        });
                                      },
                                    ),
                                  ),
                                )
                            ),
                          ],
                        ),
                        const SizedBox(height: 15,),
                        Container(
                          width: double.infinity,
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
                              padding: const EdgeInsets.only(left: 25),
                              child: TextFormField(
                                focusNode: nameFocusNode,
                                controller: nameController,
                                textAlignVertical: TextAlignVertical.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),
                                    hintText: 'Name',
                                    hintStyle: TextStyle(
                                      fontFamily: 'roboto',
                                      fontSize: 16,
                                      color: Colors.grey.shade500,
                                    )
                                ),
                              )
                          ),
                        ),
                        const SizedBox(height: 15,),
                        Container(
                          width: double.infinity,
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
                              padding: const EdgeInsets.only(left: 25),
                              child: TextFormField(
                                focusNode: addressFocusNode,
                                controller: addressController,
                                textAlignVertical: TextAlignVertical.center,
                                style: const TextStyle(
                                  fontSize: 16,
                                ),
                                decoration: InputDecoration(
                                    enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),
                                    focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide.none
                                    ),
                                    hintText: 'Address Line',
                                    hintStyle: TextStyle(
                                      fontFamily: 'roboto',
                                      fontSize: 16,
                                      color: Colors.grey.shade500,
                                    )
                                ),
                              )
                          ),
                        ),
                        const SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Container(
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
                                  padding: const EdgeInsets.only(left: 25),
                                  child: TextFormField(
                                    focusNode: cityFocusNode,
                                    controller: cityController,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                        enabledBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide.none
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide.none
                                        ),
                                        hintText: 'City',
                                        hintStyle: TextStyle(
                                          fontFamily: 'roboto',
                                          fontSize: 16,
                                          color: Colors.grey.shade500,
                                        )
                                    ),
                                  )
                              ),
                            ),),
                            const SizedBox(width: 20,),
                            Expanded(child: Container(
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
                                    focusNode: stateFocusNode,
                                    controller: stateController,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                        enabledBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide.none
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide.none
                                        ),
                                        hintText: 'State (Short code)',
                                        hintStyle: TextStyle(
                                          fontFamily: 'roboto',
                                          fontSize: 16,
                                          color: Colors.grey.shade500,
                                        )
                                    ),
                                  )
                              ),
                            ),)
                          ],
                        ),
                        const SizedBox(height: 15,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(child: Container(
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
                                  padding: const EdgeInsets.only(left: 25),
                                  child: TextFormField(
                                    focusNode: countryFocusNode,
                                    controller: countryController,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                        enabledBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide.none
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide.none
                                        ),
                                        hintText: 'Country (Short code)',
                                        hintStyle: TextStyle(
                                          fontFamily: 'roboto',
                                          fontSize: 16,
                                          color: Colors.grey.shade500,
                                        )
                                    ),
                                  )
                              ),
                            ),),
                            const SizedBox(width: 20,),
                            Container(
                              width: 110,
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
                                    focusNode: pinCodeFocusNode,
                                    controller: pinCodeController,
                                    textAlignVertical: TextAlignVertical.center,
                                    style: const TextStyle(
                                      fontSize: 16,
                                    ),
                                    decoration: InputDecoration(
                                        enabledBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide.none
                                        ),
                                        focusedBorder: const UnderlineInputBorder(
                                            borderSide: BorderSide.none
                                        ),
                                        hintText: 'Pin code',
                                        hintStyle: TextStyle(
                                          fontFamily: 'roboto',
                                          fontSize: 16,
                                          color: Colors.grey.shade500,
                                        )
                                    ),
                                  )
                              ),
                            ),
                          ],
                        )

                      ],
                    ),
                ),
                GestureDetector(
                  onTap: () {
                    if(amountFocusNode.hasFocus){
                      amountFocusNode.unfocus();
                    }
                    else if(nameFocusNode.hasFocus) {
                      nameFocusNode.unfocus();
                    }
                    else if(addressFocusNode.hasFocus) {
                      addressFocusNode.unfocus();
                    }
                    else if(cityFocusNode.hasFocus) {
                      cityFocusNode.unfocus();
                    }
                    else if(stateFocusNode.hasFocus) {
                      stateFocusNode.unfocus();
                    }
                    else if(countryFocusNode.hasFocus) {
                      countryFocusNode.unfocus();
                    }
                    else if(pinCodeFocusNode.hasFocus) {
                      pinCodeFocusNode.unfocus();
                    }
                  },
                  child: SizedBox(
                    width: 300,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        ElevatedButton(
                          onPressed: () async {
                            if(amountFocusNode.hasFocus){
                              amountFocusNode.unfocus();
                            }
                            else if(nameFocusNode.hasFocus) {
                              nameFocusNode.unfocus();
                            }
                            else if(addressFocusNode.hasFocus) {
                              addressFocusNode.unfocus();
                            }
                            else if(cityFocusNode.hasFocus) {
                              cityFocusNode.unfocus();
                            }
                            else if(stateFocusNode.hasFocus) {
                              stateFocusNode.unfocus();
                            }
                            else if(countryFocusNode.hasFocus) {
                              countryFocusNode.unfocus();
                            }
                            else if(pinCodeFocusNode.hasFocus) {
                              pinCodeFocusNode.unfocus();
                            }

                            if(amountController.text.isNotEmpty && nameController.text.isNotEmpty && addressController.text.isNotEmpty && cityController.text.isNotEmpty && stateController.text.isNotEmpty && countryController.text.isNotEmpty && pinCodeController.text.isNotEmpty) {
                              setState(() {
                                isLoading = true;
                              });
                              try {
                                await _processPayment();
                                Utilities().successMsg('Payment Done');
                              } catch(e) {
                                debugPrint(e.toString());
                                setState(() => isLoading = false);
                                Utilities().errorMsg('Payment failed. Try again.');
                              }
                            }
                            else {
                              Utilities().errorMsg('Please fill all fields');
                            }
                          },
                          style: ElevatedButton.styleFrom(
                              fixedSize: const Size(200, 20),
                              backgroundColor: Colors.blue,
                              shape: RoundedRectangleBorder(
                                  borderRadius:
                                  BorderRadius.circular(15))),
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
                              : const Text('Proceed to Pay',
                              style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                              )),

                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
              ],
            ),
          ),
        )
    );
  }
}