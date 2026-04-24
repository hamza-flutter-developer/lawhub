// ignore_for_file: file_names

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

class HelpSupportChat extends StatefulWidget {
  final String ticketId;
  const HelpSupportChat({super.key, required this.ticketId});

  @override
  State<HelpSupportChat> createState() => _HelpSupportChatState();
}

class _HelpSupportChatState extends State<HelpSupportChat> {
  final TextEditingController _messageController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  late final String? _email;
  bool _sending = false;

  DocumentReference<Map<String, dynamic>> get _ticketRef =>
      _db.collection('HelpSupportTickets').doc(widget.ticketId);

  @override
  void initState() {
    super.initState();
    _email = FirebaseAuth.instance.currentUser?.email;
    _markUserRead();
  }

  @override
  void dispose() {
    _messageController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _markUserRead() async {
    try {
      await _ticketRef.update({'unreadByUser': 0});
    } catch (_) {}
  }

  Future<void> _sendMessage() async {
    final text = _messageController.text.trim();
    final email = _email;
    if (text.isEmpty || email == null || _sending) return;

    setState(() => _sending = true);
    _messageController.clear();

    try {
      final snap = await _ticketRef.get();
      final data = snap.data();
      final wasResolved = (data?['status'] as String?) == 'resolved';
      final now = FieldValue.serverTimestamp();

      await _ticketRef.collection('messages').add({
        'text': text,
        'senderId': email,
        'senderRole': 'user',
        'createdAt': now,
      });

      final updates = <String, dynamic>{
        'lastMessage': text,
        'lastMessageAt': now,
        'updatedAt': now,
        'unreadByAdmin': FieldValue.increment(1),
      };
      if (wasResolved) {
        updates['status'] = 'open';
        updates['resolvedAt'] = FieldValue.delete();
      }
      await _ticketRef.update(updates);

      WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Could not send: $e')),
        );
      }
    } finally {
      if (mounted) setState(() => _sending = false);
    }
  }

  void _scrollToBottom() {
    if (!_scrollController.hasClients) return;
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: const Duration(milliseconds: 200),
      curve: Curves.easeOut,
    );
  }

  String _fmtTime(Timestamp? ts) {
    if (ts == null) return '';
    final d = ts.toDate();
    final h = d.hour > 12 ? d.hour - 12 : (d.hour == 0 ? 12 : d.hour);
    final m = d.minute.toString().padLeft(2, '0');
    final p = d.hour >= 12 ? 'PM' : 'AM';
    return '$h:$m $p';
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
              "Support Chat",
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
      body: Column(
        children: [
          _buildStatusBanner(),
          Expanded(child: _buildMessageList()),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildStatusBanner() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _ticketRef.snapshots(),
      builder: (context, snap) {
        final data = snap.data?.data();
        final status = (data?['status'] as String?) ?? 'open';
        Color bg;
        String label;
        switch (status) {
          case 'resolved':
            bg = const Color(0xFFDCFCE7);
            label = 'Resolved — send a message to reopen';
            break;
          case 'in_progress':
            bg = const Color(0xFFE0F2FE);
            label = 'Support is looking into your ticket';
            break;
          default:
            bg = const Color(0xFFFEF3C7);
            label = 'Open — waiting for support to respond';
        }
        return Container(
          width: double.infinity,
          color: bg,
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: Text(
            label,
            style: const TextStyle(
              fontFamily: 'roboto',
              fontSize: 12,
              fontWeight: FontWeight.w600,
              color: Color(0xFF374151),
            ),
            textAlign: TextAlign.center,
          ),
        );
      },
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: _ticketRef
          .collection('messages')
          .orderBy('createdAt', descending: false)
          .snapshots(),
      builder: (context, snap) {
        if (snap.connectionState == ConnectionState.waiting) {
          return const Center(child: SpinKitCircle(color: Colors.blue, size: 36));
        }
        if (snap.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Text(
                'Failed to load messages: ${snap.error}',
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.red),
              ),
            ),
          );
        }
        final docs = snap.data?.docs ?? [];
        if (docs.isEmpty) {
          return const Center(
            child: Text(
              'No messages yet.',
              style: TextStyle(color: Colors.grey, fontFamily: 'roboto'),
            ),
          );
        }

        WidgetsBinding.instance.addPostFrameCallback((_) => _scrollToBottom());
        _markUserRead();

        return ListView.builder(
          controller: _scrollController,
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
          itemCount: docs.length,
          itemBuilder: (context, i) {
            final m = docs[i].data();
            final role = (m['senderRole'] as String?) ?? 'user';
            final isMine = role == 'user';
            final text = (m['text'] as String?) ?? '';
            final ts = m['createdAt'] as Timestamp?;
            return _bubble(text: text, isMine: isMine, time: _fmtTime(ts));
          },
        );
      },
    );
  }

  Widget _bubble({required String text, required bool isMine, required String time}) {
    final bg = isMine ? Colors.blue : const Color(0xFFF1F3F5);
    final fg = isMine ? Colors.white : const Color(0xFF1F2937);
    final timeColor = isMine ? Colors.white70 : Colors.grey;
    return Align(
      alignment: isMine ? Alignment.centerRight : Alignment.centerLeft,
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.78,
        ),
        child: Container(
          margin: const EdgeInsets.symmetric(vertical: 4),
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: BorderRadius.only(
              topLeft: const Radius.circular(16),
              topRight: const Radius.circular(16),
              bottomLeft: Radius.circular(isMine ? 16 : 4),
              bottomRight: Radius.circular(isMine ? 4 : 16),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              if (!isMine)
                Padding(
                  padding: const EdgeInsets.only(bottom: 3),
                  child: Text(
                    'Support',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue.shade700,
                      fontFamily: 'roboto',
                    ),
                  ),
                ),
              Text(
                text,
                style: TextStyle(
                  color: fg,
                  fontSize: 15,
                  fontFamily: 'roboto',
                ),
              ),
              if (time.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.only(top: 4),
                  child: Text(
                    time,
                    style: TextStyle(color: timeColor, fontSize: 10),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildComposer() {
    return SafeArea(
      top: false,
      child: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: Color(0xFFE5E7EB))),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: TextField(
                controller: _messageController,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 15, fontFamily: 'roboto'),
                decoration: InputDecoration(
                  hintText: 'Type a message…',
                  contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: Color(0xFFE5E7EB)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(22),
                    borderSide: const BorderSide(color: Colors.blue),
                  ),
                ),
                onSubmitted: (_) => _sendMessage(),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: Colors.blue,
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _sending ? null : _sendMessage,
                child: SizedBox(
                  width: 44,
                  height: 44,
                  child: _sending
                      ? const Padding(
                          padding: EdgeInsets.all(10),
                          child: SpinKitCircle(color: Colors.white, size: 24),
                        )
                      : const Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
