import 'package:coderipple/src/features/araclar/harcirah/harcirah_calculator.dart';
import 'package:coderipple/src/features/gorevlerim/izin/il_mesafe.dart';

void main() {
  final pairs = [
    ('Denizli', 'Diyarbakır', 1243),
    ('Ankara', 'İstanbul', 452),
    ('Ankara', 'İzmir', 580),
    ('İstanbul', 'İzmir', 480),
    ('Ankara', 'Antalya', 550),
  ];
  for (final (a, b, ref) in pairs) {
    final km = ilMesafeKm(a, b);
    final kus = ilMesafeKusUcusuKm(a, b);
    final diff = ((km - ref).abs() / ref * 100);
    print('$a → $b | km=$km ref=$ref kus=${kus.toStringAsFixed(0)} sapma=${diff.toStringAsFixed(1)}%');
  }
}
