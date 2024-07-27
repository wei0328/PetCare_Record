import 'package:flutter/material.dart';
import 'package:petcare_record/pages/diary_page.dart';
import 'package:petcare_record/pages/setting/setting_page.dart';
import 'package:petcare_record/pages/myPets/my_pets_page.dart';
import 'package:petcare_record/pages/map_page.dart';
import 'package:petcare_record/globalclass/color.dart';

class BottomNavigationBarWidget extends StatefulWidget {
  final Function(int) onItemSelected;
  final int currentIndex;

  const BottomNavigationBarWidget({
    Key? key,
    required this.onItemSelected,
    required this.currentIndex,
  }) : super(key: key);

  @override
  _BottomNavigationBarWidgetState createState() =>
      _BottomNavigationBarWidgetState();
}

class _BottomNavigationBarWidgetState extends State<BottomNavigationBarWidget> {
  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      items: const <BottomNavigationBarItem>[
        // BottomNavigationBarItem(
        //   icon: Icon(Icons.book),
        //   label: 'Diary',
        // ),
        BottomNavigationBarItem(
          icon: Icon(Icons.pets),
          label: 'My Pets',
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: 'Setting',
        ),
      ],
      currentIndex: widget.currentIndex,
      selectedItemColor: PetRecordColor.theme,
      unselectedItemColor: PetRecordColor.iconcolor,
      backgroundColor: PetRecordColor.white,
      onTap: widget.onItemSelected,
    );
  }
}
