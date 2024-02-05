import 'package:bottom_navy_bar/bottom_navy_bar.dart';
import 'package:flutter/material.dart';
import 'package:line_icons/line_icons.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:quran_app/screens/alldoa_screen.dart';
import 'package:quran_app/screens/allsurah_screen.dart';
import 'package:quran_app/screens/chat.dart';
import 'package:quran_app/screens/prayertime.dart';
import 'package:quran_app/screens/qiblah.dart';
import 'package:quran_app/utils/export_utils.dart';

import 'screens/homepage.dart';

class Dashboard extends StatefulWidget {
  const Dashboard({super.key});

  @override
  _DashboardState createState() => _DashboardState();
}

class _DashboardState extends State<Dashboard> {
  int _currentIndex = 0;
  late PageController _pageController;

  @override
  void initState() {
    super.initState();
    _pageController = PageController();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  bool hasPermission = false;

  Future getPermission() async {
    if (await Permission.location.serviceStatus.isEnabled) {
      var status = await Permission.location.status;
      if (status.isGranted) {
        hasPermission = true;
      } else {
        Permission.location.request().then((value) {
          setState(() {
            hasPermission = (value == PermissionStatus.granted);
          });
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.appbarBackgroundColor,
      // appBar: AppBar(
      //   title: Text("Faraja Credit")),
      body: SizedBox.expand(
        child: PageView(
          controller: _pageController,
          onPageChanged: (index) {
            // ShowInterstitialAd().showAd(context);
            setState(() => _currentIndex = index);
          },
          children: <Widget>[
            const Home(),
            const AllSurahScreen(),
            CompassScreen(),
            const PrayerTimesScreen(),
          ],
        ),
      ),
      // floatingActionButton: FloatingActionButton(
      //   onPressed: _incrementCounter,
      //   tooltip: '',
      //   child: Icon(Icons.add),
      // ),
      bottomNavigationBar: BottomNavyBar(
        backgroundColor: AppColors.appbarBackgroundColor,
        selectedIndex: _currentIndex,
        onItemSelected: (index) {
          setState(() => _currentIndex = index);
          _pageController.jumpToPage(index);
        },
        showElevation: false,
        containerHeight: 80,
        itemCornerRadius: 24,
        curve: Curves.easeIn,
        items: <BottomNavyBarItem>[
          BottomNavyBarItem(
            icon: const Icon(Icons.chat),
            title: const Text('Home'),
            activeColor: Colors.blue,
            inactiveColor: Colors.grey[500],
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(LineIcons.quran, color: Colors.green),
            title: const Text('Al-Quran'),
            activeColor: Colors.green,
            inactiveColor: Colors.grey[700],
            textAlign: TextAlign.center,
          ),
          BottomNavyBarItem(
            icon: const Icon(LineIcons.compass),
            title: const Text(
              'Qiblah',
            ),
            activeColor: Color.fromARGB(255, 88, 92, 88),
            textAlign: TextAlign.center,
            inactiveColor: Colors.grey[700],
          ),
          BottomNavyBarItem(
            icon: const Icon(Icons.person),
            title: const Text('Profile'),
            activeColor: Colors.green,
            inactiveColor: Colors.grey[700],
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
