import 'package:flutter/material.dart';
import 'package:simplechatapp/screens/profile_page.dart';
import 'package:simplechatapp/screens/recent_conversations_page.dart';
import 'package:simplechatapp/screens/search_page.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {

  var _deviceHeight;
  var _deviceWidth;

  int _selectedIndex = 1;

  static List<Widget> _widgetOptions = <Widget>[SearchPage(),RecentConversationsPage(), ProfilePage()];

  void _onTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {

    _deviceHeight = MediaQuery.of(context).size.height;
    _deviceWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: Theme.of(context).backgroundColor,
      appBar: AppBar(
          title: Text("Chats", style: TextStyle(fontSize: 16)), backgroundColor: Theme.of(context).backgroundColor),
      body: _widgetOptions.elementAt(_selectedIndex),
      bottomNavigationBar: BottomNavigationBar(
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(icon: Icon(Icons.people), title: Text("People")),
          BottomNavigationBarItem(icon: Icon(Icons.chat), title: Text("Chats")),
          BottomNavigationBarItem(icon: Icon(Icons.person), title: Text("Profile"))
        ],
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.blue[800],
        onTap: _onTapped,
      ),
    );
  }
}
