import 'package:flutter/foundation.dart';

/// Shared AI model readiness for Home showcase and scan actions.
class ModelStatusStore extends ChangeNotifier {
  ModelStatusStore._();

  static final ModelStatusStore instance = ModelStatusStore._();

  bool _ready = false;
  String? _error;

  bool get isReady => _ready;
  String? get error => _error;

  void setReady(bool ready, {String? error}) {
    _ready = ready;
    _error = error;
    notifyListeners();
  }
}
