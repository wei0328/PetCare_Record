import 'package:flutter/material.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/pages/diary_page.dart';
import 'package:petcare_record/pages/profile_page.dart';
import 'package:petcare_record/pages/my_pets_page.dart';
import 'package:petcare_record/pages/map_page.dart';
import 'package:petcare_record/dashboard/bottom_navigation_bar.dart';
import 'package:get/get.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Pet Record App',
      home: MyHomePage(),
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
      appBar: AppBar(
        title: Text(
          'Pet Record App',
          style: TextStyle(
            color: PetRecordColor.theme,
            fontSize: 20,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: PetRecordColor.primary,
      ),
      body: IndexedStack(
        index: _selectedIndex,
        children: [
          DiaryPage(),
          MyPetsPage(),
          MapPage(),
          ProfilePage(),
        ],
      ),
      bottomNavigationBar: BottomNavigationBarWidget(
        currentIndex: _selectedIndex,
        onItemSelected: _onItemTapped,
      ),
    );
  }
}
