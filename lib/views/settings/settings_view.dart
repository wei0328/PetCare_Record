import 'package:flutter/material.dart';
import '../../core/base_view.dart';
import '../../viewmodels/settings_viewmodel.dart';
import '../../theme/app_theme.dart';

class SettingsView extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BaseView<SettingsViewModel>(
      viewModelBuilder: () => SettingsViewModel(),
      onModelReady: (model) => model.loadSettings(),
      builder: (context, model, child) => Scaffold(
        appBar: AppBar(
          title: Text('设置', style: AppTheme.headingStyle),
          backgroundColor: AppTheme.primaryColor,
        ),
        body: model.isBusy
            ? const Center(child: CircularProgressIndicator())
            : const Center(child: Text('设置选项')),
      ),
    );
  }
}
