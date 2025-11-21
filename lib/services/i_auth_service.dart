// lib/services/i_auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  Future<User?> signIn(String email, String password);
  Future<User?> signUp(String email, String password);
  Future<User?> signInWithGoogle();
  Future<void> signOut();
  Stream<User?> get authStateChanges;
  User? get currentUser;
}
