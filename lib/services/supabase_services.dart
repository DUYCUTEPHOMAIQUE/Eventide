import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class SupabaseServices {
  static SupabaseClient client = Supabase.instance.client;

  static Future<User?> getCurrentUser() async {
    final user = client.auth.currentUser;

    return user;
  }

  static Future<void> signOut() async {
    await client.auth.signOut();
  }

  static Future<AuthResponse> signInWithGoogle() async {
    try {
      print("TEST11===");
      final googleSignIn = GoogleSignIn(
        serverClientId: dotenv.env['GOOGLE_CLIENT_ID']!,
      );
      print(googleSignIn);

      final googleUser = await googleSignIn.signIn();
      print("TEST22===");

      if (googleUser == null) {
        throw 'Google Sign-In was cancelled by user';
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      final accessToken = googleAuth.accessToken;
      final idToken = googleAuth.idToken;
      print('accessToken:: $accessToken');
      print("idToken:: $idToken");

      if (accessToken == null || idToken == null) {
        throw 'Google Sign-In Error: accessToken or idToken is null';
      }

      final AuthResponse response = await client.auth.signInWithIdToken(
        provider: OAuthProvider.google,
        idToken: idToken,
        accessToken: accessToken,
      );

      return response;
    } catch (e) {
      print('Error during Google Sign-In: $e');
      Fluttertoast.showToast(
        msg: 'Đăng nhập thất bại: ${e.toString()}',
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.BOTTOM,
      );
      rethrow;
    }
  }

  static Future<AuthResponse> signInWithEmailAndPassword(
      String email, String password) async {
    final response = await client.auth.signInWithPassword(
      email: email,
      password: password,
    );
    return response;
  }
}
