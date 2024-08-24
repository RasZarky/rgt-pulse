import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:rgt_pulse/auth/forgot_Password.dart';
import 'package:rgt_pulse/auth/sign_up.dart';

import '../pages/root_app.dart';
import '../task_list.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController emailController = TextEditingController();
  TextEditingController passController = TextEditingController();
  bool _loading = false;
  bool isObscure = true;

  void _login() async {
    if (emailController.text.isNotEmpty && passController.text.isNotEmpty) {

      setState(() {
        _loading = true;
      });

      try {
        // Sign in with email and password
        UserCredential userCredential = await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: emailController.text,
          password: passController.text,
        );

        User? user = userCredential.user;

        // if (user != null
        //     &&
        //     !user.emailVerified
        // ) {
        //   // If email is not verified, send verification email
        //   await user.sendEmailVerification();
        //
        //   // Sign out to prevent unverified access
        //   await FirebaseAuth.instance.signOut();
        //
        //   ScaffoldMessenger.of(context).showSnackBar(
        //     SnackBar(
        //       content: Text('A verification email has been sent to ${emailController.text}. Please verify your email before logging in.'),
        //     ),
        //   );
        // } else {
          // Proceed to the app (replace '/home' with your home page route)
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => RootApp() ),(Route<dynamic> route) => false );
        //}
      } on FirebaseAuthException catch (e) {

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Error: ${e.message}")),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('An error occurred: $e')),
        );
      } finally {
        setState(() {
          _loading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color(0xff513677),
      body: SafeArea(
        child: OverlayLoaderWithAppIcon(
          isLoading: _loading,
          overlayOpacity: 0.7,
          appIconSize: 50,
          circularProgressColor: Colors.purple,
          overlayBackgroundColor: Colors.black,
          appIcon: Image.asset("assets/logo.png"),
          child: SingleChildScrollView(
            child: Container(
              height: size.height*1.3,
              child: Column(
                children: [
                  //give some space from top
                  const Expanded(
                    flex: 1,
                    child: Center(),
                  ),

                  //page content here
                  Expanded(
                    flex: 11,
                    child: buildCard(size),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget buildCard(Size size) {
    return SlideInUp(
      from: 700,
      child: Container(
        alignment: Alignment.center,
        decoration: const BoxDecoration(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(40), topRight: Radius.circular(40)),
          color: Colors.white,
        ),
        child: Padding(
          padding: const EdgeInsets.only(left: 20.0, right: 20, top: 20),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: <Widget>[
              //build minimize icon
              Align(
                alignment: Alignment.center,
                child: Container(
                  width: 35,
                  height: 4.0,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(8),
                    color: Colors.grey,
                  ),
                ),
              ),

              //logo section & getting started text here
              Expanded(
                flex: 4,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    //logo and text here
                    logo(size.height / 12, size.height / 12),
                    SizedBox(
                      height: size.height * 0.01,
                    ),
                    richText(24),
                    SizedBox(
                      height: size.height * 0.03,
                    ),

                    SizedBox(height: 20,),

                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Email',
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        emailTextField(size),
                      ],
                    ),

                    const SizedBox(
                      height: 16,
                    ),

                    //password textField & forget text here
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Password',
                          style: GoogleFonts.inter(
                            fontSize: 14.0,
                            color: Colors.black,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                        const SizedBox(
                          height: 8,
                        ),
                        passwordTextField(size),
                        const SizedBox(
                          height: 8,
                        ),

                        //forget text
                        Align(
                          alignment: Alignment.centerRight,
                          child: GestureDetector(
                            onTap: (){
                              Navigator.pushReplacement(
                                  context, MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()));
                            },
                            child: Text(
                              'Forgot password?',
                              style: GoogleFonts.inter(
                                fontSize: 12.0,
                                color: const Color(0xFFF56B3F),
                                height: 1.17,
                              ),
                              textAlign: TextAlign.right,
                            ),
                          ),
                        ),
                      ],
                    ),

                    const SizedBox(
                      height: 25,
                    ),

                    signInButton(size),

                    const SizedBox(
                      height: 25,
                    ),

                    buildFooter(size)
                  ],
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }

  Widget logo(double height_, double width_) {
    return Image.asset(
      'assets/logo.png',
      height: height_*2,
      width: width_*2,
    );
  }

  Widget richText(double fontSize) {
    return Text.rich(
      TextSpan(
        style: GoogleFonts.inter(
          fontSize: fontSize,
          color: const Color(0xff513677),
          letterSpacing: 2.000000061035156,
        ),
        children: const [
          TextSpan(
            text: 'RGT ',
            style: TextStyle(
              fontWeight: FontWeight.w800,
            ),
          ),
          TextSpan(
            text: 'PULSE',
            style: TextStyle(
              color: Color(0xFFFE9879),
              fontWeight: FontWeight.w800,
            ),
          ),
        ],
      ),
    );
  }

  Widget emailTextField(Size size) {
    return SizedBox(
      height: size.height / 13,
      child: TextField(
        controller: emailController,
        style: GoogleFonts.inter(
          fontSize: 18.0,
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        keyboardType: TextInputType.emailAddress,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          hintText: 'Enter your email',
          hintStyle: GoogleFonts.inter(
            fontSize: 16.0,
            color: const Color(0xFF151624).withOpacity(0.5),
          ),
          filled: true,
          fillColor: emailController.text.isEmpty
              ? const Color.fromRGBO(248, 247, 251, 1)
              : Colors.transparent,
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: BorderSide(
                color: emailController.text.isEmpty
                    ? Colors.transparent
                    : const Color(0xff513677),
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: Color(0xff513677),
              )),
          prefixIcon: Icon(
            Icons.mail_outline_rounded,
            color: emailController.text.isEmpty
                ? const Color(0xFF151624).withOpacity(0.5)
                : const Color(0xff513677),
            size: 16,
          ),
          suffix: Container(
            alignment: Alignment.center,
            width: 24.0,
            height: 24.0,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(100.0),
              color: const Color(0xff513677),
            ),
            child: emailController.text.isEmpty
                ? const Center()
                : const Icon(
              Icons.check,
              color: Colors.white,
              size: 13,
            ),
          ),
        ),
      ),
    );
  }

  Widget passwordTextField(Size size) {
    return Container(
      height: size.height / 13,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(8),
        color: const Color.fromRGBO(248, 247, 251, 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: TextField(
              controller: passController,
              style: GoogleFonts.inter(
                fontSize: 16.0,
                color: const Color(0xFF151624),
              ),
              cursorColor: const Color(0xFF151624),
              obscureText: isObscure,
              keyboardType: TextInputType.visiblePassword,
              decoration: InputDecoration(
                hintText: 'Enter your password',
                hintStyle: GoogleFonts.inter(
                  fontSize: 16.0,
                  color: const Color(0xFF151624).withOpacity(0.5),
                ),
                prefixIcon: Icon(
                  Icons.lock_outline_rounded,
                  color: emailController.text.isEmpty
                      ? const Color(0xFF151624).withOpacity(0.5)
                      : const Color(0xff513677),
                  size: 16,
                ),
                border: InputBorder.none,
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: BorderSide(
                      color: emailController.text.isEmpty
                          ? Colors.transparent
                          : const Color(0xff513677),
                    )),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(8),
                    borderSide: const BorderSide(
                      color: Color(0xff513677),
                    )),
              ),
            ),
          ),
          passController.text.isEmpty
              ? const Center()
              : GestureDetector(
            onTap: (){
              setState(() {
                isObscure = !isObscure;
              });
            },
            child: Container(
              height: 30,
              width: 60,
              alignment: Alignment.center,
              decoration: BoxDecoration(
                  color: const Color.fromRGBO(249, 225, 224, 1),
                  borderRadius: BorderRadius.circular(4),
                  border: Border.all(
                    color: isObscure ? const Color.fromRGBO(254, 152, 121, 1)
                        : Colors.green,
                  )),
              child: isObscure ? Text(
                'View',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  color: const Color(0xFFFE9879),
                  fontWeight: FontWeight.w500,
                ),
              )
                  : Text(
                'Hide',
                textAlign: TextAlign.center,
                style: GoogleFonts.inter(
                  fontSize: 12.0,
                  color: Colors.green,
                  fontWeight: FontWeight.w500,
                ),
              ) ,
            ),
          ),
        ],
      ),
    );
  }

  Widget signInButton(Size size) {
    return // Group: Button
      GestureDetector(
        onTap: (){
          _login();
        },
        child: Container(
          alignment: Alignment.center,
          height: size.height / 13,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12.0),
            color: const Color(0xff513677),
            boxShadow: [
              BoxShadow(
                color: Colors.purple.withOpacity(0.2),
                offset: const Offset(0, 15.0),
                blurRadius: 60.0,
              ),
            ],
          ),
          child: Text(
            'Sign in',
            style: GoogleFonts.inter(
              fontSize: 16.0,
              color: Colors.white,
              fontWeight: FontWeight.w600,
              height: 1.5,
            ),
            textAlign: TextAlign.center,
          ),
        ),
      );
  }

  Widget buildFooter(Size size) {
    return Center(
      child: GestureDetector(
        onTap: (){
          Navigator.pushReplacement(
              context, MaterialPageRoute(builder: (context) => const SignUpScreen()));
        },
        child: Text.rich(
          TextSpan(
            style: GoogleFonts.inter(
              fontSize: 12.0,
              color: Colors.black,
            ),
            children: const [
              TextSpan(
                text: 'Don’t have an account? ',
                style: TextStyle(
                  fontWeight: FontWeight.w500,
                ),
              ),
              TextSpan(
                text: 'Sign Up here',
                style: TextStyle(
                  color: Color(0xFFFF7248),
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
