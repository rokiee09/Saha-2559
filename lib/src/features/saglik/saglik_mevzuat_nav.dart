import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../common/routing/transitions.dart';
import '../mevzuat/mevzuat_article_detail_page.dart';
import 'saglik_metin.dart';
import 'saglik_metin_okuma_page.dart';
import 'saglik_rehberi_data.dart';

Future<void> openSaglikMevzuatRef(
  BuildContext context,
  SaglikMevzuatRef ref,
) async {
  if (ref.isInAppMevzuat) {
    await Navigator.of(context).push(
      fadeRoute(
        MevzuatArticleDetailPage(
          entryId: ref.entryId!,
          focusSectionId: ref.sectionId,
        ),
      ),
    );
    return;
  }
  if (ref.isInAppSaglikMetin) {
    await Navigator.of(context).push(
      fadeRoute(
        SaglikMetinOkumaPage(
          metinId: ref.metinId!,
          focusSectionId: ref.metinSectionId,
        ),
      ),
    );
    return;
  }
  final uri = Uri.tryParse(ref.externalUrl ?? '');
  if (uri == null) return;
  final ok = await launchUrl(uri, mode: LaunchMode.externalApplication);
  if (!context.mounted) return;
  if (!ok) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(ref.notInAppNote ?? 'Bağlantı açılamadı.'),
      ),
    );
  }
}

Future<void> openSaglikMetin(
  BuildContext context,
  SaglikMetinId id, {
  String? sectionId,
}) {
  return Navigator.of(context).push(
    fadeRoute(
      SaglikMetinOkumaPage(
        metinId: id,
        focusSectionId: sectionId,
      ),
    ),
  );
}
