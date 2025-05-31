import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'base_view_model.dart';

class BaseView<T extends BaseViewModel> extends StatelessWidget {
  final Widget Function(BuildContext context, T model, Widget? child) builder;
  final T Function() viewModelBuilder;
  final void Function(T)? onModelReady;

  const BaseView({
    Key? key,
    required this.builder,
    required this.viewModelBuilder,
    this.onModelReady,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<T>(
      create: (context) {
        T model = viewModelBuilder();
        if (onModelReady != null) {
          onModelReady!(model);
        }
        return model;
      },
      child: Consumer<T>(builder: builder),
    );
  }
}
