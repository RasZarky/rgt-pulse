import 'dart:math';

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:percent_indicator/circular_percent_indicator.dart';
import 'dart:convert';
import 'package:rgt_pulse/auth/login.dart';
import 'package:rgt_pulse/task_list.dart';
import '../theme/colors.dart';

class ProfilePage extends StatefulWidget {
  @override
  _ProfilePageState createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  String? userEmail;
  String? name;
  String? pic;
  String? id;
  Map<String, dynamic>? userData;
  bool loading = false;

  int totalTasks = 0;
  int tasksWithSpecifiedStatus = 0;
  int tasksWithoutSpecifiedStatus = 0;

  double percentageWithSpecifiedStatus = 0.0;
  double percentageWithoutSpecifiedStatus = 0.0;

  @override
  void initState() {
    super.initState();
    _getUserEmail();
    _loadUserData();
  }

  // Get current user's email from FirebaseAuth
  void _getUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email;
    });
  }

  Future<void> _loadUserData() async {
    setState(() {
      loading = true;
    });

    // Load JSON from file
    String jsonString = await rootBundle.loadString('assets/jesse.task_activities.json');
    List<dynamic> jsonData = json.decode(jsonString);

    // Variables to store user data
    Map<String, dynamic>? foundUserData;
    List<dynamic> userTasks = [];
    String? userName;
    String? userPic;
    int? userId;

    for (var task in jsonData) {
      var current = task['current'];
      bool isCollaborator = false;

      // Iterate through collaborators to find a match
      for (var collaborator in current['collaborators']) {
        if (collaborator['email'] == userEmail) {
          isCollaborator = true;
          userName = collaborator['username'];
          userId = collaborator['id'];
          userPic = collaborator['profilePicture'];
          break;  // Stop the loop once a match is found
        }
      }

      if (isCollaborator) {
        foundUserData = current;
        userTasks.add(current);  // Add the task to the userTasks list
      }
    }

    _calculateTaskPercentages(userTasks);  // Calculate percentages based on the list of tasks

    setState(() {
      userData = foundUserData;
      name = userName;
      id = userId.toString();
      pic = userPic;
      loading = false;
      // Store the retrieved user name and id
      print("User Name: $userName");
      print("User ID: $userId");
    });
  }

  void _calculateTaskPercentages(List<dynamic> userTasks) {
    totalTasks = userTasks.length;
    print("Total tasks = $totalTasks---------------------------------------------");
    for (var task in userTasks) {
      String status = task['status']['status'];

      if (status == 'to do' || status == 'in progress' || status == 'reject') {
        tasksWithSpecifiedStatus++;
      } else {
        tasksWithoutSpecifiedStatus++;
      }
    }

    if (totalTasks > 0) {
      setState(() {
        percentageWithSpecifiedStatus =
            (tasksWithSpecifiedStatus / totalTasks) * 100;
        percentageWithoutSpecifiedStatus =
            (tasksWithoutSpecifiedStatus / totalTasks) * 100;
      });
    }
  }


  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Confirm Logout'),
          content: Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                FirebaseAuth.instance.signOut();
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (context) => const LoginScreen()),
                      (Route<dynamic> route) => false,
                ); // Close the dialog
              },
              child: Text('Logout'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.05),
      body: OverlayLoaderWithAppIcon(
          isLoading: loading,
          overlayOpacity: 0.7,
          appIconSize: 50,
          circularProgressColor: Colors.purple,
          overlayBackgroundColor: Colors.black,
          appIcon: Image.asset("assets/logo.png"),
          child: getBody()),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;

    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: BoxDecoration(color: white, boxShadow: [
              BoxShadow(
                color: grey.withOpacity(0.01),
                spreadRadius: 20,
                blurRadius: 3,
              ),
            ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 30, right: 20, left: 20, bottom: 25),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/logo.png", height: 70, width: 70),
                      const Text(
                        "Profile",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                      GestureDetector(
                        onTap: _showLogoutDialog,
                        child: Icon(Icons.logout),
                      )
                    ],
                  ),
                  SizedBox(height: 25),
                  Row(
                    children: [
                      Container(
                        width: (size.width - 40) * 0.4,
                        child: Stack(
                          children: [
                            RotatedBox(
                              quarterTurns: -2,
                              child: CircularPercentIndicator(
                                circularStrokeCap: CircularStrokeCap.round,
                                backgroundColor: grey.withOpacity(0.3),
                                radius: 110.0,
                                lineWidth: 6.0,
                                percent: percentageWithoutSpecifiedStatus/100,
                                animation: true,
                                restartAnimation: true,
                                progressColor: primary,
                              ),
                            ),
                            Positioned(
                              top: 13,
                              left: 13,
                              child: Container(
                                width: 85,
                                height: 85,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                        image: pic != null ? NetworkImage(pic!)
                                            : const AssetImage("assets/images/profile.jpg"),
                                        fit: BoxFit.cover)),
                              ),
                            )
                          ],
                        ),
                      ),
                      Container(
                        width: (size.width - 40) * 0.6,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name ?? "Collaborate to update",
                              style: const TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.bold,
                                  color: black),
                            ),
                            Text(
                              id ?? 'Collaborate to update',
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: black),
                            ),
                            Text(
                                userEmail ?? "Collaborate to update",
                              style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: black),
                            ),
                            SizedBox(height: 10),
                            Text(
                              "Geek Score: ${percentageWithoutSpecifiedStatus.toInt()}%",
                              style: TextStyle(
                                  fontSize: 14,
                                  fontWeight: FontWeight.w500,
                                  color: Color(0xFFFE9879)),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                  SizedBox(height: 25),
                  Container(
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: primary,
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: primary.withOpacity(0.01),
                            spreadRadius: 10,
                            blurRadius: 3,
                          ),
                        ]),
                    child: Padding(
                      padding: const EdgeInsets.all(25.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              GestureDetector(
                                onTap: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => TaskListPage() ));
                                } ,
                                child: const Text(
                                  "⚠️ Geek Score Calculation ⚠️",
                                  style: TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 12,
                                      color: white),
                                ),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "Your Geek Score is calculated by measuring \n"
                                    "the ratio of rejected and approved tasks \n"
                                    "of projects you collaborate on.\n"
                                    "This takes into account team work as all\n"
                                    "task approval does not depend on you alone.\n"
                                    "Team work is one of the key values \nRGT promotes.",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 10,
                                    color: white),
                              ),
                            ],
                          ),
                          GestureDetector(
                            onTap: () {
                              showModalBottomSheet(
                                context: context,
                                elevation: 10,
                                isDismissible: true,
                                enableDrag: true,
                                showDragHandle: true,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(30.0),
                                ),
                                builder: (BuildContext context) {
                                  // UDE : SizedBox instead of Container for whitespaces
                                  return  Center(
                                    child: Padding(
                                      padding: const EdgeInsets.all(15),
                                      child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.center,
                                      children: [
                                        const Text(
                                          "Contact Abdul Razak Abubakari for support",
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontWeight: FontWeight.bold,
                                              color: primary),
                                        ),
                                        const SizedBox(
                                          height: 50,
                                        ),

                                        const Text(
                                          "abubakari@reallygreattech.com",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: black),
                                        ),
                                        const Text(
                                          "ubdoolrazak@gmail.com",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: black),
                                        ),
                                        const Text(
                                          "0551678559",
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold,
                                              color: black),
                                        ),

                                        const SizedBox(
                                          height: 50,
                                        ),
                                        richText(24),
                                        const SizedBox(height: 20),
                                        Image.asset("assets/logo.png", height: 100, width: 100, ),
                                      ],
                                                                        ),
                                    ),
                                  );
                                },
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: white)),
                              child: Padding(
                                padding: const EdgeInsets.all(13.0),
                                child: Text(
                                  "Help",
                                  style: TextStyle(color: white),
                                ),
                              ),
                            ),
                          )
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ),
          SizedBox(height: 50),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Center(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  richText(24),
                  SizedBox(height: 20),
                  Image.asset("assets/logo.png",  ),

                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
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
            fontWeight: FontWeight.w900,
          ),
        ),
        TextSpan(
          text: 'PULSE',
          style: TextStyle(
            color: Color(0xFFFE9879),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
