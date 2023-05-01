import 'package:flutter/material.dart';
import 'package:quickpaisa/resources/colors.dart';

class LocalSplashScreenComponent extends StatelessWidget {
  const LocalSplashScreenComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Color(AppColors.primaryBackground),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/quickpaisa_system/quickpaisa-splash-screen-logo.png',
            height: 128.0,
          ),
        ],
      ),
    );
  }
}
