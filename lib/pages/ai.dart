import 'dart:convert';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_markdown/flutter_markdown.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:overlay_loader_with_app_icon/overlay_loader_with_app_icon.dart';
import 'package:rgt_pulse/pages/stats_page.dart';

import '../theme/colors.dart';
import 'all_stats_page.dart';

const String _apiKey = "AIzaSyAjRkq-fm_vK8tRcGNO0d7sZ9nL6Vkf_k8";

class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key, required this.title});

  final String title;

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Color(0xff7C7B9B),
        toolbarHeight: 100,
        centerTitle: false,
        title: Row(
          children: [
            CircleAvatar(
              radius: 30,
              backgroundImage: AssetImage(
                "assets/logo_c.png",
              ),
            ),
            SizedBox(
              width: 20,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  "Really Great AI",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 20,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 1.5,
                  ),
                ),
                Text(
                  'online',
                  style: TextStyle(
                      color: Color(0xffAEABC9),
                      fontSize: 18,
                      letterSpacing: 1.2,
                      fontWeight: FontWeight.w500),
                ),
              ],
            ),
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: Container(
              decoration: BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: Icon(
                  Icons.question_mark_rounded,
                  size: 28,
                  color: Colors.deepOrangeAccent,
                ),
                onPressed: () {
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
                      // UDE : SizedBox instead of Container for whitespaces
                      return Center(
                        child: Padding(
                          padding: const EdgeInsets.all(15),
                          child: SingleChildScrollView(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                richText(24),
                                const Text(
                                  "Get more insight on tasks and activities",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: primary),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                const Text(
                                  "AI might have high latency sometimes. This is due to the fact that it is still under development and not fully optimised\n"
                                  "App is using testing keys which comes with limited quota, contact abubakari@reallygreattech for support when quota is reached\n"
                                      "AI can make mistakes so please cross check data on various stats pages before data is used",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: black),
                                ),
                                TextButton(onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => StatsPage() ) );

                                },
                                    child: Text("My projects stats 📈")
                                ),
                                TextButton(onPressed: (){
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => AllStatsPage() ) );

                                },
                                    child: Text("All RGT projects stats 📊")
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                const Text(
                                  "AI Capabilities",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: primary),
                                ),
                                const Text(
                                  "I can identify and extract specific information "
                                  ", such as: User email addresses "
                                  "(e.g.,adom@reallygreattech.com), TaskIDs (e.g., 86c01982a), "
                                  "Task names (e.g., 'Medications filtermodification '), Project names "
                                  "(e.g., Mediboard), Task statutes (e.g., 'pr in review, 'qa on dev '), "
                                  "Task priorities (e.g., 'high 'Unknownpriority '), Collaborators involved in a "
                                  "task, Last updated date and time of a task, Recent activity on a task \n\n"
                                  "Summarize text: I can provide concise summaries of project data, highlighting key information. \n\n"
                                  "Answer questions: I can answer questions based on context. \n\n"
                                  "Generate text: I can generate text based on the provided context, such as writing a description of a"
                                  " task or creating a list of collaborators. \n\n"
                                  "Perform basic calculations: I can perform simple math calculations.\n\n"
                                  "And more ...",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: black),
                                ),
                                const SizedBox(
                                  height: 25,
                                ),
                                const Text(
                                  "AI Limitations",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: primary),
                                ),
                                const Text(
                                  "Don't have access to real-time information or external websites, \n\n"
                                  "I'm not able to interact with external systems like databases or collaborative platforms.",
                                  style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: black),
                                ),
                                const SizedBox(
                                  height: 50,
                                ),
                                const SizedBox(height: 20),
                                Image.asset(
                                  "assets/logo.png",
                                  height: 100,
                                  width: 100,
                                ),
                              ],
                            ),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          )
        ],
        elevation: 0,
      ),
      backgroundColor: Color(0xff7C7B9B),
      body: const ChatWidget(apiKey: _apiKey),
    );
  }
}

class ChatWidget extends StatefulWidget {
  const ChatWidget({required this.apiKey, super.key});

  final String apiKey;

  @override
  State<ChatWidget> createState() => _ChatWidgetState();
}

