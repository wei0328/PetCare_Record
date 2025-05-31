import 'package:flutter/material.dart';
import '../../core/base_view.dart';
import '../../viewmodels/home_viewmodel.dart';
import '../../pages/dairy/diary_page.dart';
import '../../pages/myPets/my_pets_page.dart';
import '../../pages/setting/setting_page.dart';
import '../../dashboard/bottom_navigation_bar.dart';
import '../../globalclass/color.dart';

class HomeView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseView<HomeViewModel>(
      viewModelBuilder: () => HomeViewModel(),
      builder: (context, model, child) => Scaffold(
        body: IndexedStack(
          index: model.selectedIndex,
          children: [
            DiaryPage(),
            MyPetsPage(),
            SettingPage(),
          ],
        ),
        bottomNavigationBar: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              height: 0.5,
              color: PetRecordColor.grey,
            ),
            BottomNavigationBarWidget(
              currentIndex: model.selectedIndex,
              onItemSelected: model.setIndex,
            ),
          ],
        ),
      ),
    );
  }
}
