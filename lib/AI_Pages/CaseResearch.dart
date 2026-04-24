// ignore_for_file: file_names

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';

import 'LegalChatbotService.dart';

class CaseResearch extends StatefulWidget {
  const CaseResearch({super.key});

  @override
  State<CaseResearch> createState() => _CaseResearchState();
}

class _CaseResearchState extends State<CaseResearch> {
  final TextEditingController _descController = TextEditingController();
  final ScrollController _scrollController = ScrollController();
  bool _loading = false;
  String? _result;

  @override
  void dispose() {
    _descController.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  Future<void> _search() async {
    final desc = _descController.text.trim();
    if (desc.isEmpty || _loading) return;

    FocusScope.of(context).unfocus();
    setState(() {
      _loading = true;
      _result = null;
    });

    final result = await LegalChatbotService.searchCases(desc);

    if (mounted) {
      setState(() {
        _result = result;
        _loading = false;
      });
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (_scrollController.hasClients) {
          _scrollController.animateTo(
            _scrollController.position.maxScrollExtent,
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeOut,
          );
        }
      });
    }
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
          backgroundColor: const Color(0xFF0D47A1),
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
                Icon(FontAwesomeIcons.scaleBalanced,
                    color: Colors.white, size: 18),
                SizedBox(width: 10),
                Text(
                  'Case Research',
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
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(25),
              bottomRight: Radius.circular(25),
            ),
          ),
        ),
      ),
      body: SingleChildScrollView(
        controller: _scrollController,
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withAlpha(15),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(FontAwesomeIcons.magnifyingGlass,
                          size: 14, color: Colors.blue.shade800),
                      const SizedBox(width: 8),
                      const Text(
                        'Describe Your Case',
                        style: TextStyle(
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: Color(0xFF1F2937),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  const Text(
                    'Provide details: type of case, charges/claims, '
                    'parties involved, jurisdiction. The more detail you '
                    'give, the better the precedent matches.',
                    style: TextStyle(
                      fontFamily: 'roboto',
                      fontSize: 12,
                      color: Color(0xFF6B7280),
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: _descController,
                    maxLines: 6,
                    style:
                        const TextStyle(fontSize: 14, fontFamily: 'roboto'),
                    decoration: InputDecoration(
                      hintText:
                          'e.g. Murder case under PPC Section 302. '
                          'Accused is a family member. Victim was shot '
                          'during a property dispute in Lahore. '
                          'Looking for similar cases and outcomes…',
                      hintStyle: const TextStyle(
                        fontSize: 13,
                        color: Color(0xFFADB5BD),
                      ),
                      contentPadding: const EdgeInsets.all(14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFFE5E7EB)),
                      ),
                      focusedBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide:
                            const BorderSide(color: Color(0xFF1565C0)),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton.icon(
                      onPressed: _loading ? null : _search,
                      icon: _loading
                          ? const SizedBox(
                              width: 18,
                              height: 18,
                              child:
                                  SpinKitCircle(color: Colors.white, size: 18),
                            )
                          : const Icon(FontAwesomeIcons.magnifyingGlass,
                              size: 14),
                      label: Text(
                        _loading ? 'Searching Precedents…' : 'Search Cases',
                        style: const TextStyle(
                          fontFamily: 'roboto',
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF0D47A1),
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
            if (_loading)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 40),
                child: Center(
                  child: Column(
                    children: [
                      SpinKitFadingCircle(
                          color: Color(0xFF0D47A1), size: 40),
                      SizedBox(height: 14),
                      Text(
                        'Analyzing case details and searching\nfor relevant precedents…',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: 'roboto',
                          color: Color(0xFF6B7280),
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            if (_result != null) ...[
              const SizedBox(height: 20),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(18),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: const Color(0xFF0D47A1), width: 0.5),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withAlpha(15),
                      blurRadius: 8,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(FontAwesomeIcons.scaleBalanced,
                            size: 14, color: Colors.blue.shade800),
                        const SizedBox(width: 8),
                        const Text(
                          'Research Results',
                          style: TextStyle(
                            fontFamily: 'roboto',
                            fontWeight: FontWeight.bold,
                            fontSize: 16,
                            color: Color(0xFF1F2937),
                          ),
                        ),
                      ],
                    ),
                    const Divider(height: 20),
                    SelectableText(
                      _result!,
                      style: const TextStyle(
                        fontFamily: 'roboto',
                        fontSize: 14,
                        color: Color(0xFF374151),
                        height: 1.6,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 30),
            ],
          ],
        ),
      ),
    );
  }
}
