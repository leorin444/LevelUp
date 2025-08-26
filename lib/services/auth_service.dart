import 'package:firebase_auth/firebase_auth.dart';
import 'package:logger/logger.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  final _logger = Logger(
    printer: PrettyPrinter(), // optional, for nice output
    level: Level.info, // specify level using named parameter
  );

  // Sign up
  Future<User?> signUp(String email, String password) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e, stack) {
      _logger.e("Error signing in", error: e, stackTrace: stack);

      return null;
    }
  }

  // Login
  Future<User?> signIn(String email, String password) async {
    try {
      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return credential.user;
    } catch (e, stack) {
      _logger.e("Error signing in", error: e, stackTrace: stack);
// ✅ fixed
      return null;
    }
  }

  // Logout
  Future<void> signOut() async {
    await _auth.signOut();
    _logger.i("User signed out"); // ✅ fixed
  }

  // Get Firebase ID Token
  Future<String?> getToken() async {
    final user = _auth.currentUser;
    return await user?.getIdToken();
  }

  // Stream to check auth state
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
