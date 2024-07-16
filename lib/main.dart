import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/pages/auth/login.dart';
import 'package:petcare_record/pages/diary_page.dart';
import 'package:petcare_record/pages/setting/setting_page.dart';
import 'package:petcare_record/pages/myPets/my_pets_page.dart';
import 'package:petcare_record/pages/map_page.dart';
import 'package:petcare_record/dashboard/bottom_navigation_bar.dart';
import 'package:get/get.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:petcare_record/pages/splash.dart';
import 'firebase_options.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return ScreenUtilInit(
      designSize: Size(375, 812),
      builder: (context, child) {
        return GetMaterialApp(
          debugShowCheckedModeBanner: false,
          home: Splash(),
        );
      },
    );
  }
}

class MyHomePage extends StatefulWidget {
  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _selectedIndex = 0;

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DiaryPage(),
          MyPetsPage(),
          MapPage(),
          SettingPage(),
        ],
      ),
      bottomNavigationBar: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 0.5,
            color: Colors.grey[300],
          ),
          BottomNavigationBarWidget(
            currentIndex: _selectedIndex,
            onItemSelected: _onItemTapped,
          ),
        ],
      ),
    );
  }
}
