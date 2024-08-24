import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:rgt_pulse/pages/task_detail_page.dart';
import 'package:timeline_tile/timeline_tile.dart';
import '../theme/colors.dart';

class SearchPage extends StatefulWidget {
  final List<dynamic> tasks;

  SearchPage({required this.tasks});

  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  List<dynamic> _filteredTasks = [];
  String _searchText = '';

  @override
  void initState() {
    super.initState();
    _filteredTasks = widget.tasks;
  }

  void _filterTasks(String query) {
    setState(() {
      _searchText = query.toLowerCase();
      _filteredTasks = widget.tasks.where((task) {
        String taskName = task['current']['name'].toLowerCase();
        String taskStatus = task['current']['status']['status'].toLowerCase();
        String projectName = task['current']['project'].toLowerCase();
        String taskId = task['_id']['\$oid'].toLowerCase();

        return taskName.contains(_searchText) ||
            projectName.contains(_searchText) ||
            taskId.contains(_searchText) ||
            taskStatus.contains(_searchText);
      }).toList();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
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
                      BackButton(),
                      const Text(
                        "Search tasks",
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: black),
                      ),
                      Image.asset("assets/logo.png", height: 70, width: 70),
                    ],
                  ),
                  SizedBox(height: 15),
                  searchTextField(MediaQuery.of(context).size),
                  SizedBox(height: 15),
                  Text(
                    "${_filteredTasks.length} tasks found",
                    style: const TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.bold,
                        color: primary),
                  ),
                  SizedBox(height: 15),
                ],
              ),
            ),
          ),
          Expanded(
            child: _filteredTasks.isEmpty
                ? Image.asset(
                    "assets/images/noData.png",
                    fit: BoxFit.cover,
                  )
                : ListView.builder(
                    itemCount: _filteredTasks.length,
                    itemBuilder: (context, index) {
                      var task = _filteredTasks[index];
                      var projectName = task['current']['project'];
                      var taskName = task['current']['name'];
                      var status = task['current']['status']['status'];
                      var color = task['current']['status']['color'];
                      var taskId = task['_id']['\$oid'];
                      var newColorCode =
                          Color(int.parse(color.replaceFirst('#', '0xFF')));

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
                          isLast: index == _filteredTasks.length - 1,
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
                                  padding: EdgeInsets.symmetric(
                                      horizontal: 10, vertical: 5),
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
      ),
    );
  }

  Widget searchTextField(Size size) {
    return SizedBox(
      height: size.height / 13,
      child: TextField(
        onChanged: _filterTasks,
        style: GoogleFonts.inter(
          color: const Color(0xFF151624),
        ),
        maxLines: 1,
        keyboardType: TextInputType.text,
        cursorColor: const Color(0xFF151624),
        decoration: InputDecoration(
          hintText: 'Search task name, project, Id, status',
          hintStyle: GoogleFonts.inter(
            fontSize: 16.0,
            color: const Color(0xFF151624).withOpacity(0.5),
          ),
          filled: true,
          fillColor: const Color.fromRGBO(248, 247, 251, 1),
          enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: primary,
              )),
          focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(8),
              borderSide: const BorderSide(
                color: primary,
              )),
          prefixIcon: const Icon(
            Icons.search,
            color: primary,
            size: 16,
          ),
        ),
      ),
    );
  }
}
