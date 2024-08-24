import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:rgt_pulse/theme/colors.dart';

class CollaboratorsPage extends StatefulWidget {
  @override
  _CollaboratorsPageState createState() => _CollaboratorsPageState();
}

class _CollaboratorsPageState extends State<CollaboratorsPage> {
  bool loading = true;
  List<Map<String, dynamic>> leaderboardData = [];

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    setState(() {
      loading = true;
    });

    // Load JSON from file
    String jsonString = await rootBundle.loadString('assets/jesse.task_activities.json');
    List<dynamic> jsonData = json.decode(jsonString);

    // Dictionary to store user data and tasks
    Map<int, Map<String, dynamic>> userMap = {};

    for (var task in jsonData) {
      var current = task['current'];
      var collaborators = current['collaborators'];

      for (var collaborator in collaborators) {
        int userId = collaborator['id'];
        String userName = collaborator['username'];
        String? userPic = collaborator['profilePicture'];
        String userEmail = collaborator['email'];
        String? userColor = collaborator['color']; // Retrieve user color

        // Debugging: Print the retrieved color
        print("User: $userName, Color: $userColor");

        if (!userMap.containsKey(userId)) {
          userMap[userId] = {
            'id': userId,
            'username': userName,
            'profilePicture': userPic,
            'email': userEmail,
            'color': userColor, // Store user color
            'tasks': [],
          };
        }
        userMap[userId]?['tasks'].add(current);
      }
    }

    // Calculate geek scores
    List<Map<String, dynamic>> userList = [];
    userMap.forEach((userId, userData) {
      int totalTasks = userData['tasks'].length;
      int tasksWithoutSpecifiedStatus = 0;

      for (var task in userData['tasks']) {
        String status = task['status']['status'];
        if (status != 'to do' && status != 'in progress' && status != 'reject') {
          tasksWithoutSpecifiedStatus++;
        }
      }

      double geekScore = totalTasks > 0
          ? (tasksWithoutSpecifiedStatus / totalTasks) * 100
          : 0;

      userList.add({
        'id': userData['id'],
        'username': userData['username'],
        'profilePicture': userData['profilePicture'],
        'color': userData['color'], // Include user color
        'email': userData['email'],
        'geekScore': geekScore,
        'taskCount': totalTasks,
      });
    });

    // Sort by geek score
    userList.sort((a, b) => b['geekScore'].compareTo(a['geekScore']));

    setState(() {
      leaderboardData = userList;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white.withOpacity(0.7),
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
    return SingleChildScrollView(
      child: Column(
        children: [
          Container(
            decoration: BoxDecoration(color: white, boxShadow: [
              BoxShadow(
                color: grey.withOpacity(0.01),
                spreadRadius: 10,
                blurRadius: 3,
              ),
            ]),
            child: Padding(
              padding: const EdgeInsets.only(
                  top: 30, right: 20, left: 20, bottom: 10),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const BackButton(),
                      const Text(
                        "Project Collaborators",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                      Image.asset("assets/logo.png", height: 70, width: 70),
                    ],
                  ),
                  Text(
                    '${leaderboardData.length} collaborators',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(leaderboardData.length, (index) {
                String? colorHex = leaderboardData[index]['color'];
                Color containerColor = colorHex != null
                    ? Color(int.parse(colorHex.replaceAll('#', '0xff')))
                    : green; // Fallback color if null

                return FadeInUp(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: Container(
                      decoration: BoxDecoration(
                        color: containerColor, // Use retrieved color
                        borderRadius: BorderRadius.circular(12),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.01),
                            spreadRadius: 10,
                            blurRadius: 3,
                          ),
                        ],
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(25),
                        child: Row(
                          children: [
                            const SizedBox(width: 10),
                            CircleAvatar(
                              backgroundImage: leaderboardData[index]['profilePicture'] != null
                                  ? NetworkImage(leaderboardData[index]['profilePicture'])
                                  : const AssetImage("assets/images/profile.jpg"),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  leaderboardData[index]['username'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  leaderboardData[index]['email'],
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: true,
                                  style: const TextStyle(
                                    overflow: TextOverflow.ellipsis,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Geek Score: ${leaderboardData[index]['geekScore'].toStringAsFixed(2)}%',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Text(
                                  'Tasks Count: ${leaderboardData[index]['taskCount']}',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                )
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                );
              }),
            ),
          ),
        ],
      ),
    );
  }
}
