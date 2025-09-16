import 'package:flutter/material.dart';

class CarregamentoViewModel with ChangeNotifier {
  bool _isUserLoggedIn = false;
  bool get isUserLoggedIn => _isUserLoggedIn;
}