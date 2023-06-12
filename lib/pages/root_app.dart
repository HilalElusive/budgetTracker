import 'package:budget_tracker/pages/budget_page.dart';
import 'package:budget_tracker/pages/create_budge_page.dart';
import 'package:budget_tracker/pages/daily_page.dart';
import 'package:budget_tracker/pages/profile_page.dart';
import 'package:budget_tracker/theme/colors.dart';
import 'package:flutter/material.dart';

class RootApp extends StatefulWidget {
  const RootApp({Key? key}) : super(key: key);

  @override
  _RootAppState createState() => _RootAppState();
}

class _RootAppState extends State<RootApp> {
  int pageIndex = 0;
  List<Widget> pages = [
    DailyPage(),
    BudgetPage(),
    CreateBudgetPage(),
    ProfilePage(),
  ];

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(body: getBody(), bottomNavigationBar: getFooter());
  }

  Widget getBody() {
    return IndexedStack(
      index: pageIndex,
      children: pages,
    );
  }

  Widget getFooter() {
    List<IconData> iconItems = [
      Icons.calendar_month,
      Icons.wallet,
      Icons.add_box_rounded,
      Icons.person,
    ];

    return BottomNavigationBar(
      type: BottomNavigationBarType.fixed,
      currentIndex: pageIndex,
      selectedItemColor: primary,
      unselectedItemColor: Colors.black.withOpacity(0.5),
      onTap: (index) {
        selectedTab(index);
      },
      items: iconItems
          .map((icon) => BottomNavigationBarItem(
                icon: Icon(icon),
                label: '',
              ))
          .toList(),
    );
  }

  selectedTab(index) {
    setState(() {
      pageIndex = index;
    });
  }
}
