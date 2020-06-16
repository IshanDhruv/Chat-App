import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:simplechatapp/screens/home_page.dart';
import 'package:simplechatapp/screens/login_page.dart';
import 'package:simplechatapp/screens/register_page.dart';
import 'package:simplechatapp/services/navigation_service.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Chat App',
      navigatorKey: NavigationService.instance.navigatorKey,
      initialRoute: "login",
      routes: {
        "login" : (context) => LoginPage(),
        "register" : (context) => RegistrationPage(),
        "home" : (context) => HomePage()
      },
      theme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: Color.fromRGBO(42, 117,188, 1),
        accentColor: Color.fromRGBO(42, 117,188, 1),
        backgroundColor: Color.fromRGBO(28, 27, 27, 1),
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
    );
  }
}

