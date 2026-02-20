import 'package:flutter/foundation.dart';
import 'package:uuid/uuid.dart';

import '../../../core/network/api_client.dart';
import '../models/auth_session.dart';
import '../services/auth_service.dart';

class AuthState extends ChangeNotifier {
  AuthState(this._authService) : guestSessionId = const Uuid().v4();

  final AuthService _authService;
  final String guestSessionId;

  AuthSession? _session;
  bool _isLoading = false;
  String? _errorMessage;

  AuthSession? get session => _session;
  bool get isAuthenticated => _session != null && !_session!.isExpired;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<bool> login({
    required String identifier,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _session = await _authService.login(
        identifier: identifier,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Login failed: $error';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  Future<bool> register({
    required String email,
    required String username,
    required String password,
    String? fullName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authService.register(
        email: email,
        username: username,
        password: password,
        fullName: fullName,
      );

      final identifier = username.trim().isNotEmpty
          ? username.trim()
          : email.trim();
      _session = await _authService.login(
        identifier: identifier,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } on ApiException catch (error) {
      _errorMessage = error.message;
    } catch (error) {
      _errorMessage = 'Signup failed: $error';
    }

    _isLoading = false;
    notifyListeners();
    return false;
  }

  void logout() {
    _session = null;
    _errorMessage = null;
    notifyListeners();
  }
}
