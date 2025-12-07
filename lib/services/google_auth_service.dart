import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

/// Google Authentication Service
class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final ApiService _apiService = ApiService();

  /// Sign in with Google
  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      // Trigger Google Sign In flow
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        print('Google Sign In: User cancelled');
        return null;
      }

      print('Google Sign In: User selected - ${googleUser.email}');

      // Obtain auth details
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('Google Sign In: Got authentication token');

      // Send Google token to backend for verification and user creation/login
      final response = await _apiService.post('/auth/google', {
        'idToken': googleAuth.idToken,
        'email': googleUser.email,
        'displayName': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
      });

      print('Google Sign In: Backend response received');

      final data = _apiService.handleResponse(response);
      
      // Save JWT token
      if (data['token'] != null) {
        await _apiService.setToken(data['token']);
        print('Google Sign In: Token saved successfully');
      } else {
        print('Google Sign In: No token in response');
      }

      return data;
    } catch (e) {
      print('Google Sign In Error: $e');
      // Re-throw the original error for better error messages
      rethrow;
    }
  }

  /// Sign out from Google
  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _apiService.clearToken();
    } catch (e) {
      print('Google Sign Out Error: $e');
    }
  }

  /// Check if user is signed in with Google
  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}
