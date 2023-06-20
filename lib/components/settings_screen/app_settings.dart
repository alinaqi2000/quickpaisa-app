import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:quickpaisa/components/settings_screen/all_licenses.dart';
import 'package:quickpaisa/components/settings_screen/app_creator_info.dart';
import 'package:quickpaisa/components/settings_screen/credits_screen.dart';
import 'package:quickpaisa/database/cards_storage.dart';
import 'package:quickpaisa/database/login_info_storage.dart';
import 'package:quickpaisa/database/successful_transactions_storage.dart';
import 'package:quickpaisa/database/user_data_storage.dart';
import 'package:quickpaisa/providers/live_transactions_provider.dart';
import 'package:quickpaisa/providers/user_login_state_provider.dart';
import 'package:quickpaisa/resources/colors.dart';
import 'package:quickpaisa/utilities/quickpaisa_markdown_viewer.dart';
import 'package:quickpaisa/screens/login_screen.dart';
import 'package:quickpaisa/utilities/slide_right_route.dart';
import 'package:provider/provider.dart';

class AppSettingsComponent extends StatelessWidget {
  const AppSettingsComponent({Key? key}) : super(key: key);

  Future<bool> _deleteLoggedInUserData() async {
    List<bool> deletionStatus = await Future.wait(
        [LoginInfoStorage().deleteFile(), UserDataStorage().deleteFile()]);
    return deletionStatus.first && deletionStatus.last;
  }

  Future<bool> _resetTransactionsAndCards(BuildContext context) async {
    List<bool> deletionStatus = await Future.wait([
      CardsStorage().resetLocallySavedCards(),
      SuccessfulTransactionsStorage().resetLocallySavedTransactions(),
      Provider.of<UserLoginStateProvider>(context, listen: false)
          .resetBankBalance(),
      Provider.of<LiveTransactionsProvider>(context, listen: false)
          .resetTransactionsInState()
    ]);
    Set<bool> deletionStatusSet = deletionStatus.toSet();
    return deletionStatusSet.length == 1 && deletionStatusSet.first == true;
  }

  @override
  Widget build(BuildContext context) {
    final data = _settingsMenu(context);

    return ListView.separated(
        padding: EdgeInsets.all(0),
        itemBuilder: (_, index) {
          return Container(
            padding: EdgeInsets.symmetric(horizontal: 16, vertical: 6),
            decoration: BoxDecoration(
              color: Color(AppColors.primaryBackground),
            ),
            child: ListTile(
              textColor: Color(AppColors.primaryText),
              contentPadding: EdgeInsets.all(5),
              title: data[index]['title'],
              trailing: data[index]['trailing'],
              onTap: data[index]['onTap'],
            ),
          );
        },
        separatorBuilder: (_, b) => Divider(
              height: 6,
              color: Color(AppColors.primaryText),
            ),
        itemCount: data.length);
  }

  List<dynamic> _settingsMenu(BuildContext context) {
    List<dynamic> settingsMenuItems = [
      {
        'title': Text('Credits'),
        'trailing': Icon(FluentIcons.star_emphasis_24_regular),
        'onTap': () {
          Navigator.push(context, SlideRightRoute(page: CreditsScreen()));
        },
        'settingsCategory': 'About the app',
      },
      // {
      //   'title': Text('Privacy Policy'),
      //   'trailing': Icon(FluentIcons.info_24_regular),
      //   'onTap': () =>
      //       openDocsViewer('PRIVACY_POLICY', 'Privacy Policy', context),
      //   'settingsCategory': 'About the app',
      // },
      // {
      //   'title': Text('Terms of use'),
      //   'trailing': Icon(FluentIcons.info_24_regular),
      //   'onTap': () => openDocsViewer(
      //       'TERMS_AND_CONDITIONS', 'Terms & Conditions', context),
      //   'settingsCategory': 'About the app',
      // },
      // {
      //   'title': Text('End User License Agreement'),
      //   'trailing': Icon(FluentIcons.info_24_regular),
      //   'onTap': () => openDocsViewer('END_USER_LICENSE_AGREEMENT',
      //       'End User License Agreement', context),
      //   'settingsCategory': 'About the app',
      // },
      {
        'title': Text('Sign Out'),
        'trailing': Icon(FluentIcons.sign_out_24_regular),
        'onTap': () async {
          bool logOutStatus = await _deleteLoggedInUserData();
          if (logOutStatus) {
            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(builder: (context) => LoginScreen()),
                (route) => false);
          }
        },
        'settingsCategory': 'General',
      },
      {
        'title': Padding(
            padding: EdgeInsets.symmetric(horizontal: 48, vertical: 0),
            child: Image.asset(
              'assets/images/quickpaisa_system/quickpaisa-logo-with-name.png',
            )),
        'trailing': null,
        'onTap': null,
        'settingsCategory': 'About the app',
      },
    ];

    return settingsMenuItems;
  }

  void openDocsViewer(String docName, String screenName, BuildContext context) {
    Navigator.push(
        context,
        SlideRightRoute(
            page: quickpaisaMarkdownViewer(
          screenName: screenName,
          urlRequested:
              'https://raw.githubusercontent.com/brownboycodes/quickpaisa/master/docs/$docName.md',
        )));
  }
}
