import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final themeModeProvider = StateProvider<ThemeMode>((ref) {
  // Zorunlu dark mode için başlangıçta dark.
  return ThemeMode.dark;
});

