import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:shree/core/session_manager.dart';
import 'package:shree/models/user_model.dart';

class AuthFailure implements Exception {
  const AuthFailure(this.message);

  final String message;

  @override
  String toString() => message;
}

class AuthService {
  AuthService._();

  static final FirebaseAuth _auth = FirebaseAuth.instance;
  static final CollectionReference<Map<String, dynamic>> _usersCollection =
      FirebaseFirestore.instance.collection('users');

  static Future<AppUser> register({
    required String name,
    required String email,
    required String password,
    required SessionRole role,
  }) async {
    try {
      final normalizedName = name.trim();
      final normalizedEmail = _normalizeEmail(email);
      final userCredential = await _auth.createUserWithEmailAndPassword(
        email: normalizedEmail,
        password: password,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AuthFailure('Unable to create your account right now.');
      }

      final profile = AppUser(
        id: firebaseUser.uid,
        name: normalizedName,
        email: normalizedEmail,
        role: _roleLabel(role),
        memberSince: DateTime.now(),
      );

      await firebaseUser.updateDisplayName(normalizedName);
      await _usersCollection.doc(firebaseUser.uid).set(profile.toMap());
      await SessionManager.saveLogin(role);
      return profile;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_registerErrorMessage(error));
    } on FirebaseException {
      throw const AuthFailure(
        'Your account was created, but we could not save the profile details. Please try again.',
      );
    }
  }

  static Future<AppUser> login({
    required String email,
    required String password,
    required SessionRole expectedRole,
  }) async {
    try {
      final normalizedEmail = _normalizeEmail(email);
      final normalizedPassword = password.trim();
      final userCredential = await _auth.signInWithEmailAndPassword(
        email: normalizedEmail,
        password: normalizedPassword,
      );

      final firebaseUser = userCredential.user;
      if (firebaseUser == null) {
        throw const AuthFailure('Unable to sign in right now.');
      }

      final snapshot = await _usersCollection.doc(firebaseUser.uid).get();
      final data = snapshot.data();

      if (!snapshot.exists || data == null) {
        if (expectedRole == SessionRole.admin) {
          await signOut();
          throw const AuthFailure(
            'This admin account is not registered in the user database.',
          );
        }

        final fallbackProfile = AppUser(
          id: firebaseUser.uid,
          name: firebaseUser.displayName?.trim().isNotEmpty == true
              ? firebaseUser.displayName!.trim()
              : 'Customer',
          email: normalizedEmail,
          role: _roleLabel(SessionRole.user),
          memberSince: DateTime.now(),
        );

        await _usersCollection.doc(firebaseUser.uid).set(fallbackProfile.toMap());
        await SessionManager.saveLogin(SessionRole.user);
        return fallbackProfile;
      }

      final profile = AppUser.fromMap(snapshot.id, data);
      final actualRole = _roleFromLabel(profile.role);
      if (actualRole != expectedRole) {
        await signOut();
        throw AuthFailure(
          expectedRole == SessionRole.admin
              ? 'This account is not registered as an admin.'
              : 'Please use the admin login for admin accounts.',
        );
      }

      await SessionManager.saveLogin(actualRole);
      return profile;
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_loginErrorMessage(error));
    } on FirebaseException {
      throw const AuthFailure(
        'We could not load your account details right now. Please try again.',
      );
    }
  }

  static Future<void> sendPasswordResetEmail(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: _normalizeEmail(email));
    } on FirebaseAuthException catch (error) {
      throw AuthFailure(_passwordResetErrorMessage(error));
    }
  }

  static Future<AppUser?> currentUserProfile() async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      await SessionManager.clear();
      return null;
    }

    try {
      final snapshot = await _usersCollection.doc(firebaseUser.uid).get();
      final data = snapshot.data();
      if (!snapshot.exists || data == null) {
        await signOut();
        return null;
      }

      final profile = AppUser.fromMap(snapshot.id, data);
      await SessionManager.saveLogin(_roleFromLabel(profile.role));
      return profile;
    } on FirebaseException {
      return null;
    }
  }

  static Future<AppUser> updateProfileName(String name) async {
    final firebaseUser = _auth.currentUser;
    if (firebaseUser == null) {
      throw const AuthFailure('Please sign in again to update your profile.');
    }

    final trimmedName = name.trim();
    if (trimmedName.isEmpty) {
      throw const AuthFailure('Please enter your name.');
    }

    try {
      final userRef = _usersCollection.doc(firebaseUser.uid);
      final snapshot = await userRef.get();
      final data = snapshot.data() ?? <String, dynamic>{};
      final storedEmail = data['email'] as String?;
      final resolvedEmail = firebaseUser.email ?? storedEmail ?? '';
      final updatedData = <String, dynamic>{
        ...data,
        'name': trimmedName,
        'email': _normalizeEmail(resolvedEmail),
        'role': data['role'] ?? 'Customer',
        'memberSince':
            data['memberSince'] ?? Timestamp.fromDate(DateTime.now()),
      };

      await firebaseUser.updateDisplayName(trimmedName);
      await userRef.set(updatedData, SetOptions(merge: true));
      return AppUser.fromMap(firebaseUser.uid, updatedData);
    } on FirebaseAuthException catch (_) {
      throw const AuthFailure(
        'We could not update your profile right now. Please try again.',
      );
    } on FirebaseException {
      throw const AuthFailure(
        'We could not save your profile right now. Please try again.',
      );
    }
  }

  static Future<void> signOut() async {
    await _auth.signOut();
    await SessionManager.clear();
  }

  static String _normalizeEmail(String email) => email.trim().toLowerCase();

  static String _roleLabel(SessionRole role) {
    return role == SessionRole.admin ? 'Admin' : 'Customer';
  }

  static SessionRole _roleFromLabel(String roleLabel) {
    return roleLabel.toLowerCase() == 'admin'
        ? SessionRole.admin
        : SessionRole.user;
  }

  static String _registerErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'email-already-in-use':
        return 'An account with this email already exists.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'weak-password':
        return 'Choose a stronger password and try again.';
      case 'operation-not-allowed':
        return 'Email and password sign-in is not enabled in Firebase Auth.';
      case 'network-request-failed':
        return 'Network issue detected. Please check your connection and try again.';
      default:
        return 'Registration failed. Please try again.';
    }
  }

  static String _loginErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Incorrect email or password.';
      case 'user-disabled':
        return 'This account has been disabled.';
      case 'too-many-requests':
        return 'Too many attempts. Please wait and try again.';
      case 'network-request-failed':
        return 'Network issue detected. Please check your connection and try again.';
      default:
        return 'Login failed. Please try again.';
    }
  }

  static String _passwordResetErrorMessage(FirebaseAuthException error) {
    switch (error.code) {
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-not-found':
        return 'No account was found for this email.';
      case 'network-request-failed':
        return 'Network issue detected. Please check your connection and try again.';
      default:
        return 'We could not send the reset email right now.';
    }
  }
}
