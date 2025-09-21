import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

import 'auth_viewmodel.dart';


const String kDarkModePrefKey = 'isDarkMode';
const String kNotificationsEnabledPrefKey = 'notificationsEnabled';

class ConfiguracoesViewModel extends ChangeNotifier {
  final AuthViewModel _authViewModel;

  File? _fotoUsuario;
  File? get fotoUsuario => _fotoUsuario;

  String _username = 'Usuário';
  String get username => _username;

  bool _isDarkMode = false;
  bool get isDarkMode => _isDarkMode;

  bool _notificationsEnabled = true;
  bool get notificationsEnabled => _notificationsEnabled;

  ConfiguracoesViewModel(this._authViewModel) {
    _loadPreferences();
    _username = _authViewModel.user?.displayName ?? 'Usuário';
  }

  Future<void> _loadPreferences() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      _isDarkMode = prefs.getBool(kDarkModePrefKey) ?? _isDarkMode; // Usa o padrão se não houver salvo
      _notificationsEnabled = prefs.getBool(kNotificationsEnabledPrefKey) ?? _notificationsEnabled;
      _username = prefs.getString('username') ?? _username;
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

  // Trocar foto
  Future<void> trocarFoto() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      _fotoUsuario = File(pickedFile.path);
      notifyListeners();

      if (_authViewModel.user != null) {
        final uid = _authViewModel.user!.uid;
        final ref = FirebaseStorage.instance
            .ref()
            .child('users/$uid/profile.jpg');

        await ref.putFile(_fotoUsuario!);
        final url = await ref.getDownloadURL();

        // Atualiza no Firebase Auth
        await _authViewModel.user!.updatePhotoURL(url);
        await _authViewModel.user!.reload(); // garante que os dados estejam atualizados
      }
    }
  }

  // Trocar username
  Future<void> trocarUsername(String novoNome) async {
    _username = novoNome;
    notifyListeners();

    if (_authViewModel.user != null) {
      await _authViewModel.user!.updateDisplayName(novoNome);
      await _authViewModel.user!.reload(); // atualiza dados do usuário
    }
  }

  // Trocar senha
  Future<void> trocarSenha() async {
    final user = _authViewModel.user;
    if (user != null && user.email != null) {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: user.email!);
    }
  }

}