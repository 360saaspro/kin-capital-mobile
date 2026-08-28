import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/app_config.dart';
import 'firestore_service.dart';

/// Custom exception for Firebase Auth errors with human-readable messages.
class AuthException implements Exception {
  final String message;
  final String? code;

  const AuthException(this.message, {this.code});

  @override
  String toString() => message;
}

/// Service for managing Firebase Authentication and User Sessions across Kin Banking.
class AuthService {
  final FirebaseAuth? _customAuth;
  final FirestoreService? _customFirestore;
  String? _fallbackUid;
  bool _isSignedOut = false;

  AuthService({FirebaseAuth? auth, FirestoreService? firestore})
    : _customAuth = auth,
      _customFirestore = firestore;

  static final AuthService instance = AuthService();

  FirebaseAuth? get _auth {
    if (_customAuth != null) return _customAuth;
    try {
      return FirebaseAuth.instance;
    } catch (_) {
      return null;
    }
  }

  FirestoreService get _firestore =>
      _customFirestore ?? FirestoreService.instance;

  User? get currentUser {
    if (_isSignedOut) return null;
    try {
      return _auth?.currentUser;
    } catch (_) {
      return null;
    }
  }

  bool get isLoggedIn {
    if (_isSignedOut) return false;
    return currentUser != null ||
        (_fallbackUid != null && _fallbackUid!.isNotEmpty);
  }

  String get currentUid =>
      currentUser?.uid ?? _fallbackUid ?? AppConfig().entityId;

  Stream<User?> get authStateChanges {
    try {
      return _auth?.authStateChanges() ?? const Stream.empty();
    } catch (_) {
      return const Stream.empty();
    }
  }

  /// Converts any Firebase Auth error code or exception string into a friendly message
  static String parseAuthError(dynamic error) {
    if (error == null) return 'An unexpected error occurred. Please try again.';

    if (error is AuthException) {
      return error.message;
    }

    if (error is FirebaseAuthException) {
      switch (error.code.toLowerCase()) {
        case 'invalid-credential':
        case 'invalid-login-credentials':
          return 'Incorrect email or password. Please check your credentials and try again.';
        case 'user-not-found':
          return 'No account exists with this email. Please check the address or sign up.';
        case 'wrong-password':
          return 'Incorrect password. Please try again or tap Forgot Password.';
        case 'email-already-in-use':
          return 'An account already exists with this email address. Please log in.';
        case 'invalid-email':
          return 'The email address is invalid. Please check the formatting.';
        case 'weak-password':
          return 'The password is too weak. Please use at least 6 characters.';
        case 'user-disabled':
          return 'This user account has been disabled. Please contact Kin support.';
        case 'too-many-requests':
          return 'Too many attempts. Please wait a few moments before trying again.';
        case 'operation-not-allowed':
        case 'configuration-not-found':
          return 'Email/password sign-in is not enabled on this project. Please contact support or use Entity ID demo login.';
        case 'network-request-failed':
          return 'Network error. Please check your internet connection.';
        default:
          if (error.message != null && error.message!.trim().isNotEmpty) {
            return error.message!;
          }
      }
    }

    final str = error.toString().toLowerCase();

    if (str.contains('invalid-credential') ||
        str.contains('invalid-login-credentials')) {
      return 'Incorrect email or password. Please check your credentials and try again.';
    }
    if (str.contains('user-not-found')) {
      return 'No account exists with this email. Please check the address or sign up.';
    }
    if (str.contains('wrong-password')) {
      return 'Incorrect password. Please try again or tap Forgot Password.';
    }
    if (str.contains('email-already-in-use')) {
      return 'An account already exists with this email address. Please log in.';
    }
    if (str.contains('invalid-email')) {
      return 'The email address is invalid. Please check the formatting.';
    }
    if (str.contains('weak-password')) {
      return 'The password is too weak. Please use at least 6 characters.';
    }
    if (str.contains('user-disabled')) {
      return 'This user account has been disabled. Please contact Kin support.';
    }
    if (str.contains('too-many-requests')) {
      return 'Too many attempts. Please wait a few moments before trying again.';
    }
    if (str.contains('configuration-not-found') ||
        str.contains('operation-not-allowed')) {
      return 'Email/password sign-in is not enabled on this project. Please contact support or use Entity ID demo login.';
    }
    if (str.contains('network-request-failed') ||
        str.contains('network_error')) {
      return 'Network error. Please check your internet connection.';
    }

    // Strip internal labels and clean up
    final cleaned = error
        .toString()
        .replaceAll(RegExp(r'\[.*?\]'), '')
        .replaceAll('FirebaseError:', '')
        .replaceAll('Firebase:', '')
        .replaceAll('Exception:', '')
        .trim();

    return cleaned.isNotEmpty
        ? cleaned
        : 'Authentication failed. Please try again.';
  }

