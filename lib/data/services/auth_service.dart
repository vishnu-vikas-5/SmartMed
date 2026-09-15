import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import '../models/user_model.dart';

class AuthService {
  UserModel? _demoUser;

  FirebaseAuth? get _auth {
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirebaseFirestore? get _firestore {
    try {
      return FirebaseFirestore.instance;
    } catch (_) {
      return null;
    }
  }

  Stream<User?> get authStateChanges {
    try {
      final auth = _auth;
      if (auth != null) return auth.authStateChanges();
    } catch (_) {}
    return Stream.value(null);
  }

  /// Get Current User
  User? get currentUser => _auth?.currentUser;

  /// Register a new user with Email and Password
  Future<UserModel> registerWithEmailAndPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    final firestore = _firestore;

    if (auth != null && firestore != null) {
      try {
        final UserCredential credential =
            await auth.createUserWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        final User? user = credential.user;
        if (user == null) {
          throw Exception('Failed to create user credential.');
        }

        await user.updateDisplayName(name);

        final userModel = UserModel(
          uid: user.uid,
          name: name,
          email: email.trim(),
          createdAt: DateTime.now(),
        );

        await firestore
            .collection('users')
            .doc(user.uid)
            .set(userModel.toMap());

        return userModel;
      } catch (e) {
        rethrow;
      }
    }

    // Demo Fallback only if Firebase is completely uninitialized
    _demoUser = UserModel(
      uid: 'DEMO_USER_001',
      name: name,
      email: email.trim(),
      createdAt: DateTime.now(),
    );
    return _demoUser!;
  }

  /// Sign in with Email and Password
  Future<UserModel?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    final auth = _auth;
    final firestore = _firestore;

    if (auth != null && firestore != null) {
      try {
        final UserCredential credential =
            await auth.signInWithEmailAndPassword(
          email: email.trim(),
          password: password,
        );

        final User? user = credential.user;
        if (user != null) {
          final doc =
              await firestore.collection('users').doc(user.uid).get();
          if (doc.exists && doc.data() != null) {
            return UserModel.fromMap(doc.data()!, doc.id);
          } else {
            final userModel = UserModel(
              uid: user.uid,
              name: user.displayName ?? nameFromEmail(email),
              email: user.email ?? email,
              createdAt: DateTime.now(),
            );
            await firestore
                .collection('users')
                .doc(user.uid)
                .set(userModel.toMap(), SetOptions(merge: true));
            return userModel;
          }
        }
      } catch (e) {
        rethrow;
      }
    }

    // Demo Fallback only if Firebase is completely uninitialized
    _demoUser = UserModel(
      uid: 'DEMO_USER_001',
      name: nameFromEmail(email),
      email: email.trim(),
      createdAt: DateTime.now(),
    );
    return _demoUser;
  }

  String nameFromEmail(String email) {
    if (email.contains('@')) return email.split('@').first;
    return 'User';
  }

  /// Sign In with Google
  Future<UserModel?> signInWithGoogle({String? webClientId}) async {
    final auth = _auth;
    final firestore = _firestore;

    if (auth != null && firestore != null) {
      try {
        UserCredential credential;

        if (kIsWeb) {
          final GoogleAuthProvider googleProvider = GoogleAuthProvider();
          credential = await auth.signInWithPopup(googleProvider);
        } else {
          final GoogleSignIn googleSignIn = GoogleSignIn(
            clientId: webClientId,
            scopes: const ['email', 'profile'],
          );
          final GoogleSignInAccount? googleUser = await googleSignIn.signIn();

          if (googleUser == null) return null;

          final GoogleSignInAuthentication googleAuth =
              await googleUser.authentication;
          final AuthCredential authCred = GoogleAuthProvider.credential(
            accessToken: googleAuth.accessToken,
            idToken: googleAuth.idToken,
          );

          credential = await auth.signInWithCredential(authCred);
        }

        final User? user = credential.user;
        if (user != null) {
          final userRef = firestore.collection('users').doc(user.uid);
          final doc = await userRef.get();

          final userModel = UserModel(
            uid: user.uid,
            name: user.displayName ?? nameFromEmail(user.email ?? 'user@gmail.com'),
            email: user.email ?? '',
            createdAt: DateTime.now(),
          );

          if (!doc.exists) {
            await userRef.set(userModel.toMap());
          }

          return userModel;
        }
      } on MissingPluginException catch (_) {
        throw 'Google Sign-In plugin requires restarting the app.';
      } on PlatformException catch (e) {
        throw e.message ?? 'Google Sign-In failed.';
      } catch (e) {
        rethrow;
      }
    }

    return null;
  }

  /// Send Password Reset Email
  Future<void> sendPasswordResetEmail(String email) async {
    final auth = _auth;
    if (auth != null) {
      await auth.sendPasswordResetEmail(email: email.trim());
    }
  }

  /// Sign Out
  Future<void> signOut() async {
    try {
      await GoogleSignIn().signOut();
    } catch (_) {}
    try {
      await _auth?.signOut();
    } catch (_) {}
    _demoUser = null;
  }

  /// Get current UserModel
  Future<UserModel?> getCurrentUserModel() async {
    if (_demoUser != null) return _demoUser;
    try {
      final user = _auth?.currentUser;
      final firestore = _firestore;
      if (user != null && firestore != null) {
        final doc =
            await firestore.collection('users').doc(user.uid).get();
        if (doc.exists && doc.data() != null) {
          return UserModel.fromMap(doc.data()!, doc.id);
        }
        return UserModel(
          uid: user.uid,
          name: user.displayName ?? 'User',
          email: user.email ?? '',
          createdAt: DateTime.now(),
        );
      }
    } catch (_) {}
    return _demoUser;
  }
}
