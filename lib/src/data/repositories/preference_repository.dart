import 'package:shared_preferences/shared_preferences.dart';

import '../../common/legal/user_agreement_sections.dart';

const _keyAtaturkQuoteSeen = 'ataturk_quote_seen';
const _keyDisclaimerAccepted = 'disclaimer_accepted';
const _keyUserAgreementAcceptedVersion = 'user_agreement_accepted_version';
const _keyUserAgreementAcceptedAtMs = 'user_agreement_accepted_at_ms';

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

/// Güncel kullanıcı sözleşmesi sürümü cihazda onaylanmış mı?
Future<bool> getUserAgreementAccepted() async {
  final prefs = await SharedPreferences.getInstance();
  return prefs.getString(_keyUserAgreementAcceptedVersion) == kUserAgreementVersion;
}

/// Onayı ve zaman damgasını yerelde saklar (sunucuya gönderilmez).
Future<void> acceptUserAgreement() async {
  final prefs = await SharedPreferences.getInstance();
  await prefs.setString(_keyUserAgreementAcceptedVersion, kUserAgreementVersion);
  await prefs.setInt(
    _keyUserAgreementAcceptedAtMs,
    DateTime.now().millisecondsSinceEpoch,
  );
  await prefs.setBool(_keyDisclaimerAccepted, true);
}

Future<DateTime?> getUserAgreementAcceptedAt() async {
  final prefs = await SharedPreferences.getInstance();
  final ms = prefs.getInt(_keyUserAgreementAcceptedAtMs);
  if (ms == null) return null;
  return DateTime.fromMillisecondsSinceEpoch(ms);
}
