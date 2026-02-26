import 'package:shared_preferences/shared_preferences.dart';

const _keyAtaturkQuoteSeen = 'ataturk_quote_seen';
const _keyDisclaimerAccepted = 'disclaimer_accepted';

Future<bool> getAtaturkQuoteSeen() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_keyAtaturkQuoteSeen) ?? false;
}

Future<void> setAtaturkQuoteSeen(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyAtaturkQuoteSeen, value);
}

Future<bool> getDisclaimerAccepted() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getBool(_keyDisclaimerAccepted) ?? false;
}

Future<void> setDisclaimerAccepted(bool value) async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setBool(_keyDisclaimerAccepted, value);
}
