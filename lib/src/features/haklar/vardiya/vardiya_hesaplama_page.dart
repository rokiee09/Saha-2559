import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../common/theme/police_colors.dart';
import 'vardiya_shift_placeholder_page.dart';
import 'vardiya_shift_types.dart';

const _prefsLastShiftId = 'vardiya_last_shift_type_id';

/// Vardiya türü seçim ekranı (2 sütun grid, üst çizgili kartlar).
class VardiyaHesaplamaPage extends StatelessWidget {
  const VardiyaHesaplamaPage({super.key});

  Future<void> _openShift(BuildContext context, String id) async {
    HapticFeedback.selectionClick();
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(_prefsLastShiftId, id);
    if (!context.mounted) return;
    await Navigator.of(context).push<void>(
      MaterialPageRoute<void>(
        builder: (_) => VardiyaShiftPlaceholderPage(shiftId: id),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFE8ECF2),
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        elevation: 0,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'Vardiya Hesaplama',
              style: Theme.of(context).textTheme.titleMedium?.copyWith(
                    color: PoliceColors.titleOnDark,
                    fontWeight: FontWeight.w700,
                  ),
            ),
            Text(
              '10 vardiya türü',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: PoliceColors.titleOnDark.withValues(alpha: 0.72),
                    fontWeight: FontWeight.w500,
                  ),
            ),
          ],
        ),
        toolbarHeight: 62,
        shape: Border(
          bottom: BorderSide(
            color: PoliceColors.accentMix(0.34),
            width: 1,
          ),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.fromLTRB(12, 14, 12, 24),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 12,
            crossAxisSpacing: 12,
            childAspectRatio: 0.92,
          ),
          itemCount: VardiyaTur.all.length,
          itemBuilder: (context, i) {
            final tur = VardiyaTur.all[i];
            return _VardiyaTypeCard(
              tur: tur,
              onTap: () => _openShift(context, tur.id),
            );
          },
        ),
      ),
    );
  }
}

class _VardiyaTypeCard extends StatelessWidget {
  const _VardiyaTypeCard({
    required this.tur,
    required this.onTap,
  });

  final VardiyaTur tur;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.white,
      borderRadius: BorderRadius.circular(14),
      elevation: 2,
      shadowColor: Colors.black.withValues(alpha: 0.12),
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border(
              top: BorderSide(color: tur.topColor, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 12, 10, 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Expanded(
                  child: Center(
                    child: Container(
                      width: 56,
                      height: 56,
                      alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: const Color(0xFFF0F3F8),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: tur.icon != null
                          ? Icon(
                              tur.icon,
                              size: 30,
                              color: tur.topColor,
                            )
                          : Text(
                              tur.emoji!,
                              style: const TextStyle(fontSize: 30),
                            ),
                    ),
                  ),
                ),
                const SizedBox(height: 8),
                Row(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Expanded(
                      child: Text(
                        tur.title,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF1A1D23),
                          height: 1.2,
                        ),
                      ),
                    ),
                    Icon(
                      Icons.chevron_right_rounded,
                      size: 22,
                      color: Colors.grey.shade400,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
