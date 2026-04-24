import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:lawhub/Payment_Pages/CreatePayment.dart';
import 'package:lawhub/Payment_Pages/SendMoney.dart';
import 'package:lawhub/Payment_Pages/WalletTransactions.dart';
import 'package:intl/intl.dart';

class ManagePayment extends StatefulWidget {
  final bool isUser;
  const ManagePayment({super.key, required this.isUser});

  @override
  State<ManagePayment> createState() => _ManagePaymentState();
}

class _ManagePaymentState extends State<ManagePayment> {
  double _balance = 0;
  bool _isLoading = true;
  List<Map<String, dynamic>> _recentTransactions = [];

  @override
  void initState() {
    super.initState();
    _loadWallet();
  }

  Future<void> _loadWallet() async {
    final email = FirebaseAuth.instance.currentUser?.email ?? '';
    try {
      final walletDoc = await FirebaseFirestore.instance
          .collection('Wallets')
          .doc(email)
          .get();

      double balance = 0;
      if (walletDoc.exists) {
        balance = (walletDoc.data()?['balance'] ?? 0).toDouble();
      }

      final txnSnap = await FirebaseFirestore.instance
          .collection('Wallets')
          .doc(email)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .limit(5)
          .get();

      final recent = <Map<String, dynamic>>[];
      for (var doc in txnSnap.docs) {
        final data = doc.data();
        recent.add({
          'type': data['type'] ?? '',
          'amount': (data['amount'] ?? 0).toDouble(),
          'otherPartyName': data['otherPartyName'] ?? '',
          'otherPartyImage': data['otherPartyImage'] ?? 'null',
          'createdAt': data['createdAt'] as Timestamp?,
        });
      }

      if (mounted) {
        setState(() {
          _balance = balance;
          _recentTransactions = recent;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  String _formatDate(Timestamp? ts) {
    if (ts == null) return '';
    return DateFormat('dd MMM, h:mm a').format(ts.toDate());
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
            child: Text('My Wallet',
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
          : RefreshIndicator(
              onRefresh: () async {
                setState(() => _isLoading = true);
                await _loadWallet();
              },
              child: SingleChildScrollView(
                physics: const AlwaysScrollableScrollPhysics(),
                child: Column(
                  children: [
                    _buildBalanceCard(),
                    const SizedBox(height: 25),
                    _buildActionButtons(),
                    const SizedBox(height: 30),
                    _buildRecentTransactions(),
                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
    );
  }

  Widget _buildBalanceCard() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 25, 20, 0),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 25),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Colors.blue.shade700, Colors.blue.shade400],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.blue.withOpacity(0.35),
              blurRadius: 15,
              offset: const Offset(0, 8),
            )
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Available Balance',
                style: TextStyle(
                    fontFamily: 'roboto',
                    fontSize: 14,
                    color: Colors.white70)),
            const SizedBox(height: 8),
            Text('Rs. ${_balance.toStringAsFixed(0)}',
                style: const TextStyle(
                    fontFamily: 'roboto',
                    fontSize: 36,
                    fontWeight: FontWeight.bold,
                    color: Colors.white)),
            const SizedBox(height: 8),
            Text(
              FirebaseAuth.instance.currentUser?.email ?? '',
              style: const TextStyle(
                  fontFamily: 'roboto', fontSize: 13, color: Colors.white60),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionButtons() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Row(
        children: [
          Expanded(
            child: _actionButton(
              icon: FontAwesomeIcons.paperPlane,
              label: 'Send\nMoney',
              color: Colors.blue,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => SendMoney(isUser: widget.isUser)),
                );
                if (result == true) {
                  setState(() => _isLoading = true);
                  _loadWallet();
                }
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _actionButton(
              icon: FontAwesomeIcons.plus,
              label: 'Add\nMoney',
              color: Colors.green,
              onTap: () async {
                final result = await Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => CreatePayment(isUser: widget.isUser)),
                );
                if (result == true) {
                  setState(() => _isLoading = true);
                  _loadWallet();
                }
              },
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: _actionButton(
              icon: FontAwesomeIcons.clockRotateLeft,
              label: 'All\nHistory',
              color: Colors.orange,
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) =>
                          WalletTransactions(isUser: widget.isUser)),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _actionButton({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        height: 100,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black12.withOpacity(0.15),
              blurRadius: 8,
              offset: const Offset(0, 3),
            )
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(icon, color: color, size: 18),
            ),
            const SizedBox(height: 8),
            Text(label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                    fontFamily: 'roboto',
                    fontSize: 12,
                    fontWeight: FontWeight.w600)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentTransactions() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Recent Activity',
              style: TextStyle(
                  fontFamily: 'roboto',
                  fontSize: 18,
                  fontWeight: FontWeight.bold)),
          const SizedBox(height: 12),
          if (_recentTransactions.isEmpty)
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(30),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(15),
              ),
              child: Column(
                children: [
                  Icon(FontAwesomeIcons.wallet,
                      size: 35, color: Colors.grey.shade300),
                  const SizedBox(height: 10),
                  Text('No transactions yet',
                      style: TextStyle(
                          fontFamily: 'roboto',
                          fontSize: 14,
                          color: Colors.grey.shade500)),
                ],
              ),
            )
          else
            ...List.generate(_recentTransactions.length, (i) {
              final txn = _recentTransactions[i];
              final type = txn['type'] as String;
              final amount = txn['amount'] as double;
              final name = txn['otherPartyName'] as String;
              final isTopUp = type == 'topup';
              final isSent = type == 'sent';

              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 38,
                        height: 38,
                        decoration: BoxDecoration(
                          color: isSent
                              ? Colors.red.shade50
                              : Colors.green.shade50,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Icon(
                          isTopUp
                              ? FontAwesomeIcons.plus
                              : isSent
                                  ? FontAwesomeIcons.arrowUp
                                  : FontAwesomeIcons.arrowDown,
                          size: 14,
                          color: isSent ? Colors.red : Colors.green,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              isTopUp
                                  ? 'Top-up'
                                  : isSent
                                      ? name
                                      : name,
                              style: const TextStyle(
                                  fontFamily: 'roboto',
                                  fontWeight: FontWeight.w600,
                                  fontSize: 14),
                            ),
                            Text(_formatDate(txn['createdAt']),
                                style: TextStyle(
                                    fontFamily: 'roboto',
                                    fontSize: 11,
                                    color: Colors.grey.shade500)),
                          ],
                        ),
                      ),
                      Text(
                        '${isSent ? '-' : '+'}Rs.${amount.toStringAsFixed(0)}',
                        style: TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 15,
                            color: isSent ? Colors.red : Colors.green),
                      ),
                    ],
                  ),
                ),
              );
            }),
        ],
      ),
    );
  }
}
