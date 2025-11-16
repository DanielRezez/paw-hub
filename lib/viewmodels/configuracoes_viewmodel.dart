import 'package:flutter/material.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kDarkModePrefKey = 'isDarkMode';
const String kNotificationsEnabledPrefKey = 'notificationsEnabled';

class ConfiguracoesViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;

  // --- CORREÇÃO AQUI ---
  // O Construtor agora é "limpo" (não é mais async)
  ConfiguracoesViewModel(this._authViewModel) {
    // _loadPreferences(); // <-- LINHA REMOVIDA
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  // --- CORREÇÃO AQUI ---
  // Método agora é público para ser chamado DEPOIS da construção
  Future<void> loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(kDarkModePrefKey) ?? _isDarkMode;
      _notificationsEnabled = prefs.getBool(kNotificationsEnabledPrefKey) ?? _notificationsEnabled;
      print("Preferências carregadas: DarkMode=$_isDarkMode, Notificações=$_notificationsEnabled");
    } catch (e) {
      print("Erro ao carregar preferências: $e");
    }
    notifyListeners();
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kDarkModePrefKey, _isDarkMode);
      print("Tema salvo: DarkMode=$_isDarkMode");
    } catch (e) {
      print("Erro ao salvar preferência de tema: $e");
    }
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kNotificationsEnabledPrefKey, _notificationsEnabled);
      print("Preferência de notificações salva: $_notificationsEnabled");
    } catch (e) {
      print("Erro ao salvar preferência de notificações: $e");
    }
  }

  Future<void> logout() async {
    print("ViewModel: Solicitando logout ao AuthViewModel...");
    // Seu código original usa signOutAll(), vamos manter.
    await _authViewModel.signOutAll();
  }
}