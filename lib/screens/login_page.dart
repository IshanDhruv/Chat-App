import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplechatapp/providers/auth_provider.dart';
import 'package:simplechatapp/services/navigation_service.dart';
import 'package:simplechatapp/services/snackbar_service.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  var _deviceHeight;
  var _deviceWidth;
  String email;
  String password;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthProvider _auth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: Center(
          child: ChangeNotifierProvider<AuthProvider>.value(
        value: AuthProvider.instance,
        child: _loginPageUI(),
      )),
    );
  }

  Widget _loginPageUI() {
    return Builder(
      builder: (context) {
        SnackBarService.instance.buildContext = context;
        _auth = Provider.of<AuthProvider>(context);
        return Container(
          height: _deviceHeight * 0.6,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[_heading(), _inputForm(), _loginButton(), _registerButton()],
          ),
        );
      },
    );
  }

  Widget _heading() {
    return Container(
      height: _deviceHeight * 0.12,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        mainAxisSize: MainAxisSize.max,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            "Welcome back!",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            "Please login to your account.",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
          )
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight * 0.16,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[_emailTextField(), _passwordTextField()],
        ),
      ),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      validator: (value) {
        return value.length != 0 && value.contains('@') ? null : "Please enter a valid email";
      },
      onSaved: (value) {
        setState(() {
          email = value;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
          hintText: "Email Address", focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _passwordTextField() {
    return TextFormField(
      autocorrect: false,
      obscureText: true,
      style: TextStyle(color: Colors.white),
      validator: (value) {
        return value.length >= 6 ? null : "Password should be longer than 6 characters";
      },
      onSaved: (value) {
        setState(() {
          password = value;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
          hintText: "Password", focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _loginButton() {
    return _auth.status == AuthStatus.Authenticating
        ? Center(child: CircularProgressIndicator())
        : Container(
            height: _deviceHeight * 0.06,
            width: _deviceWidth,
            child: MaterialButton(
              onPressed: () {
                if (_formKey.currentState.validate()) {
                  _auth.loginUser(email, password);
                }
              },
              color: Colors.blue,
              child: Text(
                "LOGIN",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          );
  }

  Widget _registerButton() {
    return Container(
      height: _deviceHeight * 0.06,
      width: _deviceWidth,
      child: MaterialButton(
        onPressed: () {
         NavigationService.instance.navigateTo("register");
        },
        child: Text(
          "REGISTER",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
