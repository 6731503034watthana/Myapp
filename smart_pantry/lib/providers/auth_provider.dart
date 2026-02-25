import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_pantry/services/firestore_service.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthProvider extends ChangeNotifier {
  final fb.FirebaseAuth _auth = fb.FirebaseAuth.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  final FirestoreService _firestoreService = FirestoreService();

  fb.User? _user;
  bool _isLoading = false;
  String? _error;

  fb.User? get user => _user;
  bool get isLoggedIn => _user != null;
  bool get isLoading => _isLoading;
  String? get error => _error;
  String get userId => _user?.uid ?? '';
  String get displayName => _user?.displayName ?? _user?.email ?? 'User';

  AuthProvider() {
    _auth.authStateChanges().listen((fb.User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // ===== Login ด้วย Email + Password =====
  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      await _auth.signInWithEmailAndPassword(email: email, password: password);
      _isLoading = false;
      notifyListeners();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== Sign Up ด้วย Email + Password =====
  Future<bool> signUpWithEmail(String email, String password, String name) async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
      _user = _auth.currentUser;

      if (_user != null) {
        await _firestoreService.initDefaultCategories(_user!.uid);
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== Login ด้วย Google =====
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      if (kIsWeb) {
        // Flutter Web
        final googleProvider = fb.GoogleAuthProvider();
        final userCredential = await _auth.signInWithPopup(googleProvider);

        if (userCredential.additionalUserInfo?.isNewUser == true && 
            userCredential.user != null) {
          await _firestoreService.initDefaultCategories(userCredential.user!.uid);
        }
      } else {
        // iOS/Android
        final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
        
        if (googleUser == null) {
          _isLoading = false;
          notifyListeners();
          return false;
        }

        final GoogleSignInAuthentication googleAuth = 
            await googleUser.authentication;
        
        final credential = fb.GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );

        final userCredential = await _auth.signInWithCredential(credential);

        if (userCredential.additionalUserInfo?.isNewUser == true && 
            userCredential.user != null) {
          await _firestoreService.initDefaultCategories(userCredential.user!.uid);
        }
      }

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Google Sign-In failed: ${e.toString()}';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== Logout =====
  Future<void> logout() async {
    try {
      if (!kIsWeb) {
        await _googleSignIn.signOut();
      }
      await _auth.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed: ${e.toString()}';
      notifyListeners();
    }
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }

  String _mapAuthError(String code) {
    switch (code) {
      case 'user-not-found':
        return 'No account found with this email.';
      case 'wrong-password':
        return 'Incorrect password.';
      case 'email-already-in-use':
        return 'This email is already registered.';
      case 'weak-password':
        return 'Password is too weak (min 6 characters).';
      case 'invalid-email':
        return 'Invalid email address.';
      case 'invalid-credential':
        return 'Invalid email or password.';
      default:
        return 'Authentication error. Please try again.';
    }
  }
}


