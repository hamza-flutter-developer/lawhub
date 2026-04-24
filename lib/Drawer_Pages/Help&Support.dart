// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'HelpSupportChat.dart';

class HelpSupport extends StatefulWidget {
  const HelpSupport({super.key});

  @override
  State<HelpSupport> createState() => _HelpSupportState();
}

class _HelpSupportState extends State<HelpSupport> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailPhoneController = TextEditingController();
  final TextEditingController _statementController = TextEditingController();
  final _form = GlobalKey<FormState>();

  bool _checkingExisting = true;
  bool _submitting = false;
  String? _email;

  @override
  void initState() {
    super.initState();
    _email = FirebaseAuth.instance.currentUser?.email;
    _resolveExistingTicket();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailPhoneController.dispose();
    _statementController.dispose();
    super.dispose();
  }

  Future<void> _resolveExistingTicket() async {
    final email = _email;
    if (email == null) {
      if (mounted) setState(() => _checkingExisting = false);
      return;
    }
    try {
      final snap = await FirebaseFirestore.instance
          .collection('HelpSupportTickets')
          .where('userId', isEqualTo: email)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .get();

      if (!mounted) return;
      if (snap.docs.isNotEmpty) {
        final ticketId = snap.docs.first.id;
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => HelpSupportChat(ticketId: ticketId),
          ),
        );
        return;
      }
    } catch (_) {
      // Fall through to the form so the user can still submit.
    }
    if (mounted) setState(() => _checkingExisting = false);
  }

  Future<void> _submitTicket() async {
    if (!_form.currentState!.validate()) return;
    final email = _email;
    if (email == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('You must be signed in to submit a ticket.')),
      );
      return;
    }

    setState(() => _submitting = true);
    try {
      final db = FirebaseFirestore.instance;
      final userDoc = await db.collection('Users').doc(email).get();
      final userType = userDoc.exists ? 'user' : 'lawyer';
      final problem = _statementController.text.trim();
      final now = FieldValue.serverTimestamp();

      final ticketRef = await db.collection('HelpSupportTickets').add({
        'userId': email,
        'userType': userType,
        'name': _nameController.text.trim(),
        'contact': _emailPhoneController.text.trim(),
        'problem': problem,
        'status': 'open',
        'createdAt': now,
        'updatedAt': now,
        'lastMessage': problem,
        'lastMessageAt': now,
        'unreadByAdmin': 1,
        'unreadByUser': 0,
      });

      await ticketRef.collection('messages').add({
        'text': problem,
        'senderId': email,
        'senderRole': 'user',
        'createdAt': now,
      });

      if (!mounted) return;
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => HelpSupportChat(ticketId: ticketRef.id),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to submit ticket: $e')),
      );
    } finally {
      if (mounted) setState(() => _submitting = false);
    }
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
            padding: const EdgeInsets.only(top: 8, left: 10),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Text(
              "Help & Support",
              style: TextStyle(
                fontFamily: 'roboto',
                fontWeight: FontWeight.bold,
                fontSize: 20,
                color: Colors.white,
              ),
            ),
          ),
          centerTitle: true,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
      ),
      body: _checkingExisting
          ? const Center(child: SpinKitCircle(color: Colors.blue, size: 40))
          : _buildForm(context),
    );
  }

  Widget _buildForm(BuildContext context) {
    return SingleChildScrollView(
      child: SizedBox(
        width: double.infinity,
        child: Column(
          children: [
            Padding(
              padding: EdgeInsets.only(top: 0.04 * MediaQuery.of(context).size.height),
              child: const Text(
                'Tech Support',
                style: TextStyle(
                  fontFamily: 'roboto',
                  fontWeight: FontWeight.bold,
                  fontSize: 20,
                  wordSpacing: 2,
                ),
              ),
            ),
            Padding(
              padding: EdgeInsets.only(top: 0.02 * MediaQuery.of(context).size.height),
              child: SizedBox(
                width: 80,
                height: 80,
                child: Image.asset('assets/images/customer-support.png'),
              ),
            ),
            Padding(
              padding: EdgeInsets.all(0.05 * MediaQuery.of(context).size.height),
              child: Form(
                key: _form,
                child: Column(
                  children: [
                    TextFormField(
                      controller: _nameController,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontSize: 15),
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        prefixIcon: Icon(FontAwesomeIcons.userLarge, size: 18),
                        prefixIconColor: Colors.black,
                        prefixIconConstraints: BoxConstraints(minWidth: 65),
                        hintText: "Full Name",
                        focusColor: Colors.black,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return "Enter Name";
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _emailPhoneController,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontSize: 15),
                      keyboardType: TextInputType.emailAddress,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        prefixIcon: Icon(Icons.email, size: 22),
                        prefixIconColor: Colors.black,
                        prefixIconConstraints: BoxConstraints(minWidth: 65),
                        hintText: "Email/Phone No",
                        focusColor: Colors.black,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return "Enter Email/Phone No";
                        return null;
                      },
                    ),
                    const SizedBox(height: 10),
                    TextFormField(
                      controller: _statementController,
                      textAlignVertical: TextAlignVertical.center,
                      style: const TextStyle(fontSize: 15),
                      maxLines: 4,
                      decoration: const InputDecoration(
                        focusedBorder: UnderlineInputBorder(
                          borderSide: BorderSide(color: Colors.black),
                        ),
                        hintText: "Please Explain your problem",
                        focusColor: Colors.black,
                      ),
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) return "Please explain your problem";
                        return null;
                      },
                    ),
                  ],
                ),
              ),
            ),
            SizedBox(
              width: 300,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  ElevatedButton(
                    onPressed: _submitting ? null : _submitTicket,
                    style: ElevatedButton.styleFrom(
                      fixedSize: const Size(200, 20),
                      backgroundColor: Colors.blue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(15),
                      ),
                    ),
                    child: _submitting
                        ? Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                color: Colors.blue,
                                height: 20,
                                width: 20,
                                child: const SpinKitCircle(color: Colors.white, size: 20),
                              ),
                              const SizedBox(width: 5),
                              const Text(
                                'Submitting',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontFamily: 'roboto',
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ],
                          )
                        : const Text(
                            'Submit',
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
            const SizedBox(height: 10),
          ],
        ),
      ),
    );
  }
}
