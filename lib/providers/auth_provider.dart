import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:simplechatapp/services/db_service.dart';
import 'package:simplechatapp/services/navigation_service.dart';
import 'package:simplechatapp/services/snackbar_service.dart';

enum AuthStatus { NotAuthenticated, Authenticating, Authenticated, UserNotFound, Error }

class AuthProvider extends ChangeNotifier {
  FirebaseUser user;
  FirebaseAuth _auth;
  AuthStatus status;
  static AuthProvider instance = AuthProvider();

  AuthProvider() {
    _auth = FirebaseAuth.instance;
    _checkIfCurrentUserIsAuthenticated();
  }

  void _autoLogin() async {
    if (user != null) {
      status = AuthStatus.Authenticating;
      await DBService.instance.updateUseLastSeen(user.uid);
      status = AuthStatus.Authenticated;
      return NavigationService.instance.navigateToReplacement("home");
    }
  }

  void _checkIfCurrentUserIsAuthenticated() async {
    user = await _auth.currentUser();
    if (user != null) {
      notifyListeners();
      _autoLogin();
    }
  }

  loginUser(String _email, String _password) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      AuthResult _result = await _auth.signInWithEmailAndPassword(email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      NavigationService.instance.navigateToReplacement("home");
      SnackBarService.instance.showSnackBarSuccess("Welcome ${user.displayName}");
      DBService.instance.updateUseLastSeen(user.uid);
    } catch (e) {
      user = null;
      status = AuthStatus.Error;
      SnackBarService.instance.showSnackBarError(e.toString());
    }
    notifyListeners();
  }

  registerUser(String _email, String _password, Future onSuccess(String _uid)) async {
    status = AuthStatus.Authenticating;
    notifyListeners();
    try {
      AuthResult _result = await _auth.createUserWithEmailAndPassword(email: _email, password: _password);
      user = _result.user;
      status = AuthStatus.Authenticated;
      await onSuccess(user.uid);
      NavigationService.instance.goBack();
      NavigationService.instance.navigateToReplacement("home");
      SnackBarService.instance.showSnackBarSuccess("Registered ${user.displayName}");
      DBService.instance.updateUseLastSeen(user.uid);
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackBarError(e.toString());
    }
    notifyListeners();
  }

  logoutUser(Future onSuccess()) async {
    try {
      await _auth.signOut();
      user = null;
      status = AuthStatus.NotAuthenticated;
      await onSuccess();
      NavigationService.instance.navigateToReplacement("login");
      SnackBarService.instance.showSnackBarSuccess("Logged Out");
    } catch (e) {
      status = AuthStatus.Error;
      user = null;
      SnackBarService.instance.showSnackBarError(e.toString());
    }
  }
}
