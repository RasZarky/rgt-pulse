import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:link_text/link_text.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../theme/colors.dart';
import 'package:timeago/timeago.dart' as timeago;

class TaskDetailsPage extends StatefulWidget {
  final String projectName;
  final String taskName;
  final String tasktId;

  TaskDetailsPage({
    required this.projectName,
    required this.taskName,
    required this.tasktId,
  });

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  List<dynamic> activities = [];
  bool loading = true;
  Map<String, dynamic>? matchedTask;
  List<dynamic> collaborators = [];

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  String _formatDate(var dateStr) {
    if (dateStr.isEmpty) return "";
    try {
      var lastUpdatedDate = dateStr;
      if (lastUpdatedDate is String) {
        return timeago.format(DateTime.parse(lastUpdatedDate));
      } else if (lastUpdatedDate is int) {
        return timeago.format(DateTime.fromMillisecondsSinceEpoch(lastUpdatedDate)).toString();
      }
        } catch (e) {
      return "not available";
    }

    try {
      DateTime dateTime = DateTime.parse(dateStr);
      return DateFormat('dd MMM yy').format(dateTime);
    } catch (e) {
      return ""; // Handle parsing error if needed
    }
  }

  Future<void> _loadActivities() async {
    // Load JSON from file
    String jsonString =
    await rootBundle.loadString('assets/jesse.task_activities.json');
    List<dynamic> jsonData = json.decode(jsonString);

    // Find the task with the matching tasktId
    for (var task in jsonData) {
      if (task['_id']["\$oid"] == widget.tasktId) {
        matchedTask = task; // Save the entire task
        activities = task['activities'] ?? []; // Save the activities list
        collaborators = task['current']['collaborators'] ?? []; // Save the collaborators list
        break;
      }
    }

    // Sort activities by date
    activities.sort((a, b) {
      DateTime dateA = DateTime.parse(a['date']['\$date']);
      DateTime dateB = DateTime.parse(b['date']['\$date']);
      return dateB.compareTo(dateA); // Sort descending
    });

    setState(() {
      loading = false;
    });
  }

  void _showMoreInfoDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // Extract due date and estimate from the matchedTask
        var dueDate = matchedTask?['current']['due_date'] != null
            ? _formatDate(matchedTask!['current']['due_date'].toString())
            : "N/A";
        String estimate = matchedTask?['current']['estimate'] ?? "N/A";
        String sprint = matchedTask?['sprint']['name'] ?? "N/A";

        return AlertDialog(
          title: const Text('More Task Details',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: black),
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Due Date: $dueDate'),
              SizedBox(height: 10),
              Text('Estimated Time: $estimate'),
              SizedBox(height: 10),
              Text('Sprint: $sprint'),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Close'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    var color = matchedTask?['current']['status']['color'];
    var newColorCode = color != null
        ? Color(int.tryParse(color.replaceFirst('#', '0xFF')) ?? primary.value)
        : primary;

    // Handle the "last_updated" field
    String lastUpdated = "loading";
    try {
      if (matchedTask?["last_updated"] != null) {
        var lastUpdatedDate = matchedTask!["last_updated"]["\$date"];
        if (lastUpdatedDate is String) {
          lastUpdated = timeago.format(DateTime.parse(lastUpdatedDate));
        } else if (lastUpdatedDate is int) {
          lastUpdated = timeago.format(DateTime.fromMillisecondsSinceEpoch(lastUpdatedDate));
        }
      } else {
        lastUpdated = "not available";
      }
    } catch (e) {
      lastUpdated = "not available";
    }

    return Scaffold(
      body: OverlayLoaderWithAppIcon(
        isLoading: loading,
        overlayOpacity: 0.7,
        appIconSize: 50,
        circularProgressColor: Colors.purple,
        overlayBackgroundColor: Colors.black,
        appIcon: Image.asset("assets/logo.png"),
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
                    top: 60, right: 20, left: 20, bottom: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const BackButton(),
                        Text(
                          widget.projectName,
                          style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                              color: black),
                        ),
                        IconButton(
                          icon: Icon(Icons.more_vert),
                          onPressed: _showMoreInfoDialog,
                        )
                      ],
                    ),
                    Text(
                      widget.taskName,
                      style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: black),
                    ),
                    const SizedBox(height: 10),
                    LinkText(
                      "Task link ${matchedTask?["current"]["web_url"]}",
                      textAlign: TextAlign.center,
                      onLinkTap: (url) {
                        if (matchedTask?["current"]["web_url"] != null) {
                          launchUrl(Uri.parse(matchedTask?["current"]["web_url"]));
                        }
                      },
                    ),
                    const SizedBox(height: 10),
                    Text(
                      "Last updated: $lastUpdated",
                      style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.bold,
                          color: black),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: newColorCode,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            matchedTask?['current']['status']['status'] ?? "",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: white,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.symmetric(horizontal: 5),
                          padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                          decoration: BoxDecoration(
                            color: primary,
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: Text(
                            "Priority: ${matchedTask?['current']['priority'] ?? "N/A"}",
                            style: const TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: white,
                            ),
                          ),
                        )
                      ],
                    ),
                    const SizedBox(height: 10),
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: List.generate(collaborators.length, (index) {
                          String username = collaborators[index]['username'];
                          String email = collaborators[index]['email'];
                          String colorCode =
                              collaborators[index]['color'] ?? "0xFF43aa8b";

                          // Parse the color string into a Color object
                          Color bgColor = Color(
                              int.parse(colorCode.replaceFirst('#', '0xFF')));

                          return Container(
                            margin: EdgeInsets.symmetric(horizontal: 5),
                            padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(
                              color: bgColor,
                              borderRadius: BorderRadius.circular(5),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  username,
                                  style: const TextStyle(
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: white,
                                  ),
                                ),
                                Text(
                                  email,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    color: white,
                                  ),
                                ),
                              ],
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
                itemCount: activities.length,
                itemBuilder: (context, index) {
                  var activity = activities[index];
                  var eventDate = DateTime.parse(activity['date']['\$date']);
                  var formattedDate = timeago.format(eventDate);

                  return TimelineTile(
                    alignment: TimelineAlign.manual,
                    lineXY: 0.1,
                    isFirst: index == 0,
                    isLast: index == activities.length - 1,
                    indicatorStyle: IndicatorStyle(
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
                            'Event: ${activity['event'] ?? "N/A"}',
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Updated by: ${activity['update_by'] ?? "N/A"}',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 5),
                          Text(
                            'Date: $formattedDate',
                            style: const TextStyle(color: Colors.grey),
                          ),
                          SizedBox(height: 5),
                          _buildActivityDetails(activity['update']),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityDetails(Map<String, dynamic> update) {
    List<Widget> details = [];

    update.forEach((key, value) {
      details.add(
        Text('$key: $value'),
      );
    });

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: details,
    );
  }
}
