import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsController {

  static Future<double> getThreshold() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('threshold') ?? 20.0;
  }

  static Future<double> getVolume() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getDouble('volume') ?? 20.0;
  }
}