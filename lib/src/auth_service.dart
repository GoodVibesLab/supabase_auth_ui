import 'dart:convert';
import 'dart:math';

import 'package:google_sign_in/google_sign_in.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:crypto/crypto.dart';

class AuthService{

  // Sign in with Google
  static Future<String?> signInWithGoogle(SupabaseClient client) async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();

      // Obtain the auth details from the request
      final GoogleSignInAuthentication? googleAuth =
      await googleUser?.authentication;

      final credentials = await client.auth.signInWithIdToken(
          provider: Provider.google, idToken: googleAuth?.idToken ?? '');

      return credentials.user?.userMetadata?['name'];

    } catch (e) {
      rethrow;
    }
  }

  // Sign in with Apple
  static Future<String?> signInWithApple(SupabaseClient client) async {
    try {
      final rawNonce = _generateRandomString();
      final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
      );

      final idToken = credential.identityToken;
      if (idToken == null) {
        throw const AuthException(
            'Could not find ID Token from generated credential.');
      }

      await client.auth.signInWithIdToken(
        provider: Provider.apple,
        idToken: idToken,
        nonce: rawNonce,
      );

      return credential.givenName;
    } catch (e) {
      rethrow;
    }
  }

  static String _generateRandomString() {
    final random = Random.secure();
    return base64Url.encode(List<int>.generate(16, (_) => random.nextInt(256)));
  }

  // Sign in with Facebook
  static Future<void> signInWithFacebook(SupabaseClient client) async {
    try {
      await client.auth.signInWithOAuth(Provider.facebook);
    } catch (e) {
      rethrow;
    }
  }

  //Sign in with Twitter
  static Future<void> signInWithTwitter(SupabaseClient client) async {
    try {
      await client.auth.signInWithOAuth(Provider.twitter);
    } catch (e) {
      rethrow;
    }
  }

  //Sign in with Github
  static Future<void> signInWithGithub(SupabaseClient client) async {
    try {
      await client.auth.signInWithOAuth(Provider.github);
    } catch (e) {
      rethrow;
    }
  }

  static Future<void> signInWithPassword(SupabaseClient client,
      {required String email, required String password}) async {
    try {
      await client.auth
          .signInWithPassword(email: email, password: password);

    } catch (e) {
      rethrow;
    }
  }
}