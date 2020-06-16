import 'dart:io';

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplechatapp/providers/auth_provider.dart';
import 'package:simplechatapp/services/cloud_storage_service.dart';
import 'package:simplechatapp/services/db_service.dart';
import 'package:simplechatapp/services/media_service.dart';
import 'package:simplechatapp/services/navigation_service.dart';
import 'package:simplechatapp/services/snackbar_service.dart';

class RegistrationPage extends StatefulWidget {
  @override
  _RegistrationPageState createState() => _RegistrationPageState();
}

class _RegistrationPageState extends State<RegistrationPage> {
  var _deviceHeight;
  var _deviceWidth;
  String _name;
  String _email;
  String _password;
  File _image;
  GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  AuthProvider _auth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      body: SingleChildScrollView(
        child: Center(
            child: ChangeNotifierProvider<AuthProvider>.value(
          value: AuthProvider.instance,
          child: _registerPageUI(),
        )),
      ),
    );
  }

  Widget _registerPageUI() {
    return Builder(
      builder: (context) {
        SnackBarService.instance.buildContext = context;
        _auth = Provider.of<AuthProvider>(context);
        return Container(
          height: _deviceHeight * 0.75,
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(horizontal: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            mainAxisSize: MainAxisSize.max,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[_heading(), _inputForm(), _registerButton(), _backButton()],
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
            "Lets get going!!",
            style: TextStyle(fontSize: 35, fontWeight: FontWeight.w700),
          ),
          Text(
            "Register your new account.",
            style: TextStyle(fontSize: 25, fontWeight: FontWeight.w200),
          )
        ],
      ),
    );
  }

  Widget _inputForm() {
    return Container(
      height: _deviceHeight * 0.35,
      child: Form(
        key: _formKey,
        onChanged: () {
          _formKey.currentState.save();
        },
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[_imageSelector(), _nameTextField(), _emailTextField(), _passwordTextField()],
        ),
      ),
    );
  }

  Widget _nameTextField() {
    return TextFormField(
      autofocus: true,
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      validator: (value) {
        return value.length >= 2 ? null : "Please enter a valid name";
      },
      onSaved: (value) {
        setState(() {
          _name = value;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
          hintText: "Name", focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _emailTextField() {
    return TextFormField(
      keyboardType: TextInputType.emailAddress,
      autocorrect: false,
      style: TextStyle(color: Colors.white),
      validator: (value) {
        return value.length != 0 && value.contains('@') ? null : "Please enter a valid email";
      },
      onSaved: (value) {
        setState(() {
          _email = value;
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
          _password = value;
        });
      },
      cursorColor: Colors.white,
      decoration: InputDecoration(
          hintText: "Password", focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.white))),
    );
  }

  Widget _registerButton() {
    return _auth.status == AuthStatus.Authenticating
        ? Center(child: CircularProgressIndicator())
        : Container(
            height: _deviceHeight * 0.06,
            width: _deviceWidth,
            child: MaterialButton(
              onPressed: () {
                if (_formKey.currentState.validate() && _image != null) {
                  try {
                    print("trying");
                    _auth.registerUser(_email, _password, (_uid) async {
                      var _result = await CloudStorageService.instance.uploadUserImage(_uid, _image);
                      var _imageURL = await _result.ref.getDownloadURL();
                      await DBService.instance.createUser(_uid, _name, _email, _imageURL);
                    });
                  } catch (e) {
                    print(e);
                  }
                }
              },
              color: Colors.blue,
              child: Text(
                "REGISTER",
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
              ),
            ),
          );
  }

  Widget _backButton() {
    return Container(
      height: _deviceHeight * 0.06,
      width: _deviceWidth,
      child: MaterialButton(
        onPressed: () {
          NavigationService.instance.goBack();
        },
        child: IconButton(
          icon: Icon(
            Icons.arrow_back,
            color: Colors.white,
          ),
        ),
      ),
    );
  }

  Widget _imageSelector() {
    return Center(
      child: GestureDetector(
        onTap: () async {
          var _imageFile = await MediaService.instance.getImageFromLibrary();
          setState(() {
            _image = _imageFile;
          });
        },
        child: Container(
          height: _deviceHeight * 0.1,
          width: _deviceWidth * 0.1,
          decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(500),
              image: DecorationImage(
                  image: _image != null
                      ? FileImage(_image)
                      : NetworkImage(
                          "https://cdn0.iconfinder.com/data/icons/occupation-002-1/64/programmer-programming-occupation-avatar-512.png"))),
        ),
      ),
    );
  }
}
