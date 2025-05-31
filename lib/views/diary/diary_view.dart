import 'package:flutter/material.dart';
import '../../core/base_view.dart';
import '../../viewmodels/diary_viewmodel.dart';
import '../../theme/app_theme.dart';

class DiaryView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseView<DiaryViewModel>(
      viewModelBuilder: () => DiaryViewModel(),
      onModelReady: (model) => model.loadDiaries(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text('日记', style: AppTheme.headingStyle),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: model.isBusy
            ? const Center(child: CircularProgressIndicator())
            : const Center(child: Text('日记内容')),
      ),
    );
  }
}
