import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';

class TaskListPage extends StatefulWidget {
  @override
  _TaskListPageState createState() => _TaskListPageState();
}

class _TaskListPageState extends State<TaskListPage> {
  List<dynamic> tasks = [];
  Set<String> projects = {};
  Set<String> statuses = {};
  Set<String> users = {};
  bool loading = false;

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {

    setState(() {
      loading = true;
    });
    // Load JSON from file
    String jsonString = await rootBundle.loadString('assets/jesse.task_activities.json');
    List<dynamic> jsonData = json.decode(jsonString);

    // Parse data
    jsonData.forEach((task) {
      var current = task['current'];
      var activities = task['activities'];

      // Collect unique projects, statuses, and users
      projects.add(current['project']);
      statuses.add(current['status']['status']);
      activities.forEach((activity) {
        users.add(activity['update_by']);
      });
    });

    setState(() {
      tasks = jsonData;
      loading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Task Activities'),
      ),
      body: OverlayLoaderWithAppIcon(
        isLoading: loading,
        overlayOpacity: 0.7,
        appIconSize: 50,
        circularProgressColor: Colors.purple,
        overlayBackgroundColor: Colors.black,
        appIcon: Image.asset("assets/logo.png"),
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Number of Tasks: ${tasks.length}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Number of Projects: ${projects.length}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                Text('Projects: ${projects.join(', ')}'),
                SizedBox(height: 10),
                Text('Possible Statuses: (${statuses.length}) ${statuses.join(', ')}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 10),
                Text('Users Involved: (${users.length}) ${users.join(', ')}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                SizedBox(height: 20),
                ListView.builder(
                  shrinkWrap: true,  // Add this line
                  physics: NeverScrollableScrollPhysics(),  // Add this line
                  itemCount: tasks.length,
                  itemBuilder: (context, index) {
                    var task = tasks[index];
                    return TaskCard(task: task);
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class TaskCard extends StatelessWidget {
  final Map<String, dynamic> task;

  TaskCard({required this.task});

  @override
  Widget build(BuildContext context) {
    var current = task['current'];
    var activities = task['activities'];
    var taskId = current['task_id'] ?? 'N/A';
    var collaborators = current['collaborators'] != null ? current['collaborators'].join(', ') : 'None';
    var webUrl = current['web_url'] ?? 'N/A';
    var priority = current['priority'] ?? 'Not Set';
    var description = current['description'] ?? 'No Description';

    return Card(
      margin: EdgeInsets.symmetric(vertical: 5.0),
      child: Padding(
        padding: EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              current['name'] ?? 'No Name',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 5.0),
            Text('Task ID: $taskId'),
            SizedBox(height: 5.0),
            Text('Status: ${current['status']['status']}'),
            SizedBox(height: 5.0),
            Text('Project: ${current['project']}'),
            SizedBox(height: 5.0),
            Text('Priority: $priority'),
            SizedBox(height: 5.0),
            Text('Collaborators: $collaborators'),
            SizedBox(height: 5.0),
            Text('Description: $description'),
            SizedBox(height: 5.0),
            if (webUrl != 'N/A')
              Text('Web URL: $webUrl', style: TextStyle(color: Colors.blue)),
            SizedBox(height: 10.0),
            const Text(
              'Activities:',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            ...activities.map<Widget>((activity) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4.0),
                child: Text('${activity['date']['\$date']}: ${activity['event']} by ${activity['update_by']}'),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
