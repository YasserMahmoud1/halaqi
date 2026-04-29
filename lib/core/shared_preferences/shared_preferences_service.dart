import 'package:shared_preferences/shared_preferences.dart';


class SharedPrefsService {
  final SharedPreferences _prefs;

  SharedPrefsService(this._prefs);

  static const String _onboardingSkippedKey = 'onboarding_skipped';

  bool get onboardingSkipped => _prefs.getBool(_onboardingSkippedKey) ?? false;

  Future<void> setOnboardingSkipped(bool value) async {
    await _prefs.setBool(_onboardingSkippedKey, value);
  }
}
