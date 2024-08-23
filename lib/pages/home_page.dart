import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:rgt_pulse/pages/task_detail_page.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../theme/colors.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  int activeProject = -1;
  String? userEmail;
  List<dynamic> tasks = [];
  bool loading = false;
  List<String> projectNames = [];

  @override
  void initState() {
    super.initState();
    _getUserEmail();
    _loadTaskActivities();
  }

  // Get current user's email from FirebaseAuth
  void _getUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email;
    });
  }

  Future<void> _loadTaskActivities() async {
    setState(() {
      loading = true;
    });

    // Load JSON from file
    String jsonString = await rootBundle.loadString('assets/jesse.task_activities.json');
    List<dynamic> jsonData = json.decode(jsonString);

    // Parse data and filter based on the current user's email
    Set<String> uniqueProjectNames = {};  // Use a Set to avoid duplicate project names
    List<dynamic> filteredTasks = [];

    jsonData.forEach((task) {
      var current = task['current'];

      // Filter tasks for the logged-in user based on email
      bool isCollaborator = current['collaborators']
          .any((collaborator) => collaborator['email'] == userEmail);

      if (isCollaborator) {
        filteredTasks.add(task);

        // Add the project name to the Set if the user is a collaborator
        uniqueProjectNames.add(current['project']);
      }
    });

    setState(() {
      tasks = filteredTasks;
      projectNames = uniqueProjectNames.toList();  // Convert Set to List for use in the UI
      loading = false;
    });
  }

  List<dynamic> _getFilteredTasks() {
    if (activeProject == -1) {
      // If "All" is selected, return all tasks
      return tasks;
    } else {
      // Otherwise, return tasks for the selected project only
      String selectedProject = projectNames[activeProject];
      return tasks.where((task) => task['current']['project'] == selectedProject).toList();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: grey.withOpacity(0.05),
      body: loading ? _buildLoading() : _buildProjectTimeline(),
    );
  }

  Widget _buildLoading() {
    return Center(
      child: OverlayLoaderWithAppIcon(
        isLoading: loading,
        overlayOpacity: 0.7,
        appIconSize: 50,
        circularProgressColor: Colors.purple,
        overlayBackgroundColor: Colors.black,
        appIcon: Image.asset("assets/logo.png"),
        child: Container(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
        ),
      ),
    );
  }

  Widget _buildProjectTimeline() {
    List<dynamic> filteredTasks = _getFilteredTasks();  // Get filtered tasks based on selection

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
            padding: const EdgeInsets.only(top: 60, right: 20, left: 20, bottom: 25),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset("assets/logo.png", height: 50, width: 50),
                    const Text(
                      "MY Projects",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black),
                    ),
                    Icon(Icons.search)
                  ],
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

              ],
            ),
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: filteredTasks.length,
            itemBuilder: (context, index) {
              var task = filteredTasks[index];
              var projectName = task['current']['project'];
              var taskName = task['current']['name'];
              var status = task['current']['status']['status'];
              var color =  task['current']['status']['color'];
              var taskId = task['_id']["\$oid"];
              var newColorCode = Color(int.parse(color.replaceFirst('#', '0xFF')));

              return GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TaskDetailsPage(
                        projectName: projectName,
                        taskName: taskName,
                        tasktId: taskId,
                      ),
                    ),
                  );
                },
                child: TimelineTile(
                  alignment: TimelineAlign.manual,
                  lineXY: 0.1,
                  isFirst: index == 0,
                  isLast: index == filteredTasks.length - 1,
                  indicatorStyle: const IndicatorStyle(
                    width: 20,
                    color: primary,
                    padding: EdgeInsets.all(8),
                  ),
                  beforeLineStyle: LineStyle(
                    color: grey.withOpacity(0.5),
                    thickness: 2,
                  ),
                  endChild: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          projectName,
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: black,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          taskName,
                          style: TextStyle(
                            fontSize: 14,
                            color: black.withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 5),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: newColorCode ,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            status,
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: white,
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