class _ChatWidgetState extends State<ChatWidget> {
  late final GenerativeModel _model;
  late final ChatSession _chat;
  late final List<dynamic> _taskData;
  bool _loading = false;
  bool _isLoading = true;
  String? userEmail;
  String name = "not available";
  String id = "not available";

  void _getUserEmail() {
    User? user = FirebaseAuth.instance.currentUser;
    setState(() {
      userEmail = user?.email;
    });
  }

  final ScrollController _scrollController = ScrollController();
  final TextEditingController _textController = TextEditingController();
  final FocusNode _textFieldFocus = FocusNode();
  final List<({Image? image, String? text, bool fromUser})> _generatedContent =
      <({Image? image, String? text, bool fromUser})>[];

  @override
  void initState() {
    super.initState();
    _model = GenerativeModel(
      model: 'gemini-1.5-flash',
      apiKey: widget.apiKey,
    );
    _chat = _model.startChat();
    _loadTaskActivities();
    _getUserEmail();
  }

  Future<void> _loadTaskActivities() async {
    try {
      setState(() {
        _isLoading = true;
      });

      String jsonString =
          await rootBundle.loadString('assets/jesse.task_activities.json');
      _taskData = json.decode(jsonString);

      for (var task in _taskData) {
        var current = task['current'];

        // Iterate through collaborators to find a match
        for (var collaborator in current['collaborators']) {
          if (collaborator['email'] == userEmail) {
            setState(() {
              name = collaborator['username'];
              id = collaborator['id'].toString();
            });
            break;
          }
        }

      }

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      print("Failed to load task activities: $e");
      _showError("Failed to load task activities: $e");
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _sendChatMessage(String message) async {
    setState(() {
      _loading = true;
    });

    try {
      _generatedContent.add((image: null, text: message, fromUser: true));

      // Convert the relevant parts of the JSON data to a context string
      String context = _generateContextFromJson(_taskData);

      final response = await _chat.sendMessage(
        Content.text(
            "Based on the following data context retrieved from app data: $context, answer this: $message"),
      );

      final text = response.text;
      _generatedContent.add((image: null, text: text, fromUser: false));

      setState(() {
        _loading = false;
        _scrollDown();
      });
    } catch (e) {
      print(e.toString());
      _showError(e.toString());
      setState(() {
        _loading = false;
      });
    } finally {
      _textController.clear();
      _textFieldFocus.requestFocus();
    }
  }

  String _generateContextFromJson(List<dynamic> jsonData) {
    StringBuffer context = StringBuffer();

    for (var task in jsonData) {
      var current = task['current'];
      var taskId = task['task_id'];
      var projectName = current?['project'] ?? 'Unknown project';
      var status = current?['status']?['status'] ?? 'Unknown status';
      var taskName = current?['name'] ?? 'Unnamed task';
      var priority = current?['priority'] ?? 'Unknown priority';

      // Safely access 'collaborators' with null check
      var collaborators = current?['collaborators']
              ?.map((collaborator) => collaborator['username'])
              .join(', ') ??
          'No collaborators';

      // Safely access 'last_updated' with null check
      var lastUpdated = current?['last_updated']?['\$date'] ?? 'Unknown date';

      // Safely access 'activities' with null check and check if list is not empty
      var recentActivity =
          (task['activities'] != null && task['activities'].isNotEmpty)
              ? (task['activities'].last['update']?['event']) ??
                  'No recent activity'
              : 'No recent activity';

      context.write(
          "Logged in user email is $userEmail ,name is $name and id is $id. If the user with that email is not found then the user has not collaborated on a task ");
      context.write(
          "Task $taskId ('$taskName') in project $projectName is currently $status with a priority of $priority. ");
      context.write("Collaborators involved: $collaborators. ");
      context.write(
          "Last updated on $lastUpdated. Recent activity: $recentActivity. ");
      context.write(
          "About RGT, (https://www.reallygreattech.com/) Our mission is to elevate your tech projects by"
          " providing expert services worldwide. Unlike the frustrations you've"
          " faced with unvetted developers—marked by mediocre outcomes, poor "
          "quality, delays, and communication issues—we ensure that every developer"
          " in our network is rigorously vetted. We focus on innovation and vision, "
          "so you can trust us to bring the best talent to your team, driving exceptional "
          "results and fostering seamless collaboration. With RGT, you're not just hiring a "
          "developer; you're gaining a partner committed to your success.");
    }

    return context.toString();
  }

  void _scrollDown() {
    WidgetsBinding.instance.addPostFrameCallback(
      (_) => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: const Duration(milliseconds: 750),
        curve: Curves.easeOutCirc,
      ),
    );
  }

  void _showError(String message) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Something went wrong'),
          content: SingleChildScrollView(
            child: SelectableText("$message\n Please try again later."),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('OK'),
            )
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: OverlayLoaderWithAppIcon(
        isLoading: _isLoading,
        overlayOpacity: 0.7,
        appIconSize: 50,
        circularProgressColor: Colors.purple,
        overlayBackgroundColor: Colors.black,
        appIcon: Image.asset("assets/logo.png"),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Container(
                padding: EdgeInsets.symmetric(horizontal: 20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: _apiKey.isNotEmpty
                      ? ListView.builder(
                          controller: _scrollController,
                          itemBuilder: (context, idx) {
                            final content = _generatedContent[idx];
                            return Container(
                              margin: EdgeInsets.only(top: 10),
                              child: MessageWidget(
                                text: content.text,
                                image: content.image,
                                isFromUser: content.fromUser,
                              ),
                            );
                          },
                          itemCount: _generatedContent.length,
                        )
                      : ListView(
                          children: const [
                            Text(
                              'No API key found. Please provide an API Key using '
                              "'--dart-define' to set the 'API_KEY' declaration.",
                            ),
                          ],
                        ),
                ),
              ),
            ),
            Container(
              padding: EdgeInsets.symmetric(horizontal: 20),
              color: Colors.white,
              height: 100,
              child: Row(
                children: [
                  Expanded(
                    child: Container(
                      padding: EdgeInsets.symmetric(horizontal: 14),
                      height: 60,
                      decoration: BoxDecoration(
                        color: Colors.grey[200],
                        borderRadius: BorderRadius.circular(30),
                      ),
                      child: TextField(
                        autofocus: true,
                        focusNode: _textFieldFocus,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          hintText: 'Enter a prompt ...',
                          hintStyle: TextStyle(color: Colors.grey[500]),
                        ),
                        controller: _textController,
                        onSubmitted: _sendChatMessage,
                      ),
                    ),
                  ),
                  const SizedBox.square(dimension: 15),
                  IconButton(
                    onPressed: !_loading
                        ? () async {
                            _sendChatMessage(_textController.text);
                            _textController.clear();
                          }
                        : null,
                    icon: Icon(
                      Icons.send,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                  if (_loading) const CircularProgressIndicator(),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class MessageWidget extends StatelessWidget {
  const MessageWidget({
    super.key,
    this.image,
    this.text,
    required this.isFromUser,
  });

  final Image? image;
  final String? text;
  final bool isFromUser;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment:
          isFromUser ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: [
        Flexible(
            child: Container(
                constraints: const BoxConstraints(maxWidth: 520),
                decoration: BoxDecoration(
                    color: isFromUser
                        ? Color(0xffFCAAAB)
                        : Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(16),
                      topRight: Radius.circular(16),
                      bottomLeft: Radius.circular(isFromUser ? 12 : 0),
                      bottomRight: Radius.circular(isFromUser ? 0 : 12),
                    )),
                padding: const EdgeInsets.symmetric(
                  vertical: 15,
                  horizontal: 20,
                ),
                margin: const EdgeInsets.only(bottom: 8),
                child: Column(children: [
                  if (text case final text?) MarkdownBody(data: text),
                  if (image case final image?) image,
                ]))),
      ],
    );
  }
}

Widget richText(double fontSize) {
  return Text.rich(
    TextSpan(
      style: GoogleFonts.inter(
        fontSize: fontSize,
        color: const Color(0xff513677),
        letterSpacing: 2.000000061035156,
      ),
      children: const [
        TextSpan(
          text: 'Really Great ',
          style: TextStyle(
            fontWeight: FontWeight.w900,
          ),
        ),
        TextSpan(
          text: 'AI',
          style: TextStyle(
            color: Color(0xFFFE9879),
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    ),
  );
}
