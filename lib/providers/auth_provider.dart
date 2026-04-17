import 'package:email_validator/email_validator.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../main.dart' show firebaseReady;
import '../services/auth_service.dart';

enum AuthStatus { initial, loading, authenticated, unauthenticated, error }

class AuthProvider extends ChangeNotifier {
  final AuthService _service = AuthService();

  AuthStatus _status = AuthStatus.initial;
  String? _errorMessage;
  User? _user;

  AuthStatus get status => _status;
  String? get errorMessage => _errorMessage;
  User? get user => _user;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    if (!firebaseReady) {
      _status = AuthStatus.unauthenticated;
      return;
    }
    try {
      _service.authStateChanges.listen(
        (user) {
          _user = user;
          _status = user != null
              ? AuthStatus.authenticated
              : AuthStatus.unauthenticated;
          notifyListeners();
        },
        onError: (_) {
          _status = AuthStatus.unauthenticated;
          notifyListeners();
        },
      );
    } catch (_) {
      _status = AuthStatus.unauthenticated;
    }
  }

  void _setLoading() {
    _status = AuthStatus.loading;
    _errorMessage = null;
    notifyListeners();
  }

  void _setError(String message) {
    _status = AuthStatus.error;
    _errorMessage = message;
    notifyListeners();
  }

  String get _noFirebaseMsg =>
      'Firebase is not configured yet.\nSee SETUP.md to connect your project.';

  // ── Register ────────────────────────────────────────────────────────────────
  Future<bool> register({
    required String name,
    required String email,
    required String password,
  }) async {
    if (!firebaseReady) {
      _setError(_noFirebaseMsg);
      return false;
    }

    // Client-side validation
    if (!EmailValidator.validate(email.trim())) {
      _setError('Please enter a valid email address.');
      return false;
    }

    _setLoading();
    try {
      await _service.register(
          email: email.trim(), password: password, displayName: name);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(AuthService.handleAuthError(e));
      return false;
    } catch (_) {
      _setError('Registration failed. Please try again.');
      return false;
    }
  }

  // ── Login ───────────────────────────────────────────────────────────────────
  Future<bool> login({
    required String email,
    required String password,
  }) async {
    if (!firebaseReady) {
      _setError(_noFirebaseMsg);
      return false;
    }

    // Client-side validation
    if (!EmailValidator.validate(email.trim())) {
      _setError('Please enter a valid email address.');
      return false;
    }

    _setLoading();
    try {
      await _service.login(email: email.trim(), password: password);
      return true;
    } on FirebaseAuthException catch (e) {
      _setError(AuthService.handleAuthError(e));
      return false;
    } catch (_) {
      _setError('Login failed. Please try again.');
      return false;
    }
  }

  // ── Sign Out ────────────────────────────────────────────────────────────────
  Future<void> signOut() async {
    if (!firebaseReady) return;
    try {
      await _service.signOut();
    } catch (_) {}
  }

  // ── Password Reset ──────────────────────────────────────────────────────────
  Future<bool> sendPasswordReset(String email) async {
    if (!firebaseReady) return false;
    try {
      await _service.sendPasswordReset(email);
      return true;
    } catch (_) {
      return false;
    }
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
