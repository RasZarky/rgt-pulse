import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:rgt_pulse/pages/all_stats_page.dart';
import 'package:rgt_pulse/pages/collaborators_page.dart';
import 'package:rgt_pulse/pages/leaderboard_page.dart';
import 'package:rgt_pulse/pages/search_page.dart';
import 'package:rgt_pulse/pages/task_detail_page.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../theme/colors.dart';
import 'ai.dart';

class AllPage extends StatefulWidget {
  @override
  _AllPageState createState() => _AllPageState();
}

class _AllPageState extends State<AllPage> {
  int activeProject = -1;
  List<dynamic> tasks = [];
  bool loading = false;
  List<String> projectNames = [];

  @override
  void initState() {
    super.initState();
    _loadTaskActivities();
  }

  Future<void> _loadTaskActivities() async {
    setState(() {
      loading = true;
    });

    String jsonString = await rootBundle.loadString('assets/jesse.task_activities.json');
    List<dynamic> jsonData = json.decode(jsonString);

    Set<String> uniqueProjectNames = {};
    List<dynamic> filteredTasks = [];

    jsonData.forEach((task) {
      var current = task['current'];
      filteredTasks.add(task);
      uniqueProjectNames.add(current['project']);
    });

    setState(() {
      tasks = filteredTasks;
      projectNames = uniqueProjectNames.toList();
      loading = false;
    });
  }

  List<dynamic> _getFilteredTasks() {
    if (activeProject == -1) {
      return tasks;
    } else {
      String selectedProject = projectNames[activeProject];
      return tasks.where((task) => task['current']['project'] == selectedProject).toList();
    }
  }

  void _showGridMenu() {
    showModalBottomSheet(
      context: context,
      elevation: 10,
      isDismissible: true,
      enableDrag: true,
      showDragHandle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(30.0),
      ),
      builder: (context) {
        return Container(
          padding: EdgeInsets.all(20),
          child: GridView.count(
            crossAxisCount: 3, // Number of columns in the grid
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            children: [
              _buildGridMenuItem(Icons.multiline_chart, 'Stats', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => AllStatsPage() ));
                // Handle Project Info action
              }),
              _buildGridMenuItem(Icons.supervised_user_circle_outlined, 'Collaborators', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => CollaboratorsPage() ));
                // Handle Filter Tasks action
              }),
              _buildGridMenuItem(Icons.android, 'AI', () {
                Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(title: 'Chat with Ai',) ) );
                // Handle Settings action
              }),
              // _buildGridMenuItem(Icons.notifications, 'Notifications', () {
              //   Navigator.pop(context);
              //   // Handle Notifications action
              // }),
              // _buildGridMenuItem(Icons.share, 'Share', () {
              //   Navigator.pop(context);
              //   // Handle Share action
              // }),
              // _buildGridMenuItem(Icons.exit_to_app, 'Logout', () {
              //   Navigator.pop(context);
              //   // Handle Logout action
              // }),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGridMenuItem(IconData icon, String label, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40, color: primary),
          SizedBox(height: 10),
          Text(
            label,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: black,
            ),
          ),
        ],
      ),
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
        child: _buildProjectTimeline(),
      ),
    );
  }

  Widget _buildProjectTimeline() {
    List<dynamic> filteredTasks = _getFilteredTasks();

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
            padding: const EdgeInsets.only(top: 30, right: 20, left: 20, bottom: 25),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Image.asset("assets/logo.png", height: 70, width: 70),
                    const Text(
                      "All RGT Projects",
                      style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: black),
                    ),
                    Row(
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => SearchPage(tasks: filteredTasks)));
                          },
                          child: const Icon(Icons.search),
                        ),
                        const SizedBox(width: 20),
                        GestureDetector(
                          onTap: _showGridMenu,
                          child: Icon(Icons.more_vert),
                        ),
                      ],
                    )
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
              var color = task['current']['status']['color'];
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
                            color: newColorCode,
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
                        ),
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
