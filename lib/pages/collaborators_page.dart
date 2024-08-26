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
  List<String> projectNames = [];
  int activeProject = -1;

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
    Set<String> projectSet = {}; // To store unique project names

    for (var task in jsonData) {
      var current = task['current'];
      var projectName = current['project']; // Extract project name
      projectSet.add(projectName); // Add to set to ensure uniqueness

      var collaborators = current['collaborators'];

      for (var collaborator in collaborators) {
        int userId = collaborator['id'];
        String userName = collaborator['username'];
        String? userPic = collaborator['profilePicture'];
        String userEmail = collaborator['email'];
        String? userColor = collaborator['color']; // Retrieve user color

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

    // Convert project set to a list
    projectNames = projectSet.toList();

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
        'tasks': userData['tasks'], // Store tasks for filtering
      });
    });

    // Sort by geek score
    userList.sort((a, b) => b['geekScore'].compareTo(a['geekScore']));

    setState(() {
      leaderboardData = userList;
      loading = false;
    });
  }

  List<Map<String, dynamic>> _getFilteredCollaborators() {
    if (activeProject == -1) {
      return leaderboardData;
    } else {
      String selectedProject = projectNames[activeProject];
      return leaderboardData.where((collaborator) {
        return collaborator['tasks'].any((task) => task['project'] == selectedProject);
      }).toList();
    }
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
        child: getBody(),
      ),
    );
  }

  Widget getBody() {
    var filteredCollaborators = _getFilteredCollaborators();
    return Column(
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
                  '${filteredCollaborators.length} collaborators',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 25),
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: List.generate(projectNames.length + 1, (index) {
                      String displayName = index == 0 ? 'All' : projectNames[index - 1];
                      bool isActive = index == 0 ? activeProject == -1 : activeProject == index - 1;

                      return GestureDetector(
                        onTap: () {
                          setState(() {
                            activeProject = index == 0 ? -1 : index - 1;
                          });
                        },
                        child: Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: isActive ? primary : grey.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            displayName,
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: isActive ? white : black,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(
                  height: 0,
                ),
              ],
            ),
          ),
        ),
        Expanded(
          child: filteredCollaborators.isEmpty
              ? Image.asset("assets/images/noData.png", fit: BoxFit.cover,)
              : SingleChildScrollView(
            child: Column(
              children: [
                SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: List.generate(filteredCollaborators.length, (index) {
                      String? colorHex = filteredCollaborators[index]['color'];
                      Color containerColor = colorHex != null
                          ? Color(int.parse(colorHex.replaceAll('#', '0xff')))
                          : green; // Fallback color if null

                      return FadeInUp(
                        child: Padding(
                          padding: const EdgeInsets.only(bottom: 10),
                          child: Container(
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.surfaceContainerHighest, // Use retrieved color
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
                                    radius: 25,
                                    backgroundColor: containerColor,
                                    child: CircleAvatar(
                                      radius: 20,
                                      backgroundColor: containerColor,
                                      backgroundImage: filteredCollaborators[index]['profilePicture'] != null
                                          ? NetworkImage(filteredCollaborators[index]['profilePicture'])
                                          : const AssetImage("assets/images/profile.jpg"),
                                    ),
                                  ),
                                  const SizedBox(width: 20),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        filteredCollaborators[index]['username'],
                                        style: const TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 16,
                                          color: Colors.black,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Text(
                                        filteredCollaborators[index]['email'],
                                        overflow: TextOverflow.ellipsis,
                                        softWrap: true,
                                        style: const TextStyle(
                                          overflow: TextOverflow.ellipsis,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 14,
                                          color: Colors.black54,
                                        ),
                                      ),
                                      SizedBox(height: 5),
                                      Column(
                                        children: [
                                          Row(
                                            children: [
                                              Text(
                                                filteredCollaborators[index]['taskCount'].toString(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.black),
                                              ),
                                              const SizedBox(width: 5),
                                              const Text(
                                                "Tasks",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                    color: Colors.black),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 5),
                                          Row(
                                            children: [
                                              Text(
                                                "${filteredCollaborators[index]['geekScore'].toStringAsFixed(2)}%",
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold,
                                                    fontSize: 18,
                                                    color: Colors.green),
                                              ),
                                              const SizedBox(width: 5),
                                              const Text(
                                                "Geek",
                                                style: TextStyle(
                                                    fontWeight: FontWeight.w600,
                                                    fontSize: 12,
                                                    color: Colors.green),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
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
          ),
        ),
      ],
    );
  }
}
