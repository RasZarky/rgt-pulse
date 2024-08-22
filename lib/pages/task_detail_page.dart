import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

class TaskDetailsPage extends StatefulWidget {
  final String projectName;
  final String taskName;

  TaskDetailsPage({
    required this.projectName,
    required this.taskName,
  });

  @override
  _TaskDetailsPageState createState() => _TaskDetailsPageState();
}

class _TaskDetailsPageState extends State<TaskDetailsPage> {
  List<dynamic> activities = [];
  bool loading = true;

  @override
  void initState() {
    super.initState();
    _loadActivities();
  }

  // Load activities based on projectName and taskName
  Future<void> _loadActivities() async {
    // Load JSON from file (you can replace this with your own data fetching logic)
    String jsonString =
    await rootBundle.loadString('assets/jesse.task_activities.json');
    List<dynamic> jsonData = json.decode(jsonString);

    // Find the task with the matching projectName and taskName
    List<dynamic> filteredActivities = [];
    for (var task in jsonData) {
      if (task['current']['project'] == widget.projectName &&
          task['current']['name'] == widget.taskName) {
        filteredActivities = task['activities'];
        break;
      }
    }

    setState(() {
      activities = filteredActivities;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.projectName} - ${widget.taskName}'),
        backgroundColor: Colors.purple, // Use your primary color
      ),
      body: OverlayLoaderWithAppIcon(
        isLoading: loading,
        overlayOpacity: 0.7,
        appIconSize: 50,
        circularProgressColor: Colors.purple,
        overlayBackgroundColor: Colors.black,
        appIcon: Image.asset("assets/logo.png"),
        child: ListView.builder(
          itemCount: activities.length,
          itemBuilder: (context, index) {
            var activity = activities[index];
            return ListTile(
              title: Text(
                'Event: ${activity['event'] ?? "N/A"}',
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Updated by: ${activity['update_by'] ?? "N/A"}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  Text(
                    'Date: ${activity['date']['\$date'] ?? "N/A"}',
                    style: TextStyle(color: Colors.grey),
                  ),
                  SizedBox(height: 4),
                  _buildActivityDetails(activity['update']),
                ],
              ),
            );
          },
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
