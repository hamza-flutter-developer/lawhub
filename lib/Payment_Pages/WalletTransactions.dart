// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:intl/intl.dart';

class WalletTransactions extends StatefulWidget {
  final bool isUser;
  const WalletTransactions({super.key, required this.isUser});

  @override
  State<WalletTransactions> createState() => _WalletTransactionsState();
}

class _WalletTransactionsState extends State<WalletTransactions> {
  bool _isLoading = true;
  List<Map<String, dynamic>> _transactions = [];

  @override
  void initState() {
    super.initState();
    _loadTransactions();
  }

  Future<void> _loadTransactions() async {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    try {
      final snap = await FirebaseFirestore.instance
          .collection('Wallets')
          .doc(email)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .get();

      final list = <Map<String, dynamic>>[];
      for (var doc in snap.docs) {
        final data = doc.data();
        list.add({
          'type': data['type'] ?? '',
          'amount': (data['amount'] ?? 0).toDouble(),
          'otherPartyName': data['otherPartyName'] ?? '',
          'otherPartyEmail': data['otherPartyEmail'] ?? '',
          'otherPartyImage': data['otherPartyImage'] ?? 'null',
          'createdAt': data['createdAt'] as Timestamp?,
        });
      }

      if (mounted) {
        setState(() {
          _transactions = list;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    final dt = ts.toDate();
    return DateFormat('dd MMM yyyy, h:mm a').format(dt);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.shade50,
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
            child: Text('Transaction History',
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
      body: _isLoading
          ? const Center(child: SpinKitCircle(color: Colors.blue, size: 34))
          : _transactions.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(FontAwesomeIcons.receipt,
                          size: 50, color: Colors.grey.shade300),
                      const SizedBox(height: 15),
                      Text('No transactions yet',
                          style: TextStyle(
                              fontFamily: 'roboto',
                              fontSize: 16,
                              color: Colors.grey.shade500)),
                    ],
                  ),
                )
              : ListView.builder(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
                  itemCount: _transactions.length,
                  itemBuilder: (context, index) {
                    final txn = _transactions[index];
                    return _buildTransactionCard(txn);
                  },
                ),
    );
  }

  Widget _buildTransactionCard(Map<String, dynamic> txn) {
    final type = txn['type'] as String;
    final amount = txn['amount'] as double;
    final name = txn['otherPartyName'] as String;
    final image = txn['otherPartyImage'] as String;
    final hasImage = image != 'null' && image.isNotEmpty;

    final isSent = type == 'sent';
    final isTopUp = type == 'topup';

    IconData icon;
    Color iconBgColor;
    Color amountColor;
    String amountPrefix;
    String subtitle;

    if (isTopUp) {
      icon = FontAwesomeIcons.plus;
      iconBgColor = Colors.green.shade50;
      amountColor = Colors.green;
      amountPrefix = '+';
      subtitle = 'Wallet Top-up';
    } else if (isSent) {
      icon = FontAwesomeIcons.arrowUp;
      iconBgColor = Colors.red.shade50;
      amountColor = Colors.red;
      amountPrefix = '-';
      subtitle = 'Sent to $name';
    } else {
      icon = FontAwesomeIcons.arrowDown;
      iconBgColor = Colors.green.shade50;
      amountColor = Colors.green;
      amountPrefix = '+';
      subtitle = 'Received from $name';
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.15),
              blurRadius: 6,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            isTopUp
                ? Container(
                    width: 48,
                    height: 48,
                    decoration: BoxDecoration(
                      color: iconBgColor,
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Icon(icon, color: amountColor, size: 18),
                  )
                : CircleAvatar(
                    radius: 24,
                    backgroundColor: Colors.grey[200],
                    backgroundImage:
                        hasImage ? NetworkImage(image) : null,
                    child: hasImage
                        ? null
                        : const Icon(Icons.person,
                            color: Colors.grey, size: 22),
                  ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(subtitle,
                      style: const TextStyle(
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.w600,
                          fontSize: 15)),
                  const SizedBox(height: 3),
                  Text(_formatDate(txn['createdAt']),
                      style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 12,
                          color: Colors.grey.shade500)),
                ],
              ),
            ),
            Text('$amountPrefix Rs.${amount.toStringAsFixed(0)}',
                style: TextStyle(
                    fontFamily: 'roboto',
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: amountColor)),
          ],
        ),
      ),
    );
  }
}
