import 'package:flutter/material.dart';
import '../../../../data/models/user_model.dart';
import '../../../../data/repositories/auth_repository.dart';

class AuthViewModel extends ChangeNotifier {
  final AuthRepository _authRepository;

  AuthViewModel({AuthRepository? authRepository})
      : _authRepository = authRepository ?? AuthRepository() {
    _authRepository.authStateChanges.listen((user) {
      if (user != null) {
        loadCurrentUser();
      } else {
        _currentUser = null;
        notifyListeners();
      }
    });
  }

  UserModel? _currentUser;
  UserModel? get currentUser => _currentUser;

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _errorMessage;
  String? get errorMessage => _errorMessage;

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  Future<void> loadCurrentUser() async {
    _currentUser = await _authRepository.getCurrentUserModel();
    notifyListeners();
  }

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    required String confirmPassword,
  }) async {
    if (password != confirmPassword) {
      _errorMessage = 'Passwords do not match';
      notifyListeners();
      return false;
    }

    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.register(
        name: name,
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanFirebaseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser = await _authRepository.login(
        email: email,
        password: password,
      );
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanFirebaseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signInWithGoogle({String? webClientId}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      _currentUser =
          await _authRepository.signInWithGoogle(webClientId: webClientId);
      _isLoading = false;
      notifyListeners();
      return _currentUser != null;
    } catch (e) {
      _errorMessage = _cleanFirebaseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendPasswordReset(String email) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      await _authRepository.sendPasswordReset(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _errorMessage = _cleanFirebaseError(e.toString());
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> sendEmailVerification() async {
    try {
      await _authRepository.sendEmailVerification();
      return true;
    } catch (e) {
      _errorMessage = _cleanFirebaseError(e.toString());
      notifyListeners();
      return false;
    }
  }

  Future<void> logout() async {
    await _authRepository.logout();
    _currentUser = null;
    notifyListeners();
  }

  String _cleanFirebaseError(String err) {
    if (err.contains('EMAIL_NOT_VERIFIED')) {
      return 'Please verify your email address before logging in. A verification link has been sent to your email inbox.';
    }
    if (err.contains('user-not-found')) return 'No user found with this email.';
    if (err.contains('wrong-password')) return 'Incorrect password.';
    if (err.contains('email-already-in-use')) return 'Email is already registered.';
    if (err.contains('invalid-email')) return 'Invalid email format.';
    if (err.contains('weak-password')) return 'Password should be at least 6 characters.';
    return err.replaceAll(RegExp(r'\[.*?\]'), '').trim();
  }
}
