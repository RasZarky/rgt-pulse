import 'package:animate_do/animate_do.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:rgt_pulse/theme/colors.dart';

class LeaderboardPage extends StatefulWidget {
  @override
  _LeaderboardPageState createState() => _LeaderboardPageState();
}

class _LeaderboardPageState extends State<LeaderboardPage> {
  bool loading = true;
  List<Map<String, dynamic>> leaderboardData = [];
  List<Map<String, dynamic>> filteredData = []; // Added to store filtered data
  TextEditingController searchController = TextEditingController(); // Added to control search input

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
        String? userColor = collaborator['color']; // Retrieve user color

        if (!userMap.containsKey(userId)) {
          userMap[userId] = {
            'id': userId,
            'username': userName,
            'profilePicture': userPic,
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
        'geekScore': geekScore,
      });
    });

    // Sort by geek score
    userList.sort((a, b) => b['geekScore'].compareTo(a['geekScore']));

    setState(() {
      leaderboardData = userList;
      filteredData = userList; // Initialize filteredData with full list
      loading = false;
    });
  }

  void _filterTasks(String query) {
    setState(() {
      filteredData = leaderboardData.where((user) {
        String username = user['username'].toLowerCase();
        String id = user['id'].toString();
        String geekScore = user['geekScore'].toStringAsFixed(2);
        return username.contains(query.toLowerCase()) ||
            id.contains(query) ||
            geekScore.contains(query);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey.withOpacity(0.05),
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
                        "LEADERBOARD",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                      Icon(Icons.wine_bar)
                    ],
                  ),
                  const SizedBox(height: 10),
                  const Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        '⚠️ Only users who are collaborators on tasks appear on leaderboard.',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '⚠️ Collaborate and gain more stats to appear on leaderboard',
                        style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  searchTextField(MediaQuery.of(context).size), // Added search field
                ],
              ),
            ),
          ),
          SizedBox(height: 10),
          filteredData.isEmpty ?
          Image.asset(
            "assets/images/noData.png",
            fit: BoxFit.cover,
          )
          : Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: List.generate(filteredData.length, (index) {
                String? colorHex = filteredData[index]['color'];
                Color containerColor = colorHex != null
                    ? Color(int.parse(colorHex.replaceAll('#', '0xff')))
                    : green; // Fallback color if null

                return FadeInUp(
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
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
                            Text(
                              '${index + 1}',
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                                color: Colors.black,
                              ),
                            ),
                            const SizedBox(width: 10),
                            CircleAvatar(
                              backgroundColor: containerColor,
                              radius: 25,
                              child: CircleAvatar(
                                radius: 20,
                                backgroundColor: containerColor,
                                backgroundImage: filteredData[index]['profilePicture'] != null
                                    ? NetworkImage(filteredData[index]['profilePicture'])
                                    : const AssetImage("assets/images/profile.jpg"),
                              ),
                            ),
                            const SizedBox(width: 20),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  filteredData[index]['username'],
                                  style: const TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                    color: Colors.black,
                                  ),
                                ),
                                SizedBox(height: 5),
                                Column(
                                  children: [

                                    const SizedBox(height: 5),
                                    Row(
                                      children: [
                                        Text(
                                          "${filteredData[index]['geekScore'].toStringAsFixed(2)}%",
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
    );
  }

  Widget searchTextField(Size size) {
    return SizedBox(
      height: size.height / 13,
      child: TextField(
        controller: searchController, // Added controller
        onChanged: _filterTasks,
        style: GoogleFonts.inter(
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        keyboardType: TextInputType.text,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          hintText: 'Search user name, Geek score, Id',
          hintStyle: GoogleFonts.inter(
            fontSize: 16.0,
            color: const Color(0xFF151624).withOpacity(0.5),
          ),
          filled: true,
          fillColor: const Color(0xFFF2F3F5),
          prefixIcon: Icon(
            Icons.search,
            color: const Color(0xFF151624).withOpacity(0.5),
          ),
          contentPadding: const EdgeInsets.symmetric(horizontal: 20.0),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.4),
            ),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(10.0),
            borderSide: BorderSide(
              color: Colors.grey.withOpacity(0.4),
            ),
          ),
        ),
      ),
    );
  }
}
