import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplechatapp/models/contact.dart';
import 'package:simplechatapp/providers/auth_provider.dart';
import 'package:simplechatapp/services/db_service.dart';

class ProfilePage extends StatelessWidget {
  var _deviceHeight;
  var _deviceWidth;
  AuthProvider _auth;

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Container(
      child: ChangeNotifierProvider<AuthProvider>.value(value: AuthProvider.instance, child: _profilePageUI()),
    );
  }

  _profilePageUI() {

    return Builder(
      builder: (BuildContext _context) {
        _auth = Provider.of<AuthProvider>(_context);
        return StreamBuilder<Object>(
            stream: DBService.instance.getUserData(_auth.user.uid),
            builder: (context, _snapshot) {
              if (_snapshot.data == null)
                return Center(child: CircularProgressIndicator());
              else {
                Contact _userData = _snapshot.data;
                return Center(
                    child: SizedBox(
                  height: _deviceHeight * 0.5,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    mainAxisSize: MainAxisSize.max,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      _userImageWidget(_userData.image),
                      _userNameWidget(_userData.name),
                      _userEmailWidget(_userData.email),
                      _logoutButton()
                    ],
                  ),
                ));
              }
            });
      },
    );
  }

  _userImageWidget(String _image) {
    var _imageRadius = _deviceHeight * 0.2;
    return Container(
      height: _imageRadius,
      width: _imageRadius,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(_imageRadius),
          image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(_image))),
    );
  }

  _userNameWidget(String _name) {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceWidth,
      child: Text(
        _name,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white, fontSize: 30),
      ),
    );
  }

  _userEmailWidget(String _email) {
    return Container(
      height: _deviceHeight * 0.05,
      width: _deviceWidth,
      child: Text(
        _email,
        textAlign: TextAlign.center,
        style: TextStyle(color: Colors.white24, fontSize: 15),
      ),
    );
  }

  _logoutButton() {
    return Container(
      height: _deviceHeight * 0.06,
      width: _deviceWidth * 0.8,
      child: MaterialButton(
        color: Colors.red,
        onPressed: () {
          _auth.logoutUser(() => null);
        },
        child: Text(
          "LOGOUT",
          style: TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
        ),
      ),
    );
  }
}
