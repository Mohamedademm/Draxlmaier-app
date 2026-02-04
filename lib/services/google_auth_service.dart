import 'package:google_sign_in/google_sign_in.dart';
import 'api_service.dart';

class GoogleAuthService {
  final GoogleSignIn _googleSignIn = GoogleSignIn(
    scopes: ['email', 'profile'],
  );
  final ApiService _apiService = ApiService();

  Future<Map<String, dynamic>?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      
      if (googleUser == null) {
        print('Google Sign In: User cancelled');
        return null;
      }

      print('Google Sign In: User selected - ${googleUser.email}');

      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      print('Google Sign In: Got authentication token');

      final response = await _apiService.post('/auth/google', {
        'idToken': googleAuth.idToken,
        'email': googleUser.email,
        'displayName': googleUser.displayName,
        'photoUrl': googleUser.photoUrl,
      });

      print('Google Sign In: Backend response received');

      final data = _apiService.handleResponse(response);
      
      if (data['token'] != null) {
        await _apiService.setToken(data['token']);
        print('Google Sign In: Token saved successfully');
      } else {
        print('Google Sign In: No token in response');
      }

      return data;
    } catch (e) {
      print('Google Sign In Error: $e');
      rethrow;
    }
  }

  Future<void> signOut() async {
    try {
      await _googleSignIn.signOut();
      await _apiService.clearToken();
    } catch (e) {
      print('Google Sign Out Error: $e');
    }
  }

  Future<bool> isSignedIn() async {
    return await _googleSignIn.isSignedIn();
  }
}
