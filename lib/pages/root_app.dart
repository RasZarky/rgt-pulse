import 'package:floating_chat_button/floating_chat_button.dart';
import 'package:flutter/material.dart';
import 'package:animated_bottom_navigation_bar/animated_bottom_navigation_bar.dart';
import 'package:rgt_pulse/pages/all_page.dart';
import 'package:rgt_pulse/pages/leaderboard_page.dart';
import 'package:rgt_pulse/pages/profile_page.dart';
import 'package:rgt_pulse/pages/stats_page.dart';
import '../theme/colors.dart';
import 'ai.dart';
import 'home_page.dart';

class RootApp extends StatefulWidget {
  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int pageIndex = 0;
  List<Widget> pages = [
    HomePage(),
    StatsPage(),
    LeaderboardPage(),
    ProfilePage(),
    AllPage()
  ];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: FloatingChatButton(
            background: getBody(),
          onTap: (BuildContext ) {
            Navigator.push(context, MaterialPageRoute(builder: (context) => ChatScreen(title: 'Chat with Ai',) ) );
          },
            messageBackgroundColor: primary,
            chatIconBorderColor: primary,
            chatIconBackgroundColor: Colors.white,
            chatIconWidget: Padding(
              padding: EdgeInsets.all(10.0),
              child: Image.asset("assets/images/ai.jpeg", height: 40, width: 40,),
            ),
            messageText: "Interact with the AI!",
            showMessageParameters: ShowMessageParameters(
                durationToShowMessage: const Duration(seconds: 5),
                delayDuration: const Duration(seconds: 2),
                showMessageFrequency: 5
                )
        ),
        bottomNavigationBar: getFooter(),
        floatingActionButton: FloatingActionButton(
            onPressed: () {
              selectedTab(4);
            },
            shape: const CircleBorder(),
            backgroundColor: primary,
            child:  Image.asset(
              "assets/logo_c.png",
            )
            //params
            ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.centerDocked);
  }

  Widget getBody() {
    return IndexedStack(
      index: pageIndex,
      children: pages,
    );
  }

  Widget getFooter() {
    List<IconData> iconItems = [
      Icons.calendar_month_outlined,
      Icons.area_chart,
      Icons.people,
      Icons.person,
    ];

    return AnimatedBottomNavigationBar(
      activeColor: primary,
      splashColor: secondary,
      inactiveColor: Colors.black.withOpacity(0.5),
      icons: iconItems,
      activeIndex: pageIndex,
      gapLocation: GapLocation.center,
      notchSmoothness: NotchSmoothness.verySmoothEdge,
      leftCornerRadius: 10,
      iconSize: 25,
      rightCornerRadius: 10,
      onTap: (index) {
        selectedTab(index);
      },
      blurEffect: true,
    );
  }

  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }
}
