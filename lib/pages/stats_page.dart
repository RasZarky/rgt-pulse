import 'dart:convert';
import 'package:animate_do/animate_do.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:intl/intl.dart';
import '../theme/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class StatsPage extends StatefulWidget {
  @override
  _StatsPageState createState() => _StatsPageState();
}

class _StatsPageState extends State<StatsPage> {
  int activeDay = 3;
  List<dynamic> tasks = [];
  bool loading = false;
  List<String> projectNames = [];
  String? userEmail;

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
    String jsonString =
        await rootBundle.loadString('assets/jesse.task_activities.json');
    List<dynamic> jsonData = json.decode(jsonString);

    // Parse data and filter based on the current user's email
    Set<String> uniqueProjectNames =
        {}; // Use a Set to avoid duplicate project names
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
      projectNames =
          uniqueProjectNames.toList(); // Convert Set to List for use in the UI
      loading = false;
    });
  }

  Map<String, int> getTaskCountByStatus(List<dynamic> tasks) {
    Map<String, int> statusCount = {};

    for (var task in tasks) {
      String status = task['current']['status']['status'];
      if (statusCount.containsKey(status)) {
        statusCount[status] = statusCount[status]! + 1;
      } else {
        statusCount[status] = 1;
      }
    }

    return statusCount;
  }

  Map<DateTime, int> getUpdatesOverTime(List<dynamic> tasks) {
    Map<DateTime, int> updatesCount = {};

    for (var task in tasks) {
      try {
        var lastUpdatedRaw = task['last_updated']['\$date'];
        if (lastUpdatedRaw != null && lastUpdatedRaw is String) {
          DateTime lastUpdated = DateTime.parse(lastUpdatedRaw);
          // Count the last_updated date
          updatesCount.update(lastUpdated, (count) => count + 1,
              ifAbsent: () => 1);
        }
      } catch (e) {
        print('Error parsing last_updated for task: ${task['current']}');
        print('Error: $e');
      }

      // Check and count the dates in the activities
      try {
        if (task['activities'] != null && task['activities'] is List) {
          for (var activity in task['activities']) {
            var activityDateRaw = activity['date']['\$date'];
            if (activityDateRaw != null && activityDateRaw is String) {
              DateTime activityDate = DateTime.parse(activityDateRaw);
              updatesCount.update(activityDate, (count) => count + 1,
                  ifAbsent: () => 1);
            }
          }
        }
      } catch (e) {
        print('Error parsing activity date for task: ${task['current']}');
        print('Error: $e');
      }
    }

    return updatesCount;
  }

  Map<String, int> getTaskCountByPriority(List<dynamic> tasks) {
    Map<String, int> priorityCount = {};

    for (var task in tasks) {
      String priority = task['current']['priority'] ?? "N/A";
      if (priorityCount.containsKey(priority)) {
        priorityCount[priority] = priorityCount[priority]! + 1;
      } else {
        priorityCount[priority] = 1;
      }
    }

    return priorityCount;
  }

  Map<String, int> getAssignmentEvents(List<dynamic> tasks) {
    Map<String, int> eventCount = {
      'assignee_add': 0,
      'assignee_rem': 0,
    };

    for (var task in tasks) {
      try {
        if (task['activities'] != null && task['activities'] is List) {
          for (var activity in task['activities']) {
            var event = activity['event'];
            if (event != null && eventCount.containsKey(event)) {
              eventCount[event] = eventCount[event]! + 1;
            }
          }
        }
      } catch (e) {
        print('Error parsing event for task: ${task['current']}');
        print('Error: $e');
      }
    }

    return eventCount;
  }

  Map<String, int> getActivityTypes(List<dynamic> tasks) {
    Map<String, int> activityTypeCount = {};

    for (var task in tasks) {
      try {
        if (task['activities'] != null && task['activities'] is List) {
          for (var activity in task['activities']) {
            var eventType = activity['event'];
            if (eventType != null) {
              if (activityTypeCount.containsKey(eventType)) {
                activityTypeCount[eventType] =
                    activityTypeCount[eventType]! + 1;
              } else {
                activityTypeCount[eventType] = 1;
              }
            }
          }
        }
      } catch (e) {
        print('Error parsing event for task: ${task['current']}');
        print('Error: $e');
      }
    }

    return activityTypeCount;
  }

  Map<String, int> getTaskCountByProject(List<dynamic> tasks) {
    Map<String, int> projectCount = {};

    for (var task in tasks) {
      String project = task['current']['project'] ?? "Unknown";
      if (projectCount.containsKey(project)) {
        projectCount[project] = projectCount[project]! + 1;
      } else {
        projectCount[project] = 1;
      }
    }

    return projectCount;
  }

  @override
  void initState() {
    super.initState();
    _getUserEmail();
    _loadTaskActivities();
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
        child: getBody(),
      ),
    );
  }

  Widget getBody() {
    var size = MediaQuery.of(context).size;

    final taskCountByStatus = getTaskCountByStatus(tasks);
    final updatesOverTime = getUpdatesOverTime(tasks);
    final taskCountByPriority = getTaskCountByPriority(tasks);
    final assignmentEvents = getAssignmentEvents(tasks);
    final activityTypes = getActivityTypes(tasks);
    final taskCountByProject = getTaskCountByProject(tasks);

    // Calculate total counts
    final totalTasks = tasks.length;
    final totalUpdates = updatesOverTime.values.fold(0, (a, b) => a + b);
    final totalAssignmentEvents =
        assignmentEvents.values.fold(0, (a, b) => a + b);
    final totalActivityTypes = activityTypes.values.fold(0, (a, b) => a + b);

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
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Image.asset("assets/logo.png", height: 70, width: 70),
                      const Text(
                        "My Projects Stats",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                      Icon(Icons.filter_alt)
                    ],
                  ),
                  const SizedBox(
                    height: 0,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        '⚠️ Below are stats of projects you collaborated on.',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Total Projects Count: ${projectNames.length}',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total Tasks: $totalTasks',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total Updates Over Time: $totalUpdates',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total Assignment Event: $totalAssignmentEvents',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Total Activity Count: $totalActivityTypes',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      const Text(
                        '⚠️ Tap on line or bar chart for more info',
                        style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(
            height: 10,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: grey.withOpacity(0.01),
                      spreadRadius: 10,
                      blurRadius: 3,
                    ),
                  ]),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Task Count by Status",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: black),
                        ),
                        GestureDetector(
                          onTap: () {
                            showBottomSheet(
                              "Task Count by Status",
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      taskCountByStatus.length, (index) {
                                    return FadeInUp(
                                      child: Padding(
                                        padding:
                                            const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: double.infinity, // Full width
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(.4),
                                            borderRadius:
                                                BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.01),
                                                spreadRadius: 10,
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 20),
                                                Column(
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      taskCountByStatus.keys
                                                          .elementAt(index),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      "${
                                                        taskCountByStatus.values
                                                            .elementAt(index)
                                                            .toString()
                                                      } tasks",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                            FontWeight.w500,
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
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
                            );
                          },
                          child: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    const SizedBox(height: 30),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: taskCountByStatus.entries
                                  .toList() // Convert entries to a list
                                  .asMap()
                                  .entries
                                  .map((entry) => FlSpot(entry.key.toDouble(),
                                      entry.value.value.toDouble()))
                                  .toList(),
                              isCurved: true,
                              color: primary,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(show: true),
                            ),
                          ],
                          borderData: FlBorderData(
                            show: false,
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          titlesData: const FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  reservedSize: 44, showTitles: true),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  reservedSize: 44, showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  reservedSize: 44, showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  reservedSize: 44, showTitles: false),
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems:
                                  (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((lineBarSpot) {
                                  final index = lineBarSpot.spotIndex.toInt();
                                  final status =
                                      taskCountByStatus.keys.elementAt(index);
                                  final count = taskCountByStatus[status];
                                  return LineTooltipItem(
                                    '$status\nCount: $count',
                                    TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            touchSpotThreshold: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // Add the new time series chart for Task Updates Over Time
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              width: double.infinity,
              height: 300,
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: grey.withOpacity(0.01),
                      spreadRadius: 10,
                      blurRadius: 3,
                    ),
                  ]),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Task Updates Over Time",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: black),
                        ),
                        GestureDetector(
                          onTap: () {
                            showBottomSheet(
                              "Task Updates Over Time",
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      updatesOverTime.length, (index) {
                                    return FadeInUp(
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: double.infinity, // Full width
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(.4),
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.01),
                                                spreadRadius: 10,
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 20),
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      timeago.format(updatesOverTime.keys
                                                          .elementAt(index))
                                                      ,
                                                      style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      "${
                                                          updatesOverTime.values
                                                              .elementAt(index)
                                                              .toString()
                                                      } tasks",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
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
                            );
                          },
                          child: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: LineChart(
                        LineChartData(
                          lineBarsData: [
                            LineChartBarData(
                              spots: updatesOverTime.entries
                                  .toList() // Convert entries to a list
                                  .map((entry) => FlSpot(
                                      entry.key.millisecondsSinceEpoch
                                          .toDouble(),
                                      entry.value.toDouble()))
                                  .toList(),
                              isCurved: true,
                              color: Colors.blue,
                              barWidth: 4,
                              isStrokeCapRound: true,
                              dotData: FlDotData(show: true),
                              belowBarData: BarAreaData(show: true),
                            ),
                          ],
                          borderData: FlBorderData(
                            show: false,
                            border: Border.all(color: Colors.grey, width: 1),
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  reservedSize: 44, showTitles: true),
                            ),
                            rightTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  reservedSize: 44, showTitles: false),
                            ),
                            topTitles: AxisTitles(
                              sideTitles: SideTitles(
                                  reservedSize: 44, showTitles: false),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 44,
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  DateTime date =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          value.toInt());
                                  return Text(
                                    DateFormat('MM/dd').format(date),
                                    style:
                                        TextStyle(color: black, fontSize: 10),
                                  );
                                },
                              ),
                            ),
                          ),
                          lineTouchData: LineTouchData(
                            touchTooltipData: LineTouchTooltipData(
                              getTooltipItems:
                                  (List<LineBarSpot> touchedBarSpots) {
                                return touchedBarSpots.map((lineBarSpot) {
                                  final date =
                                      DateTime.fromMillisecondsSinceEpoch(
                                          lineBarSpot.x.toInt());
                                  final formattedDate =
                                      DateFormat('MM/dd/yyyy').format(date);
                                  return LineTooltipItem(
                                    '$formattedDate\nUpdates: ${lineBarSpot.y.toInt()}',
                                    TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  );
                                }).toList();
                              },
                            ),
                            touchSpotThreshold: 10,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // Add the new chart for Task Prioritization
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              width: double.infinity,
              height: 300, // Height to accommodate the pie chart
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: grey.withOpacity(0.01),
                      spreadRadius: 10,
                      blurRadius: 3,
                    ),
                  ]),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Task Prioritization",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: black),
                        ),
                        GestureDetector(
                          onTap: () {
                            showBottomSheet(
                              "Task Prioritization",
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      taskCountByPriority.length, (index) {
                                    return FadeInUp(
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: double.infinity, // Full width
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(.4),
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.01),
                                                spreadRadius: 10,
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 20),
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      taskCountByPriority.keys
                                                          .elementAt(index),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      "${
                                                          taskCountByPriority.values
                                                              .elementAt(index)
                                                              .toString()
                                                      } tasks",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
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
                            );
                          },
                          child: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 20,
                          sections: getPieChartSections(taskCountByPriority),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),
          // Add the new bar chart for Task Assignment Events
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              width: double.infinity,
              height: 300, // Height to accommodate the bar chart
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: grey.withOpacity(0.01),
                      spreadRadius: 10,
                      blurRadius: 3,
                    ),
                  ]),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Task Assignment Events",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: black),
                        ),
                        GestureDetector(
                          onTap: () {
                            showBottomSheet(
                              "Task Assignment Events",
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      assignmentEvents.length, (index) {
                                    return FadeInUp(
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: double.infinity, // Full width
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(.4),
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.01),
                                                spreadRadius: 10,
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 20),
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      assignmentEvents.keys
                                                          .elementAt(index),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      "${
                                                          assignmentEvents.values
                                                              .elementAt(index)
                                                              .toString()
                                                      } tasks",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
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
                            );
                          },
                          child: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          barGroups: [
                            BarChartGroupData(
                              x: 0,
                              barRods: [
                                BarChartRodData(
                                  toY: assignmentEvents['assignee_add']
                                          ?.toDouble() ??
                                      0,
                                  color: Colors.green,
                                  width: 20,
                                  borderRadius: BorderRadius.zero,
                                ),
                              ],
                            ),
                            BarChartGroupData(
                              x: 1,
                              barRods: [
                                BarChartRodData(
                                  toY: assignmentEvents['assignee_rem']
                                          ?.toDouble() ??
                                      0,
                                  color: Colors.red,
                                  width: 20,
                                  borderRadius: BorderRadius.zero,
                                ),
                              ],
                            ),
                          ],
                          borderData: FlBorderData(
                            show: false,
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 40,
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                        color: black, fontSize: 14),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 40,
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  String title = value.toInt() == 0
                                      ? 'Add Assignee '
                                      : ' Remove Assignee';
                                  return Text(
                                    title,
                                    style: const TextStyle(
                                        color: black, fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 40,
                                showTitles: false,
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 40,
                                showTitles: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          SizedBox(
            height: 20,
          ),

          // Add the new chart for Activity types
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              width: double.infinity,
              height: 300, // Height to accommodate the pie chart
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: grey.withOpacity(0.01),
                      spreadRadius: 10,
                      blurRadius: 3,
                    ),
                  ]),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Activity Types",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: black),
                        ),
                        GestureDetector(
                          onTap: () {
                            showBottomSheet(
                              "Activity Types",
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      activityTypes.length, (index) {
                                    return FadeInUp(
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: double.infinity, // Full width
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(.4),
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.01),
                                                spreadRadius: 10,
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 20),
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      activityTypes.keys
                                                          .elementAt(index),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      "${
                                                          activityTypes.values
                                                              .elementAt(index)
                                                              .toString()
                                                      } tasks",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
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
                            );
                          },
                          child: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: PieChart(
                        PieChartData(
                          sectionsSpace: 0,
                          centerSpaceRadius: 20,
                          sections: getPieChartSections(activityTypes),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.only(left: 20, right: 20),
            child: Container(
              width: double.infinity,
              height: 300, // Height to accommodate the bar chart
              decoration: BoxDecoration(
                  color: white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [
                    BoxShadow(
                      color: grey.withOpacity(0.01),
                      spreadRadius: 10,
                      blurRadius: 3,
                    ),
                  ]),
              child: Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text(
                          "Project-Specific Task Distribution",
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 16,
                              color: black),
                        ),
                        GestureDetector(
                          onTap: () {
                            showBottomSheet(
                              "Project-Specific Task Distribution",
                              Padding(
                                padding:
                                const EdgeInsets.symmetric(horizontal: 20),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: List.generate(
                                      getTaskCountByProject(tasks).length, (index) {
                                    return FadeInUp(
                                      child: Padding(
                                        padding:
                                        const EdgeInsets.only(bottom: 10),
                                        child: Container(
                                          width: double.infinity, // Full width
                                          decoration: BoxDecoration(
                                            color: primary.withOpacity(.4),
                                            borderRadius:
                                            BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey
                                                    .withOpacity(0.01),
                                                spreadRadius: 10,
                                                blurRadius: 3,
                                              ),
                                            ],
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(5),
                                            child: Row(
                                              children: [
                                                const SizedBox(width: 20),
                                                Column(
                                                  crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      getTaskCountByProject(tasks).keys
                                                          .elementAt(index),
                                                      style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.bold,
                                                        fontSize: 16,
                                                        color: Colors.black,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      "${
                                                          getTaskCountByProject(tasks).values
                                                              .elementAt(index)
                                                              .toString()
                                                      } tasks",
                                                      style: const TextStyle(
                                                        fontWeight:
                                                        FontWeight.w500,
                                                        fontSize: 14,
                                                        color: Colors.white,
                                                      ),
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
                            );
                          },
                          child: const Icon(Icons.more_vert),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Expanded(
                      child: BarChart(
                        BarChartData(
                          barGroups:
                              getBarChartGroups(getTaskCountByProject(tasks)),
                          borderData: FlBorderData(
                            show: false,
                          ),
                          titlesData: FlTitlesData(
                            leftTitles: AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 40,
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  return Text(
                                    value.toInt().toString(),
                                    style: const TextStyle(
                                        color: black, fontSize: 14),
                                  );
                                },
                              ),
                            ),
                            bottomTitles: AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 40,
                                showTitles: true,
                                getTitlesWidget: (value, meta) {
                                  final projectName =
                                      getTaskCountByProject(tasks)
                                          .keys
                                          .toList()[value.toInt()];
                                  return Text(
                                    projectName,
                                    style: const TextStyle(
                                        color: black, fontSize: 10),
                                  );
                                },
                              ),
                            ),
                            topTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 40,
                                showTitles: false,
                              ),
                            ),
                            rightTitles: const AxisTitles(
                              sideTitles: SideTitles(
                                reservedSize: 40,
                                showTitles: false,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(
            height: 20,
          ),
        ],
      ),
    );
  }

  void showBottomSheet(String title, Widget widget) {
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
        return FractionallySizedBox(
          heightFactor: 1, // Adjusts the height of the bottom sheet
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                title,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: primary,
                ),
              ),
              const SizedBox(height: 10),
              Expanded(
                child: SingleChildScrollView(
                  child: widget,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  List<PieChartSectionData> getPieChartSections(
      Map<String, int> priorityCount) {
    List<PieChartSectionData> sections = [];
    final total = priorityCount.values.reduce((a, b) => a + b);
    final colors = [
      Colors.red,
      Colors.orange,
      blue,
      Colors.green,
      Colors.blue,
      green,
      Colors.brown,
      primary
    ];
    int colorIndex = 0;

    priorityCount.forEach((priority, count) {
      sections.add(
        PieChartSectionData(
          color: colors[colorIndex % colors.length],
          value: count.toDouble(),
          radius: 80,
          titlePositionPercentageOffset: 1.1,
          title:
              '$priority\n${(count / total * 100).toStringAsFixed(1)}% \n${(count.toString())}',
          titleStyle: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.black,
          ),
        ),
      );
      colorIndex++;
    });

    return sections;
  }
}

List<BarChartGroupData> getBarChartGroups(Map<String, int> projectCount) {
  List<BarChartGroupData> barGroups = [];
  final colors = [
    Colors.red,
    Colors.orange,
    blue,
    Colors.green,
    Colors.blue,
    green,
    Colors.brown,
    primary
  ];
  int colorIndex = 0;

  projectCount.forEach((project, count) {
    barGroups.add(
      BarChartGroupData(
        x: barGroups.length, // X position of the bar group
        barRods: [
          BarChartRodData(
            toY: count.toDouble(),
            color: colors[colorIndex % colors.length],
            width: 20,
            borderRadius: BorderRadius.zero,
          ),
        ],
      ),
    );
    colorIndex++;
  });

  return barGroups;
}
