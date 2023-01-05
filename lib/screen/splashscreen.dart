import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:homestayraya/screen/profilescreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../model/user.dart';
import '../config.dart';
import 'package:http/http.dart' as http;

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    autoLogin();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: const [
              Text("HOMESTAY RAYA",
                  style: TextStyle(fontSize: 40, fontWeight: FontWeight.bold)),
              CircularProgressIndicator(),
              Text("Version Lab Asgm")
            ]),
      ),
    );
  }

  Future<void> autoLogin() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String email = (prefs.getString('email')) ?? '';
    String pass = (prefs.getString('pass')) ?? '';
    if (email.isNotEmpty) {
      http.post(Uri.parse("${Config.server}/php/login_user.php"),
          body: {"email": email, "password": pass}).then((response) {
        print(response.body);
        var jsonResponse = json.decode(response.body);
        if (response.statusCode == 200 && jsonResponse['status'] == "success") {
          User user = User.fromJson(jsonResponse['data']);
          Timer(
              const Duration(seconds: 3),
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (content) => ProfileScreen(user: user))));
        } else {
          User user = User(
              id: "0",
              email: "unregistered",
              name: "unregistered",
              address: "na",
              phone: "0123456789",
              regdate: "0");
          Timer(
              const Duration(seconds: 3),
              () => Navigator.pushReplacement(
                  context,
                  MaterialPageRoute(
                      builder: (content) => ProfileScreen(user: user))));
        }
      });
    } else {
      User user = User(
          id: "0",
          email: "unregistered@email.com",
          name: "unregistered",
          address: "na",
          phone: "0123456789",
          regdate: "0");
      Timer(
          const Duration(seconds: 3),
          () => Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (content) => ProfileScreen(user: user))));
    }
  }
}
