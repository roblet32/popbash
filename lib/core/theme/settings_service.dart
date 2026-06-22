import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsService {
  static final SettingsService _instance = SettingsService._internal();
  factory SettingsService() => _instance;
  SettingsService._internal();

  late SharedPreferences _prefs;
  
  // Estado reactivo para el color primario (Verde Hacker por defecto)
  final ValueNotifier<Color> primaryColorNotifier = ValueNotifier<Color>(const Color(0xFFA6E3A1));
  
  // Estado reactivo para el Arte ASCII personalizado (vacío usa el logo por defecto)
  final ValueNotifier<String> customAsciiNotifier = ValueNotifier<String>('');

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    
    // Cargar color
    int? colorValue = _prefs.getInt('primary_color');
    if (colorValue != null) {
      primaryColorNotifier.value = Color(colorValue);
    }

    // Cargar ASCII
    String? ascii = _prefs.getString('custom_ascii');
    if (ascii != null && ascii.isNotEmpty) {
      customAsciiNotifier.value = ascii;
    }
  }

  Future<void> updateColor(Color color) async {
    primaryColorNotifier.value = color;
    await _prefs.setInt('primary_color', color.toARGB32());
  }

  Future<void> updateAscii(String asciiText) async {
    customAsciiNotifier.value = asciiText;
    await _prefs.setString('custom_ascii', asciiText);
  }
}
