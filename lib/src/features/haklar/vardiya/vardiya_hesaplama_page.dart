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
        padding: const EdgeInsets.fromLTRB(12, 12, 12, 20),
        child: GridView.builder(
          physics: const BouncingScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2,
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 2.5,
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
      borderRadius: BorderRadius.circular(12),
      elevation: 1.5,
      shadowColor: Colors.black.withValues(alpha: 0.10),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onTap,
        child: Ink(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border(
              left: BorderSide(color: tur.topColor, width: 4),
            ),
          ),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(10, 8, 6, 8),
            child: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: const Color(0xFFF0F3F8),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: tur.icon != null
                      ? Icon(tur.icon, size: 21, color: tur.topColor)
                      : Text(
                          tur.emoji!,
                          style: const TextStyle(fontSize: 20),
                        ),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    tur.title,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: 13.5,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF1A1D23),
                      height: 1.15,
                    ),
                  ),
                ),
                Icon(
                  Icons.chevron_right_rounded,
                  size: 20,
                  color: Colors.grey.shade400,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
