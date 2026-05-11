import 'package:flutter/material.dart';

/// Vardiya türü tanımları — menü sırası sabit (10 kart).
class VardiyaTur {
  const VardiyaTur({
    required this.id,
    required this.title,
    required this.topColor,
    this.emoji,
    this.icon,
  }) : assert(emoji != null || icon != null);

  final String id;
  final String title;
  final Color topColor;
  final String? emoji;
  final IconData? icon;

  static const Color blueAccent = Color(0xFF1976D2);
  static const Color greenAccent = Color(0xFF43A047);
  static const Color redAccent = Color(0xFFE53935);
  static const Color purpleAccent = Color(0xFF7E57C2);

  static const List<VardiyaTur> all = [
    VardiyaTur(id: '12_24', title: '12/24', topColor: blueAccent, emoji: '🌙'),
    VardiyaTur(id: 'cakma_12_36', title: 'Çakma 12/36', topColor: blueAccent, emoji: '🌤️'),
    VardiyaTur(id: 'gercek_12_36', title: 'Gerçek 12/36', topColor: greenAccent, emoji: '✅'),
    VardiyaTur(id: '24_48', title: '24/48', topColor: redAccent, emoji: '🤗'),
    VardiyaTur(id: '8_24', title: '8 / 24', topColor: blueAccent, emoji: '🚓'),
    VardiyaTur(
      id: '222',
      title: '2 + 2 + 2',
      topColor: blueAccent,
      icon: Icons.sync_rounded,
    ),
    VardiyaTur(id: '11', title: '1 + 1', topColor: blueAccent, emoji: '👮‍♀️'),
    VardiyaTur(
      id: '21',
      title: '2 + 1',
      topColor: blueAccent,
      icon: Icons.assignment_outlined,
    ),
    VardiyaTur(
      id: '31',
      title: '3 + 1',
      topColor: purpleAccent,
      icon: Icons.calendar_month_rounded,
    ),
    VardiyaTur(
      id: 'asayis_11',
      title: 'Asayiş 1+1',
      topColor: redAccent,
      icon: Icons.emergency_rounded,
    ),
  ];

  static VardiyaTur? byId(String id) {
    for (final t in all) {
      if (t.id == id) return t;
    }
    return null;
  }
}
