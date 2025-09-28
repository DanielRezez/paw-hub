import 'package:flutter/material.dart';
import 'package:projeto_integrador2/viewmodels/auth_viewmodel.dart';
import 'package:shared_preferences/shared_preferences.dart';

const String kDarkModePrefKey = 'isDarkMode';
const String kNotificationsEnabledPrefKey = 'notificationsEnabled';

class ConfiguracoesViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;

  ConfiguracoesViewModel(this._authViewModel) {
    _loadPreferences();
  }

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(kDarkModePrefKey) ?? _isDarkMode; // Usa o padrão se não houver salvo
      _notificationsEnabled = prefs.getBool(kNotificationsEnabledPrefKey) ?? _notificationsEnabled;
      print("Preferências carregadas: DarkMode=$_isDarkMode, Notificações=$_notificationsEnabled");
    } catch (e) {
      print("Erro ao carregar preferências: $e");
      // Mantém os valores padrão se houver erro
    }
    notifyListeners(); // Notifica a UI após carregar, caso os valores tenham mudado do padrão
  }

  Future<void> toggleTheme(bool value) async {
    _isDarkMode = value;
    notifyListeners(); // Notifica a UI imediatamente para uma resposta visual rápida

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kDarkModePrefKey, _isDarkMode);
      print("Tema salvo: DarkMode=$_isDarkMode");
      // Aqui você pode adicionar lógica para realmente alternar o tema do app
      // Isso geralmente é feito através de um ThemeProvider ou um serviço de tema.
    } catch (e) {
      print("Erro ao salvar preferência de tema: $e");
      // Considere reverter o estado da UI ou notificar o usuário
    }
  }

  Future<void> toggleNotifications(bool value) async {
    _notificationsEnabled = value;
    notifyListeners(); // Notifica a UI imediatamente

    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(kNotificationsEnabledPrefKey, _notificationsEnabled);
      print("Preferência de notificações salva: $_notificationsEnabled");
      // Aqui você pode adicionar lógica para ativar/desativar notificações no sistema
    } catch (e) {
      print("Erro ao salvar preferência de notificações: $e");
      // Considere reverter o estado da UI ou notificar o usuário
    }
  }

  Future<void> logout() async {
    print("ViewModel: Solicitando logout ao AuthViewModel...");
    await _authViewModel.signOutAll();
    // O Wrapper cuidará do redirecionamento
  }
}