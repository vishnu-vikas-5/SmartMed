import 'package:firebase_auth/firebase_auth.dart';
import '../models/user_model.dart';
import '../services/auth_service.dart';

class AuthRepository {
  final AuthService _authService;

  AuthRepository({AuthService? authService})
      : _authService = authService ?? AuthService();

  Stream<User?> get authStateChanges => _authService.authStateChanges;
  User? get currentUser => _authService.currentUser;

  Future<UserModel> register({
    required String name,
    required String email,
    required String password,
  }) {
    return _authService.registerWithEmailAndPassword(
      name: name,
      email: email,
      password: password,
    );
  }

  Future<UserModel?> login({
    required String email,
    required String password,
  }) {
    return _authService.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  Future<UserModel?> signInWithGoogle({String? webClientId}) {
    return _authService.signInWithGoogle(webClientId: webClientId);
  }

  Future<void> sendPasswordReset(String email) {
    return _authService.sendPasswordResetEmail(email);
  }

  Future<void> sendEmailVerification() {
    return _authService.sendEmailVerification();
  }

  Future<void> logout() {
    return _authService.signOut();
  }

  Future<UserModel?> getCurrentUserModel() {
    return _authService.getCurrentUserModel();
  }
}
