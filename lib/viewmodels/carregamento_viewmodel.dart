import 'package:flutter/material.dart';

class CarregamentoViewModel with ChangeNotifier {
  final bool _isUserLoggedIn = false;
  bool get isUserLoggedIn => _isUserLoggedIn;
}