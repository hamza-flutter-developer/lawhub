// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Utils/Utilities.dart';

class SendMoney extends StatefulWidget {
  final bool isUser;
  const SendMoney({super.key, required this.isUser});

  @override
  State<SendMoney> createState() => _SendMoneyState();
}

class _SendMoneyState extends State<SendMoney> {
  final TextEditingController _searchController = TextEditingController();
  final TextEditingController _amountController = TextEditingController();
  final FocusNode _searchFocus = FocusNode();
  final FocusNode _amountFocus = FocusNode();

  List<Map<String, dynamic>> _allPeople = [];
  List<Map<String, dynamic>> _filtered = [];
  Map<String, dynamic>? _selectedPerson;

  bool _isLoadingPeople = true;
  bool _isSending = false;

  @override
  void initState() {
    super.initState();
    _loadPeople();
  }

  Future<void> _loadPeople() async {
    final currentEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final List<Map<String, dynamic>> people = [];

    final usersSnap =
        await FirebaseFirestore.instance.collection('Users').get();
    for (var doc in usersSnap.docs) {
      if (doc.id != currentEmail) {
        people.add({
          'id': doc.id,
          'name': doc['name'] ?? '',
          'profilePic': doc['profilePic'] ?? 'null',
          'type': 'User',
        });
      }
    }

    final lawyersSnap =
        await FirebaseFirestore.instance.collection('Lawyers').get();
    for (var doc in lawyersSnap.docs) {
      if (doc.id != currentEmail) {
        people.add({
          'id': doc.id,
          'name': doc['name'] ?? '',
          'profilePic': doc['profilePic'] ?? 'null',
          'type': 'Lawyer',
        });
      }
    }

    if (mounted) {
      setState(() {
        _allPeople = people;
        _filtered = people;
        _isLoadingPeople = false;
      });
    }
  }

  void _onSearch(String query) {
    setState(() {
      if (query.isEmpty) {
        _filtered = _allPeople;
      } else {
        _filtered = _allPeople
            .where((p) =>
                p['name'].toString().toLowerCase().contains(query.toLowerCase()) ||
                p['id'].toString().toLowerCase().contains(query.toLowerCase()))
            .toList();
      }
    });
  }

  void _selectPerson(Map<String, dynamic> person) {
    setState(() {
      _selectedPerson = person;
      _searchController.clear();
      _searchFocus.unfocus();
    });
  }

  void _clearSelection() {
    setState(() {
      _selectedPerson = null;
      _amountController.clear();
    });
  }

