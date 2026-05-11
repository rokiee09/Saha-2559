import 'package:flutter/material.dart';

import '../../common/legal/user_agreement_document_body.dart';

/// Ayarlardan salt okunur açılış veya tam metin görüntüleme.
class UserAgreementViewerPage extends StatefulWidget {
  const UserAgreementViewerPage({super.key});

  @override
  State<UserAgreementViewerPage> createState() => _UserAgreementViewerPageState();
}

class _UserAgreementViewerPageState extends State<UserAgreementViewerPage> {
  final _scrollController = ScrollController();

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Kullanıcı sözleşmesi')),
      body: Scrollbar(
        controller: _scrollController,
        thumbVisibility: true,
        child: SingleChildScrollView(
          controller: _scrollController,
          padding: const EdgeInsets.fromLTRB(18, 16, 18, 32),
          child: const UserAgreementDocumentBody(),
        ),
      ),
    );
  }
}
