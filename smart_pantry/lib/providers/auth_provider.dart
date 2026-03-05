import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:google_sign_in/google_sign_in.dart';
import 'package:smart_pantry/services/firestore_service.dart';

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
    // Listen Firebase auth state
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
      // ตั้งชื่อ
      await credential.user?.updateDisplayName(name);
      await credential.user?.reload();
      _user = _auth.currentUser;

      // สร้าง default categories ให้ user ใหม่
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
  // หมายเหตุ: ต้องตั้งค่า Firebase Console ก่อนใช้งาน:
  // 1. Firebase Console → Authentication → Sign-in method → เปิดใช้ Google
  // 2. Firebase Console → Project Settings → เพิ่ม SHA-1 fingerprint
  //    (ได้จาก: keytool -list -v -keystore ~/.android/debug.keystore -alias androiddebugkey -storepass android -keypass android)
  // 3. ดาวน์โหลด google-services.json ใหม่แล้ววางที่ android/app/
  Future<bool> loginWithGoogle() async {
    _isLoading = true;
    _error = null;
    notifyListeners();
    try {
      // ล้าง session เก่าก่อน sign in ใหม่ เพื่อป้องกันปัญหา cached credentials
      await _googleSignIn.signOut();

      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        _isLoading = false;
        notifyListeners();
        return false; // ผู้ใช้ยกเลิก
      }

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      final credential = fb.GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final userCredential = await _auth.signInWithCredential(credential);

      // ถ้าเป็น user ใหม่ สร้าง default categories
      if (userCredential.additionalUserInfo?.isNewUser == true && userCredential.user != null) {
        await _firestoreService.initDefaultCategories(userCredential.user!.uid);
      }
      _isLoading = false;
      notifyListeners();
      return true;
    } on fb.FirebaseAuthException catch (e) {
      _error = _mapAuthError(e.code);
      _isLoading = false;
      notifyListeners();
      return false;
    } catch (e) {
      // แสดง error ที่ชัดเจนมากขึ้น เพื่อ debug ง่าย
      if (e.toString().contains('sign_in_canceled')) {
        _error = null; // ผู้ใช้ยกเลิกเอง ไม่ต้องแสดง error
      } else if (e.toString().contains('network_error')) {
        _error = 'Network error. Please check your connection.';
      } else if (e.toString().contains('ApiException: 10')) {
        _error = 'Google Sign-In configuration error. Please check SHA-1 fingerprint in Firebase Console.';
      } else if (e.toString().contains('ApiException: 12500')) {
        _error = 'Google Sign-In failed. Please update Google Play Services.';
      } else {
        _error = 'Google Sign-In failed: ${e.toString()}';
      }
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  // ===== Logout =====
  Future<void> logout() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    _user = null;
    notifyListeners();
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
