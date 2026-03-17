import 'dart:async';
import 'package:bloc/bloc.dart';
import 'package:firebase_auth/firebase_auth.dart' as fb;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:shared_preferences/shared_preferences.dart';
part 'auth_state.dart';

class AuthCubit extends Cubit<AuthState> {
  final fb.FirebaseAuth _auth;
  final FirebaseFirestore _firestore;
  StreamSubscription<fb.User?>? _sub;

  AuthCubit(this._auth, this._firestore) : super(AuthInitial());

  void start() async {
    final prefs = await SharedPreferences.getInstance();
    final remember = prefs.getBool('rememberMe') ?? false;

    if (!remember) {
      await _auth.signOut();
      emit(AuthUnauthenticated());
      return;
    }

    _sub = _auth.authStateChanges().listen((user) async {
      if (user == null) {
        emit(AuthUnauthenticated());
      } else {
        emit(AuthAuthenticated(uid: user.uid, email: user.email ?? ''));
      }
    }, onError: (e) => emit(AuthError(e.toString())));
  }

  Future<void> register(
    String email,
    String password,
    String name, {
    String? gender,
    bool remember = false,
  }) async {
    emit(AuthLoading());
    try {
      final cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;
      if (remember) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('savedEmail', email);
        await prefs.setString('savedPassword', password);
        await prefs.setBool('rememberMe', true);
      } else {
        await clearRememberedUser();
      }
      await _firestore.collection('users').doc(user.uid).set({
        'uid': user.uid,
        'email': user.email,
        'name': name,
        'gender': gender ?? "",
        'createdAt': FieldValue.serverTimestamp(),
      });
      emit(AuthAuthenticated(uid: user.uid, email: user.email ?? ""));
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Registration failed'));
      emit(AuthUnauthenticated());
    }
  }

  Future<void> login(
    String email,
    String password, {
    bool remember = false,
  }) async {
    emit(AuthLoading());
    try {
      final cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      final user = cred.user!;

      if (remember) {
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('savedEmail', email);
        await prefs.setString('savedPassword', password);
        await prefs.setBool('rememberMe', true);
      } else {
        await clearRememberedUser();
      }

      emit(AuthAuthenticated(uid: user.uid, email: user.email ?? ''));
    } on fb.FirebaseAuthException catch (e) {
      emit(AuthError(e.message ?? 'Login failed'));
      emit(AuthUnauthenticated());
    }
  }

  Future<Map<String, dynamic>> loadRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    return {
      'email': prefs.getString('savedEmail') ?? '',
      'password': prefs.getString('savedPassword') ?? '',
      'remember': prefs.getBool('rememberMe') ?? false,
    };
  }

  Future<void> clearRememberedUser() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('savedEmail');
    await prefs.remove('savedPassword');
    await prefs.setBool('rememberMe', false);
  }

  Future<void> logout() async {
    await clearRememberedUser();
    await _auth.signOut();
    emit(AuthUnauthenticated());
  }

  @override
  Future<void> close() {
    _sub?.cancel();
    return super.close();
  }
}
