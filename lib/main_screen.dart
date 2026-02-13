import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:online_banking_system/screens/home_screen.dart';
import 'package:online_banking_system/screens/settings_screen.dart';
import 'package:persistent_bottom_nav_bar/persistent_bottom_nav_bar.dart';

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  final PersistentTabController _controller = PersistentTabController(
    initialIndex: 0,
  );

  final List<Widget> _screens = const [
    HomeScreen(),
    Center(child: Text('Search Screen')),
    Center(child: Text('Messages Screen')),
    SettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return PersistentTabView(
      context,
      controller: _controller,
      screens: _screens,
      items: _navBarsItems(),
      resizeToAvoidBottomInset: true,
      hideNavigationBarWhenKeyboardAppears: true,
      backgroundColor: Colors.white,
      confineToSafeArea: true,
      navBarHeight: kBottomNavigationBarHeight,
      animationSettings: const NavBarAnimationSettings(
        navBarItemAnimation: ItemAnimationSettings(
          duration: Duration(milliseconds: 300),
          curve: Curves.easeOut,
        ),
        screenTransitionAnimation: ScreenTransitionAnimationSettings(
          animateTabTransition: true,
          duration: Duration(milliseconds: 200),
          screenTransitionAnimationType: ScreenTransitionAnimationType.fadeIn,
        ),
      ),
    );
  }

  List<PersistentBottomNavBarItem> _navBarsItems() {
    return [
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.home),
        title: "Home",
        activeColorPrimary: const Color(0xFF5B4CCC),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.search),
        title: "Search",
        activeColorPrimary: const Color(0xFF5B4CCC),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.chat_bubble),
        title: "Messages",
        activeColorPrimary: const Color(0xFF5B4CCC),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
      PersistentBottomNavBarItem(
        icon: const Icon(CupertinoIcons.settings),
        title: "Settings",
        activeColorPrimary: const Color(0xFF5B4CCC),
        inactiveColorPrimary: CupertinoColors.systemGrey,
      ),
    ];
  }
}
