import 'package:flutter/material.dart';

import '../../../common/theme/police_colors.dart';
import 'atis_models.dart';
import 'atis_store.dart';

class AtisEditorPage extends StatefulWidget {
  const AtisEditorPage({
    super.key,
    this.existing,
    this.initialDonem,
    this.initialYil,
  });

  final AtisKayit? existing;
  final int? initialDonem;
  final int? initialYil;

  @override
  State<AtisEditorPage> createState() => _AtisEditorPageState();
}

class _AtisEditorPageState extends State<AtisEditorPage> {
  late int _donem;
  late int _yil;
  late DateTime _tarih;
  late final TextEditingController _puanCtrl;
  late final TextEditingController _notCtrl;
  bool _izinKullanildi = false;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _donem = e?.donem ?? widget.initialDonem ?? 1;
    _yil = e?.yil ?? widget.initialYil ?? DateTime.now().year;
    _tarih = e != null
        ? DateTime(e.tarih.year, e.tarih.month, e.tarih.day)
        : DateTime.now();
    _puanCtrl = TextEditingController(
      text: e != null && e.puan > 0 ? e.puan.toString() : '',
    );
    _notCtrl = TextEditingController(text: e?.not ?? '');
    _izinKullanildi = e?.izinKullanildi ?? false;
  }

  @override
  void dispose() {
    _puanCtrl.dispose();
    _notCtrl.dispose();
    super.dispose();
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _tarih,
      firstDate: DateTime(2015),
      lastDate: DateTime.now().add(const Duration(days: 30)),
      locale: const Locale('tr', 'TR'),
    );
    if (picked != null) setState(() => _tarih = picked);
  }

  Future<void> _save() async {
    final puan = double.tryParse(_puanCtrl.text.trim().replaceAll(',', '.'));
    if (puan == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Puan girin.')),
      );
      return;
    }
    setState(() => _saving = true);
    final nowMs = DateTime.now().millisecondsSinceEpoch;
    final entry = AtisKayit(
      id: widget.existing?.id ?? atisGenerateId(),
      yil: _yil,
      donem: _donem,
      tarihMs: DateTime(_tarih.year, _tarih.month, _tarih.day)
          .millisecondsSinceEpoch,
      puan: puan,
      izinKullanildi: _izinKullanildi,
      not: _notCtrl.text.trim(),
      createdAtMs: widget.existing?.createdAtMs ?? nowMs,
      updatedAtMs: nowMs,
    );
    await atisUpsert(entry);
    if (!mounted) return;
    Navigator.of(context).pop(true);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: PoliceColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: PoliceColors.navy,
        foregroundColor: PoliceColors.titleOnDark,
        title: Text(
          widget.existing == null ? 'Atış kaydı' : 'Atış düzenle',
        ),
        actions: [
          TextButton(
            onPressed: _saving ? null : _save,
            child: const Text('Kaydet',
                style: TextStyle(
                    color: PoliceColors.primaryBlue,
                    fontWeight: FontWeight.w700)),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 16, 16, 28),
        children: [
          DropdownButtonFormField<int>(
            initialValue: _donem,
            dropdownColor: PoliceColors.surfaceDark,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Dönem'),
            items: const [
              DropdownMenuItem(value: 1, child: Text('1. Dönem')),
              DropdownMenuItem(value: 2, child: Text('2. Dönem')),
              DropdownMenuItem(value: 3, child: Text('3. Dönem')),
              DropdownMenuItem(value: 4, child: Text('4. Dönem')),
            ],
            onChanged: widget.existing != null
                ? null
                : (v) => setState(() => _donem = v ?? 1),
          ),
          const SizedBox(height: 12),
          ListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text('Tarih',
                style: TextStyle(color: PoliceColors.titleOnDark)),
            subtitle: Text(
              '${_tarih.day.toString().padLeft(2, '0')}.'
              '${_tarih.month.toString().padLeft(2, '0')}.'
              '${_tarih.year}',
              style: const TextStyle(
                  color: PoliceColors.primaryBlue, fontSize: 16),
            ),
            trailing: const Icon(Icons.calendar_today_rounded,
                color: PoliceColors.primaryBlue),
            onTap: _pickDate,
          ),
          const SizedBox(height: 12),
          TextField(
            controller: _puanCtrl,
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Puan'),
          ),
          const SizedBox(height: 12),
          SwitchListTile(
            contentPadding: EdgeInsets.zero,
            title: const Text(
              'Atış izni kullanıldı mı?',
              style: TextStyle(color: PoliceColors.titleOnDark),
            ),
            value: _izinKullanildi,
            activeThumbColor: PoliceColors.primaryBlue,
            onChanged: (v) => setState(() => _izinKullanildi = v),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: _notCtrl,
            minLines: 2,
            maxLines: 5,
            style: const TextStyle(color: PoliceColors.titleOnDark),
            decoration: _dec('Not'),
          ),
        ],
      ),
    );
  }

  InputDecoration _dec(String label) => InputDecoration(
        labelText: label,
        labelStyle:
            TextStyle(color: PoliceColors.textMuted.withValues(alpha: 0.9)),
        filled: true,
        fillColor: PoliceColors.surfaceDark,
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
      );
}