  Future<void> _sendMoney() async {
    if (_selectedPerson == null) return;

    final amountText = _amountController.text.trim();
    if (amountText.isEmpty) {
      Utilities().errorMsg('Please enter an amount');
      return;
    }

    final amount = double.tryParse(amountText);
    if (amount == null || amount <= 0) {
      Utilities().errorMsg('Enter a valid amount');
      return;
    }

    final senderEmail = FirebaseAuth.instance.currentUser?.email ?? '';
    final recipientEmail = _selectedPerson!['id'] as String;
    final recipientName = _selectedPerson!['name'] as String;
    final recipientImage = _selectedPerson!['profilePic'] ?? 'null';

    if (senderEmail == recipientEmail) {
      Utilities().errorMsg('Cannot send money to yourself');
      return;
    }

    setState(() => _isSending = true);

    try {
      final db = FirebaseFirestore.instance;
      final senderWalletRef = db.collection('Wallets').doc(senderEmail);
      final recipientWalletRef = db.collection('Wallets').doc(recipientEmail);

      // Get sender name and image
      String senderName = 'Unknown';
      String senderImage = 'null';
      final senderUser = await db.collection('Users').doc(senderEmail).get();
      if (senderUser.exists) {
        senderName = senderUser.data()?['name'] ?? 'Unknown';
        senderImage = senderUser.data()?['profilePic'] ?? 'null';
      } else {
        final senderLawyer = await db.collection('Lawyers').doc(senderEmail).get();
        if (senderLawyer.exists) {
          senderName = senderLawyer.data()?['name'] ?? 'Unknown';
          senderImage = senderLawyer.data()?['profilePic'] ?? 'null';
        }
      }

      await db.runTransaction((transaction) async {
        final senderWallet = await transaction.get(senderWalletRef);
        final recipientWallet = await transaction.get(recipientWalletRef);

        final senderBalance = senderWallet.exists
            ? (senderWallet.data()?['balance'] ?? 0).toDouble()
            : 0.0;
        final recipientBalance = recipientWallet.exists
            ? (recipientWallet.data()?['balance'] ?? 0).toDouble()
            : 0.0;

        if (senderBalance < amount) {
          throw Exception('Insufficient balance');
        }

        transaction.set(senderWalletRef, {
          'balance': senderBalance - amount,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(recipientWalletRef, {
          'balance': recipientBalance + amount,
          'updatedAt': FieldValue.serverTimestamp(),
        }, SetOptions(merge: true));

        transaction.set(senderWalletRef.collection('transactions').doc(), {
          'type': 'sent',
          'amount': amount,
          'otherPartyEmail': recipientEmail,
          'otherPartyName': recipientName,
          'otherPartyImage': recipientImage,
          'createdAt': FieldValue.serverTimestamp(),
        });

        transaction.set(recipientWalletRef.collection('transactions').doc(), {
          'type': 'received',
          'amount': amount,
          'otherPartyEmail': senderEmail,
          'otherPartyName': senderName,
          'otherPartyImage': senderImage,
          'createdAt': FieldValue.serverTimestamp(),
        });
      });

      // Send notification to recipient
      final recipientIsUser = (await db.collection('Users').doc(recipientEmail).get()).exists;
      final notifCollection = recipientIsUser ? 'UsersNotifications' : 'LawyersNotifications';
      final senderKey = recipientIsUser ? 'lawyerID' : 'userID';
      final notifRef = db.collection(notifCollection).doc(recipientEmail);
      final notifDoc = await notifRef.get();

      int counter = 1;
      if (notifDoc.exists && notifDoc.data()?['counter'] != null) {
        counter = (notifDoc.data()!['counter'] as int) + 1;
      }

      await notifRef.set({
        'Notification$counter': [
          {senderKey: senderEmail},
          {'type': 'sent you Rs.${amount.toStringAsFixed(0)}'},
          {'isSeen': false},
        ],
        'counter': counter,
      }, SetOptions(merge: true));

      if (!mounted) return;
      Utilities().successMsg('Rs.${amount.toStringAsFixed(0)} sent to $recipientName');
      Navigator.pop(context, true);
    } catch (e) {
      if (mounted) {
        if (e.toString().contains('Insufficient balance')) {
          Utilities().errorMsg('Insufficient balance');
        } else {
          Utilities().errorMsg('Transfer failed. Try again.');
        }
      }
    }

    if (mounted) setState(() => _isSending = false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          toolbarHeight: 70,
          leadingWidth: 40,
          backgroundColor: Colors.blue,
          leading: Padding(
            padding: const EdgeInsets.only(top: 8, left: 10),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
              onPressed: () => Navigator.pop(context),
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text('Send Money',
                style: TextStyle(
                    fontFamily: 'roboto',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white)),
          ),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(25),
                bottomRight: Radius.circular(25)),
          ),
        ),
      ),
      body: _isLoadingPeople
          ? const Center(child: SpinKitCircle(color: Colors.blue, size: 34))
          : Column(
              children: [
                // Selected person card
                if (_selectedPerson != null) _buildSelectedCard(),

                // Search bar (hidden when person selected)
                if (_selectedPerson == null) _buildSearchBar(),

                // Results list or amount input
                Expanded(
                  child: _selectedPerson != null
                      ? _buildAmountInput()
                      : _buildResultsList(),
                ),
              ],
            ),
    );
  }

  Widget _buildSearchBar() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 10),
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
              offset: const Offset(1, 1),
            )
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 15),
          child: TextFormField(
            focusNode: _searchFocus,
            controller: _searchController,
            onChanged: _onSearch,
            textAlignVertical: TextAlignVertical.center,
            style: const TextStyle(fontSize: 16),
            decoration: InputDecoration(
              enabledBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
              focusedBorder: const UnderlineInputBorder(borderSide: BorderSide.none),
              hintText: 'Search by name or email...',
              hintStyle: TextStyle(
                  fontFamily: 'roboto', fontSize: 16, color: Colors.grey.shade500),
              prefixIcon: const Icon(Icons.search, color: Colors.blue),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildResultsList() {
    if (_filtered.isEmpty) {
      return Center(
        child: Text('No users found',
            style: TextStyle(
                fontFamily: 'roboto',
                fontSize: 16,
                color: Colors.grey.shade500)),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      itemCount: _filtered.length,
      itemBuilder: (context, index) {
        final person = _filtered[index];
        final hasImage =
            person['profilePic'] != 'null' && person['profilePic'] != null;

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: InkWell(
            onTap: () => _selectPerson(person),
            borderRadius: BorderRadius.circular(15),
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 15),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black12.withOpacity(0.2),
                    blurRadius: 6,
                    offset: const Offset(0, 2),
                  )
                ],
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    backgroundImage: hasImage
                        ? NetworkImage(person['profilePic'])
                        : null,
                    child: hasImage
                        ? null
                        : const Icon(Icons.person, color: Colors.grey),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(person['name'],
                            style: const TextStyle(
                                fontFamily: 'roboto',
                                fontWeight: FontWeight.bold,
                                fontSize: 16)),
                        const SizedBox(height: 2),
                        Text(person['id'],
                            style: TextStyle(
                                fontFamily: 'roboto',
                                fontSize: 13,
                                color: Colors.grey.shade600)),
                      ],
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: person['type'] == 'Lawyer'
                          ? Colors.blue.shade50
                          : Colors.green.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Text(person['type'],
                        style: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: person['type'] == 'Lawyer'
                                ? Colors.blue
                                : Colors.green)),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildSelectedCard() {
    final person = _selectedPerson!;
    final hasImage =
        person['profilePic'] != 'null' && person['profilePic'] != null;

    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: Colors.blue.shade50,
          borderRadius: BorderRadius.circular(15),
          border: Border.all(color: Colors.blue.shade200),
        ),
        child: Row(
          children: [
            CircleAvatar(
              radius: 26,
              backgroundColor: Colors.grey[200],
              backgroundImage:
                  hasImage ? NetworkImage(person['profilePic']) : null,
              child: hasImage
                  ? null
                  : const Icon(Icons.person, color: Colors.grey),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Sending to',
                      style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 12,
                          color: Colors.blue)),
                  Text(person['name'],
                      style: const TextStyle(
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 17)),
                ],
              ),
            ),
            IconButton(
              icon: const Icon(Icons.close, color: Colors.red),
              onPressed: _clearSelection,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildAmountInput() {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 30),
          const Text('Enter Amount',
              style: TextStyle(
                  fontFamily: 'roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 20),
          Container(
            height: 60,
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.grey.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 7,
                  offset: const Offset(1, 1),
                )
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 55,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: Colors.blue,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(15),
                      bottomLeft: Radius.circular(15),
                    ),
                  ),
                  child: const Text('Rs.',
                      style: TextStyle(
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 18,
                          color: Colors.white)),
                ),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 15),
                    child: TextFormField(
                      focusNode: _amountFocus,
                      controller: _amountController,
                      keyboardType: TextInputType.number,
                      style: const TextStyle(
                          fontSize: 22, fontWeight: FontWeight.bold),
                      decoration: InputDecoration(
                        enabledBorder:
                            const UnderlineInputBorder(borderSide: BorderSide.none),
                        focusedBorder:
                            const UnderlineInputBorder(borderSide: BorderSide.none),
                        hintText: '0',
                        hintStyle: TextStyle(
                            fontFamily: 'roboto',
                            fontSize: 22,
                            color: Colors.grey.shade400),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 40),
          SizedBox(
            width: 220,
            height: 48,
            child: ElevatedButton(
              onPressed: _isSending ? null : _sendMoney,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(15)),
              ),
              child: _isSending
                  ? const Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SpinKitCircle(color: Colors.white, size: 20),
                        SizedBox(width: 8),
                        Text('Sending...',
                            style: TextStyle(
                                color: Colors.white,
                                fontFamily: 'roboto',
                                fontSize: 16,
                                fontWeight: FontWeight.bold)),
                      ],
                    )
                  : const Text('Send Money',
                      style: TextStyle(
                          color: Colors.white,
                          fontFamily: 'roboto',
                          fontSize: 16,
                          fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }
}
