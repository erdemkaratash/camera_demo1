import 'package:flutter/material.dart';

class ErrorNotifier extends ChangeNotifier {
  String? _errorMessage;
  bool get hasError => _errorMessage != null;
  String? get errorMessage => _errorMessage;

  void setError(String? message) {
    _errorMessage = message;
    notifyListeners();
  }

  void clear() {
    _errorMessage = null;
  }
}
