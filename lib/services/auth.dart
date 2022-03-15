import 'dart:io';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:pol_dbms/services/db.dart';

class FireAuth {
  String lastError = '';

  static final FireAuth _singleton = FireAuth._internal();

  factory FireAuth() {
    return _singleton;
  }

  FireAuth._internal();
  // For registering a new user
  static Future<User?> registerUsingEmailPassword({
    required String name,
    required String email,
    required String password,
  }) async {
    String appId = Platform.isIOS
        ? '1:215355536969:ios:bc19e66c79bba7d1ec3198'
        : Platform.isAndroid
            ? '1:215355536969:android:fc9dc5a2d24a5f6aec3198'
            : '';
    final String apiKey = Platform.isIOS
        ? 'AIzaSyARz6GMoZVzu6E3wMHqeUYtFxbrboLdQV0'
        : Platform.isAndroid
            ? 'AIzaSyDFGVFsMTSTAk12bCvnj97ejNauRW8elo4'
            : '';
    await Firebase.initializeApp(
        name: 'SecondaryApp',
        options: FirebaseOptions(
            appId: appId,
            apiKey: apiKey,
            messagingSenderId: '215355536969',
            projectId: 'pdn-dbms'));

    FirebaseApp secondaryApp = Firebase.app('SecondaryApp');
    FirebaseAuth auth = FirebaseAuth.instanceFor(app: secondaryApp);
    User? user;

    UserCredential userCredential = await auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    user = userCredential.user;
    // ignore: deprecated_member_use
    await user!.updateProfile(displayName: name);
    await Db().addUser(uid: user.uid, name: name);
    // await user.reload();
    user = auth.currentUser;
    auth.signOut();

    await secondaryApp.delete();

    return user;
  }

  setLastError(String error) {
    lastError = error;
  }

  getLasError() {
    return lastError;
  }

  // For signing in an user (have already registered)
  Future<User?> signInUsingEmailPassword({
    required String email,
    required String password,
  }) async {
    FirebaseAuth auth = FirebaseAuth.instance;
    User? user;

    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      user = userCredential.user;
    } on FirebaseAuthException catch (e) {
      if (e.code == 'user-not-found') {
        setLastError('No user found for that email.');
      } else if (e.code == 'wrong-password') {
        setLastError('Wrong password provided.');
      }
      user = null;
    }

    return user;
  }

  static Future<User?> refreshUser(User user) async {
    FirebaseAuth auth = FirebaseAuth.instance;

    await user.reload();
    User? refreshedUser = auth.currentUser;

    return refreshedUser;
  }

  static Future signOut() async {
    try {
      FirebaseAuth auth = FirebaseAuth.instance;

      return await auth.signOut();
    } catch (error) {
      return null;
    }
  }
}