  /// Sign Up a new user with Email and Password
  Future<void> signUp({
    required String email,
    required String password,
    required String fullName,
    required String phone,
  }) async {
    _isSignedOut = false;
    final cleanEmail = email.trim();
    final cleanName = fullName.trim();
    final cleanPhone = phone.trim();

    final auth = _auth;
    if (auth == null) {
      throw const AuthException('Firebase Auth is not initialized. Please restart the application.');
    }

    try {
      final credential = await auth.createUserWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      if (credential.user != null) {
        try {
          await credential.user!.updateDisplayName(cleanName);
        } catch (_) {}

        _fallbackUid = credential.user!.uid;
        AppConfig().entityId = credential.user!.uid;

        // Initialize User Profile in Firestore
        await _firestore.setUserProfile(credential.user!.uid, {
          'uid': credential.user!.uid,
          'email': cleanEmail,
          'fullName': cleanName,
          'phone': cleanPhone,
          'role': 'user',
          'accountType': 'personal',
          'tier': 'standard',
          'balance': 0.00,
          'kycStatus': 'Verified',
          'createdAt': DateTime.now().toIso8601String(),
        });
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(parseAuthError(e));
    }
  }

  /// Login existing user with Email and Password
  Future<void> login({required String email, required String password}) async {
    _isSignedOut = false;
    final cleanEmail = email.trim();

    final auth = _auth;
    if (auth == null) {
      throw const AuthException('Firebase Auth is not initialized. Please restart the application.');
    }

    try {
      final credential = await auth.signInWithEmailAndPassword(
        email: cleanEmail,
        password: password,
      );

      if (credential.user != null) {
        _fallbackUid = credential.user!.uid;
        AppConfig().entityId = credential.user!.uid;

        final profile = await _firestore.getUserProfile(credential.user!.uid);
        if (profile == null) {
          await _firestore.setUserProfile(credential.user!.uid, {
            'uid': credential.user!.uid,
            'email': credential.user!.email ?? cleanEmail,
            'fullName': credential.user!.displayName ?? 'Kin User',
            'phone': '+1 (876) 123-4567',
            'role': 'user',
            'accountType': 'personal',
            'tier': 'standard',
            'balance': 0.00,
            'kycStatus': 'Verified',
            'createdAt': DateTime.now().toIso8601String(),
          });
        }
      }
    } catch (e) {
      if (e is AuthException) rethrow;
      throw AuthException(parseAuthError(e));
    }
  }

  /// Send password reset email
  Future<void> sendPasswordResetEmail(String email) async {
    final cleanEmail = email.trim();
    if (_auth != null) {
      try {
        await _auth!.sendPasswordResetEmail(email: cleanEmail);
      } catch (e) {
        throw AuthException(parseAuthError(e));
      }
    }
  }

  /// Sign out current user
  Future<void> signOut() async {
    _isSignedOut = true;
    _fallbackUid = null;
    try {
      await _auth?.signOut();
    } catch (_) {}
  }
}
