import 'package:flutter/material.dart';
import 'package:quickpaisa/qp_components.dart';
import 'package:quickpaisa/resources/colors.dart';

class NewSettingsScreen extends StatelessWidget {
  NewSettingsScreen({Key? key}) : super(key: key);

  final AppBar appBar = AppBar(
    title: Text('Settings'),
    centerTitle: true,
    backgroundColor: Color(AppColors.primaryBackground),
    foregroundColor: Color(AppColors.secondaryText),
    elevation: 0,
  );

  @override
  Widget build(BuildContext context) {
    Column appSettings = Column(
      children: [
        Expanded(
          child: Container(
            width: MediaQuery.of(context).size.width,
            height: MediaQuery.of(context).size.height - 180,
            child: AppSettingsComponent(),
          ),
        )
      ],
    );
    return Scaffold(
      backgroundColor: Color(AppColors.primaryBackground),
      appBar: appBar,
      body: appSettings,
    );
  }
}
