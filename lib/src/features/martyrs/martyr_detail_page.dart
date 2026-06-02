import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../common/theme/police_colors.dart';
import '../../common/widgets/turkish_flag_circle_icon.dart';
import 'martyr_provider.dart';
import 'martyrs_controller.dart';

class MartyrDetailPage extends ConsumerWidget {
  final int martyrId;

  const MartyrDetailPage({super.key, required this.martyrId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final martyrAsync = ref.watch(martyrProvider(martyrId));

    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: const Text('Şehit kaydı'),
      ),
      body: martyrAsync.when(
        data: (martyr) {
          if (martyr == null) {
            return const Center(child: Text('Kayıt bulunamadı.'));
          }

          final dateText = formatMartyrDate(martyr.dateOfMartyrdom);
          final cityText = martyr.cityName.trim().isEmpty ||
                  martyr.cityName.toLowerCase() == 'belirtilmedi'
              ? 'Belirtilmedi'
              : martyr.cityName;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _RowLabel(
                  label: 'Ad soyad / ünvan',
                  value: martyr.fullName,
                  strong: true,
                  valueLeading: const TurkishFlagAssetCircleIcon(size: 48),
                ),
                const SizedBox(height: 16),
                _RowLabel(label: 'Şehit olma tarihi', value: dateText),
                const SizedBox(height: 12),
                _RowLabel(label: 'İl', value: cityText),
                const SizedBox(height: 20),
                Text(
                  'Bu alanda anı metni veya yorum yoktur. '
                  'Güncel ve eksiksiz resmî kayıt için kurum duyuruları esas alınmalıdır.',
                  style: TextStyle(
                    color: PoliceColors.textMuted.withValues(alpha: 0.95),
                    height: 1.4,
                    fontSize: 12.5,
                  ),
                ),
              ],
            ),
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, _) => Center(child: Text('Hata: $e')),
      ),
    );
  }
}

class _RowLabel extends StatelessWidget {
  const _RowLabel({
    required this.label,
    required this.value,
    this.strong = false,
    this.valueLeading,
  });

  final String label;
  final String value;
  final bool strong;
  final Widget? valueLeading;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          label,
          style: TextStyle(
            color: PoliceColors.textMuted.withValues(alpha: 0.9),
            fontSize: 12,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 4),
        valueLeading != null
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 2, right: 10),
                    child: valueLeading!,
                  ),
                  Expanded(
                    child: SelectableText(
                      value,
                      style: TextStyle(
                        color: PoliceColors.titleOnDark,
                        fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
                        fontSize: strong ? 16 : 15,
                        height: 1.35,
                      ),
                    ),
                  ),
                ],
              )
            : SelectableText(
                value,
                style: TextStyle(
                  color: PoliceColors.titleOnDark,
                  fontWeight: strong ? FontWeight.w800 : FontWeight.w500,
                  fontSize: strong ? 16 : 15,
                  height: 1.35,
                ),
              ),
      ],
    );
  }
}
