import 'package:firebase_auth/firebase_auth.dart' as fb_auth;
import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/user_model.dart';

class AuthService {
  final fb_auth.FirebaseAuth _firebaseAuth = fb_auth.FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  // Get current user
  fb_auth.User? get currentUser => _firebaseAuth.currentUser;

  // Auth state stream
  Stream<fb_auth.User?> get authStateChanges => _firebaseAuth.authStateChanges();

  // Sign up
  Future<String> signUp({
    required String email,
    required String password,
    required String name,
    required UserRole role,
    String? area,
  }) async {
    try {
      final userCredential = await _firebaseAuth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      final user = User(
        userId: userCredential.user!.uid,
        name: name,
        email: email,
        role: role,
        area: area,
        createdAt: DateTime.now(),
      );

      // Save user to Firestore
      await _firestore.collection('users').doc(user.userId).set(user.toMap());

      return userCredential.user!.uid;
    } catch (e) {
      rethrow;
    }
  }

  // Login
  Future<String> login({
    required String email,
    required String password,
  }) async {
    try {
      final userCredential = await _firebaseAuth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return userCredential.user!.uid;
    } catch (e) {
      rethrow;
    }
  }

  // Get user data
  Future<User?> getUserData(String userId) async {
    try {
      final doc = await _firestore.collection('users').doc(userId).get();
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get user data stream
  Stream<User?> getUserDataStream(String userId) {
    return _firestore.collection('users').doc(userId).snapshots().map((doc) {
      if (doc.exists) {
        return User.fromMap(doc.data() as Map<String, dynamic>);
      }
      return null;
    });
  }

  // Update user
  Future<void> updateUser(User user) async {
    try {
      await _firestore.collection('users').doc(user.userId).update(user.toMap());
    } catch (e) {
      rethrow;
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _firebaseAuth.signOut();
    } catch (e) {
      rethrow;
    }
  }

  // Password reset
  Future<void> resetPassword(String email) async {
    try {
      await _firebaseAuth.sendPasswordResetEmail(email: email);
    } catch (e) {
      rethrow;
    }
  }
}
