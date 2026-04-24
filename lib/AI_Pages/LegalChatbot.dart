// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'CaseResearch.dart';
import 'LegalChatbotService.dart';

class LegalChatbot extends StatefulWidget {
  final bool isLawyer;
  final bool isVerified;
  const LegalChatbot({
    super.key,
    this.isLawyer = false,
    this.isVerified = false,
  });

  @override
  State<LegalChatbot> createState() => _LegalChatbotState();
}

class _LegalChatbotState extends State<LegalChatbot> {
  final TextEditingController _controller = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  final List<_ChatMessage> _messages = [];
  final List<Map<String, String>> _history = [];
  bool _sending = false;

  @override
  void initState() {
    super.initState();
    _messages.add(_ChatMessage(
      text: 'Hello! I am LawHub AI, your legal assistant. '
          'Ask me anything about Pakistani or international law.',
      isUser: false,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _send() async {
    final text = _controller.text.trim();
    if (text.isEmpty || _sending) return;

    setState(() {
      _messages.add(_ChatMessage(text: text, isUser: true));
      _sending = true;
    });
    _controller.clear();
    _scrollToBottom();

    final reply = await LegalChatbotService.chat(text, _history);

    _history.add({'role': 'user', 'content': text});
    _history.add({'role': 'assistant', 'content': reply});

    if (mounted) {
      setState(() {
        _messages.add(_ChatMessage(text: reply, isUser: false));
        _sending = false;
      });
      _scrollToBottom();
    }
  }

  void _scrollToBottom() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (_scrollController.hasClients) {
        _scrollController.animateTo(
          _scrollController.position.maxScrollExtent,
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOut,
        );
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(60),
        child: AppBar(
          toolbarHeight: 70,
          leadingWidth: 40,
          backgroundColor: const Color(0xFF1565C0),
          leading: Padding(
            padding: const EdgeInsets.only(top: 8, left: 10),
            child: IconButton(
              icon: const Icon(FontAwesomeIcons.angleLeft, color: Colors.white),
              onPressed: () => Navigator.of(context).pop(),
            ),
          ),
          title: const Padding(
            padding: EdgeInsets.only(top: 13),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(FontAwesomeIcons.robot, color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(
                  'LawHub AI',
                  style: TextStyle(
                    fontFamily: 'roboto',
                    fontWeight: FontWeight.bold,
                    fontSize: 20,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          centerTitle: true,
          actions: [
            if (widget.isLawyer && widget.isVerified)
              Padding(
                padding: const EdgeInsets.only(top: 8, right: 6),
                child: IconButton(
                  tooltip: 'Case Research',
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const CaseResearch(),
                      ),
                    );
                  },
                  icon: const Icon(
                    FontAwesomeIcons.scaleBalanced,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
              ),
          ],
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
          if (widget.isLawyer && widget.isVerified)
            GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const CaseResearch()),
                );
              },
              child: Container(
                width: double.infinity,
                margin: const EdgeInsets.fromLTRB(14, 12, 14, 0),
                padding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF1565C0), Color(0xFF0D47A1)],
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF1565C0).withAlpha(60),
                      blurRadius: 8,
                      offset: const Offset(0, 3),
                    ),
                  ],
                ),
                child: const Row(
                  children: [
                    Icon(FontAwesomeIcons.scaleBalanced,
                        color: Colors.white, size: 18),
                    SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Case Research',
                            style: TextStyle(
                              color: Colors.white,
                              fontFamily: 'roboto',
                              fontWeight: FontWeight.bold,
                              fontSize: 14,
                            ),
                          ),
                          SizedBox(height: 2),
                          Text(
                            'Search precedents, win/loss stats & legal strategy',
                            style: TextStyle(
                              color: Colors.white70,
                              fontFamily: 'roboto',
                              fontSize: 11,
                            ),
                          ),
                        ],
                      ),
                    ),
                    Icon(FontAwesomeIcons.angleRight,
                        color: Colors.white70, size: 14),
                  ],
                ),
              ),
            ),
          Expanded(child: _buildMessages()),
          _buildComposer(),
        ],
      ),
    );
  }

  Widget _buildMessages() {
    return ListView.builder(
      controller: _scrollController,
      padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
      itemCount: _messages.length + (_sending ? 1 : 0),
      itemBuilder: (context, i) {
        if (i == _messages.length && _sending) {
          return const Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 8, horizontal: 4),
              child: SpinKitThreeBounce(color: Color(0xFF1565C0), size: 20),
            ),
          );
        }
        final msg = _messages[i];
        return _bubble(msg);
      },
    );
  }

  Widget _bubble(_ChatMessage msg) {
    final bg = msg.isUser ? const Color(0xFF1565C0) : Colors.white;
    final fg = msg.isUser ? Colors.white : const Color(0xFF1F2937);

    return Align(
      alignment: msg.isUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints: BoxConstraints(
          maxWidth: MediaQuery.of(context).size.width * 0.8,
        ),
        margin: const EdgeInsets.symmetric(vertical: 4),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
        decoration: BoxDecoration(
          color: bg,
          borderRadius: BorderRadius.only(
            topLeft: const Radius.circular(16),
            topRight: const Radius.circular(16),
            bottomLeft: Radius.circular(msg.isUser ? 16 : 4),
            bottomRight: Radius.circular(msg.isUser ? 4 : 16),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withAlpha(15),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            if (!msg.isUser)
              Padding(
                padding: const EdgeInsets.only(bottom: 4),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(FontAwesomeIcons.robot,
                        size: 10, color: Colors.blue.shade700),
                    const SizedBox(width: 5),
                    Text(
                      'LawHub AI',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue.shade700,
                        fontFamily: 'roboto',
                      ),
                    ),
                  ],
                ),
              ),
            SelectableText(
              msg.text,
              style: TextStyle(
                color: fg,
                fontSize: 14,
                fontFamily: 'roboto',
                height: 1.4,
              ),
            ),
          ],
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
                controller: _controller,
                minLines: 1,
                maxLines: 5,
                textCapitalization: TextCapitalization.sentences,
                style: const TextStyle(fontSize: 15, fontFamily: 'roboto'),
                decoration: InputDecoration(
                  hintText: 'Ask a legal question…',
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
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
                    borderSide: const BorderSide(color: Color(0xFF1565C0)),
                  ),
                ),
                onSubmitted: (_) => _send(),
              ),
            ),
            const SizedBox(width: 6),
            Material(
              color: const Color(0xFF1565C0),
              shape: const CircleBorder(),
              child: InkWell(
                customBorder: const CircleBorder(),
                onTap: _sending ? null : _send,
                child: const SizedBox(
                  width: 44,
                  height: 44,
                  child: Icon(Icons.send, color: Colors.white, size: 20),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ChatMessage {
  final String text;
  final bool isUser;
  _ChatMessage({required this.text, required this.isUser});
}
