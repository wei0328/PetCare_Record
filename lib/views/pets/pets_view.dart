import 'package:flutter/material.dart';
import '../../core/base_view.dart';
import '../../viewmodels/pets_viewmodel.dart';
import '../../theme/app_theme.dart';

class PetsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseView<PetsViewModel>(
      viewModelBuilder: () => PetsViewModel(),
      onModelReady: (model) => model.loadPets(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text('我的宠物', style: AppTheme.headingStyle),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: model.isBusy
            ? const Center(child: CircularProgressIndicator())
            : const Center(child: Text('宠物列表')),
      ),
    );
  }
}
