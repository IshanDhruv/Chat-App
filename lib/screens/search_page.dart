import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:simplechatapp/models/contact.dart';
import 'package:simplechatapp/providers/auth_provider.dart';
import 'package:simplechatapp/screens/chats_page.dart';
import 'package:simplechatapp/services/db_service.dart';
import 'package:simplechatapp/services/navigation_service.dart';
import 'package:timeago/timeago.dart' as timeago;

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  var _deviceHeight;
  var _deviceWidth;
  AuthProvider _auth;
  String _searchName = "";

  @override
  Widget build(BuildContext context) {
    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return ChangeNotifierProvider<AuthProvider>.value(
      value: AuthProvider.instance,
      child: _searchPageUI(),
    );
  }

  _searchPageUI() {
    return Builder(
      builder: (context) {
        _auth = Provider.of<AuthProvider>(context);
        return Column(
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.max,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[_userSearchField(), _usersListView()],
        );
      },
    );
  }

  _userSearchField() {
    return Container(
      height: _deviceHeight * 0.08,
      width: _deviceWidth,
      padding: EdgeInsets.symmetric(horizontal: _deviceWidth * 0.02),
      child: TextField(
        autocorrect: false,
        style: TextStyle(color: Colors.white),
        onSubmitted: (value) {
          setState(() {
            _searchName = value;
          });
        },
        decoration: InputDecoration(
            icon: Icon(Icons.search, color: Colors.white),
            labelText: "Search",
            labelStyle: TextStyle(color: Colors.white),
            border: OutlineInputBorder(borderSide: BorderSide.none)),
      ),
    );
  }

  _usersListView() {
    return StreamBuilder<Object>(
        stream: DBService.instance.getUsers(_searchName),
        builder: (context, snapshot) {
          List _usersData = snapshot.data;
          if (_usersData != null) _usersData.removeWhere((_contact) => _contact.id == _auth.user.uid);
          return snapshot.hasData
              ? Container(
                  height: _deviceHeight * 0.75,
                  child: ListView.builder(
                    itemCount: _usersData.length,
                    itemBuilder: (context, index) {
                      Contact _userData = _usersData[index];
                      var _currentTime = DateTime.now();
                      var _recipientID = _usersData[index].id;
                      var _isUserActive =
                          !_userData.lastSeen.toDate().isBefore(_currentTime.subtract(Duration(hours: 1)));
                      return ListTile(
                        onTap: () {
                          DBService.instance.createConversation(
                            _auth.user.uid,
                            _recipientID,
                            (String _conversationID) => NavigationService.instance.navigateToRoute(
                              MaterialPageRoute(
                                builder: (context) => ChatsPage(
                                  conversationID: _conversationID,
                                  receiverID: _recipientID,
                                  receiverName: _userData.name,
                                  receiverImage: _userData.image,
                                ),
                              ),
                            ),
                          );
                        },
                        title: Text(_userData.name),
                        leading: Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            image: DecorationImage(fit: BoxFit.cover, image: NetworkImage(_userData.image)),
                          ),
                        ),
                        trailing: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                          mainAxisSize: MainAxisSize.max,
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: <Widget>[
                            _isUserActive
                                ? Text("Active now", style: TextStyle(fontSize: 15))
                                : Text("Last seen", style: TextStyle(fontSize: 15)),
                            _isUserActive
                                ? Container(
                                    height: 12,
                                    width: 12,
                                    decoration:
                                        BoxDecoration(color: Colors.green, borderRadius: BorderRadius.circular(100)),
                                  )
                                : Text(timeago.format(_userData.lastSeen.toDate()), style: TextStyle(fontSize: 15)),
                          ],
                        ),
                      );
                    },
                  ))
              : CircularProgressIndicator();
        });
  }
}
