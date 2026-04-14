import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'backend_service.dart';

class GoogleAuthService {
  static final GoogleAuthService _instance = GoogleAuthService._internal();
  factory GoogleAuthService() => _instance;
  GoogleAuthService._internal();

  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final BackendService _backendService = BackendService();

  // Sign in with Google
  Future<UserCredential?> signInWithGoogle() async {
    try {
      // Sign out first to clear any cached credentials
      await _googleSignIn.signOut();

      // Trigger Google Sign-In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        // User cancelled the sign-in
        return null;
      }

      print('========================================');
      print('GOOGLE SIGN-IN RESPONSE:');
      print('========================================');
      print('Display Name: ${googleUser.displayName}');
      print('Email: ${googleUser.email}');
      print('ID: ${googleUser.id}');
      print('========================================');

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the credential
      final UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      print('FIREBASE USER CREDENTIAL:');
      print('========================================');
      print('User UID: ${userCredential.user?.uid}');
      print('Display Name: ${userCredential.user?.displayName}');
      print('Email: ${userCredential.user?.email}');
      print('========================================');

      // Sign in to Django backend and get JWT token
      if (userCredential.user != null) {
        await _signInToBackend();
      }

      return userCredential;
    } catch (e) {
      print('========================================');
      print('ERROR SIGNING IN WITH GOOGLE:');
      print('========================================');
      print('Error: $e');
      print('========================================');
      rethrow;
    }
  }

  // Sign in to Django backend
  Future<void> _signInToBackend() async {
    try {
      print('Signing in to Django backend...');
      final result = await _backendService.signIn();
      
      if (result != null) {
        print('✅ Successfully signed in to backend');
        print('Is new user: ${result['is_new_user']}');
        print('User: ${result['user']}');
      } else {
        print('⚠️ Backend signin failed, but continuing with Firebase auth');
      }
    } catch (e) {
      print('⚠️ Error signing in to backend: $e');
      // Don't throw - allow sign-in to continue even if backend fails
    }
  }

  // Sign out
  Future<void> signOut() async {
    await _googleSignIn.signOut();
    await _auth.signOut();
    await _backendService.clearJwtToken();
  }

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Check if user is signed in
  bool isSignedIn() {
    return _auth.currentUser != null;
  }
}
