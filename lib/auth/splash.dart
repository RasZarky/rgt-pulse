import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:rgt_pulse/auth/login.dart';
import 'package:rgt_pulse/auth/t_login.dart';
import 'package:rgt_pulse/task_list.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {

  bool loading = false;

  void _checkLoginStatus() async {
    // Simulate a delay for the splash screen
    await Future.delayed(Duration(seconds: 2));

    User? user = FirebaseAuth.instance.currentUser;

    if (user != null) {
      if (user.emailVerified) {
        // User is logged in and email is verified
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => TaskListPage()),
        );
      } else {
        // User is logged in but email is not verified
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginScreen()),
        );
      }
    } else {
      // User is not logged in
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    }
  }

  @override
  void initState() {
    // TODO: implement initState
    _checkLoginStatus();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xff513677),
      body: OverlayLoaderWithAppIcon(
          isLoading: true,
          overlayOpacity: 0.7,
          appIconSize: 50,
          circularProgressColor: Colors.purple,
          overlayBackgroundColor: Colors.transparent,
          appIcon: Image.asset("assets/logo.png"),
        child: Container(
          child: Image.asset("assets/splash.png",
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height,
            fit: BoxFit.cover,),
        ),
      )
    );
  }
}
