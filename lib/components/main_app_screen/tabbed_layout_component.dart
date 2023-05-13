import 'dart:async';
import 'dart:io';
import 'dart:math';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_nav_bar/google_nav_bar.dart';

import 'package:quickpaisa/providers/live_transactions_provider.dart';
import 'package:quickpaisa/providers/tab_navigation_provider.dart';

import 'package:quickpaisa/providers/user_login_state_provider.dart';
import 'package:quickpaisa/qp_components.dart';
import 'package:quickpaisa/resources/colors.dart';

import 'package:quickpaisa/screens/all_contacts.dart';
import 'package:quickpaisa/screens/all_transaction_activities_screen.dart';

import 'package:quickpaisa/screens/home_dashboard_screen.dart';

import 'package:quickpaisa/screens/wallet_screen.dart';
import 'package:quickpaisa/utilities/quickpaisa_icons.dart';

import 'package:provider/provider.dart';

class TabbedLayoutComponent extends StatefulWidget {
  final Map<String, dynamic> userData;
  const TabbedLayoutComponent({Key? key, required this.userData})
      : super(key: key);
  @override
  _TabbedLayoutComponentState createState() =>
      new _TabbedLayoutComponentState();
}

class _TabbedLayoutComponentState extends State<TabbedLayoutComponent> {
  Timer? _updateTransactionsTimer;
  int _currentTab = 0;
  int totalTransactionRequests = 0;

  final LabeledGlobalKey<HomeDashboardScreenState> dashboardScreenKey =
      LabeledGlobalKey("Dashboard Screen");
  final LabeledGlobalKey<AllTransactionActivitiesState>
      transactionActivitiesScreenKey =
      LabeledGlobalKey("Transaction Activities Screen");

  @override
  void initState() {
    super.initState();

    _updateTransactionsTimer = Timer.periodic(
        Duration(minutes: [1, 2, 3, 4][Random().nextInt(4)]), (Timer t) async {
      Provider.of<LiveTransactionsProvider>(context, listen: false)
          .updateTransactionRequests();
    });
  }

  @override
  void dispose() {
    _updateTransactionsTimer!.cancel();
    super.dispose();
  }

  void setTab(int index) {
    setState(() {
      _currentTab = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    String userAuthKey =
        Provider.of<UserLoginStateProvider>(context).userLoginAuthKey;
    List<Widget> screens = [
      HomeDashboardScreen(
        user: widget.userData,
        userAuthKey: userAuthKey,
        setTab: setTab,
        key: dashboardScreenKey,
      ),
      // AllContactsScreen(
      //   userAuthKey: userAuthKey,
      //   setTab: setTab,
      // ),
      // AllTransactionActivities(
      //   user: widget.userData,
      //   userAuthKey: userAuthKey,
      //   setTab: setTab,
      //   key: transactionActivitiesScreenKey,
      // ),
      WalletScreen(
        setTab: setTab,
        user: widget.userData,
      ),
    ];
    ;
    return WillPopScope(
      onWillPop: _onBackPress,
      child: Scaffold(
        // backgroundColor: Colors.white,
        backgroundColor: Color(AppColors.primaryBackground),

        extendBodyBehindAppBar: true,

        bottomNavigationBar: googleNavBar(),
        floatingActionButton: new FloatingActionButton(
          onPressed: () => {
            Navigator.push(
                context, SlideRightRoute(page: QRCodeScannerScreen()))
          },
          elevation: 2,
          backgroundColor: Color(AppColors.primaryColor),
          child: Icon(
            Icons.qr_code_scanner_outlined,
            size: 24.0,
          ),
        ),
        floatingActionButtonLocation:
            FloatingActionButtonLocation.miniCenterDocked,
        body: screens.isEmpty ? Text("Loading...") : screens[_currentTab],
      ),
    );
  }

  Widget googleNavBar() {
    int unreadTransactions =
        context.watch<LiveTransactionsProvider>().unreadTransactions;
    int transactionRequests =
        context.watch<LiveTransactionsProvider>().transactionRequests;
    if (transactionRequests != totalTransactionRequests) {
      setState(() {
        totalTransactionRequests = transactionRequests;
      });
      if (_currentTab == 0) {
        dashboardScreenKey.currentState!.getTransactionsFromApi();
      } else if (_currentTab == 2) {
        transactionActivitiesScreenKey.currentState!.getTransactionsFromApi();
      }
    }

    return BottomAppBar(
        shape: CircularNotchedRectangle(),
        notchMargin: 6, //shape of notch
        color: Color(AppColors.secondaryBackground),
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 0, vertical: 0),
          child: GNav(
            padding: const EdgeInsets.symmetric(horizontal: 60, vertical: 20),
            haptic: false,
            activeColor: Color(AppColors.primaryColor),
            iconSize: 12,
            gap: 6,
            tabMargin: EdgeInsets.all(0),
            duration: Duration(milliseconds: 300),
            color: Color(AppColors.secondaryText),
            backgroundColor: Colors.transparent,
            tabs: [
              GButton(
                icon: FluentIcons.home_32_regular,
                iconSize: 24,
                text: 'Home',
              ),
              // GButton(
              //   icon: FluentIcons.people_32_regular,
              //   iconSize: 24,
              //   text: 'Contacts',
              // ),
              // GButton(
              //   icon: FluentIcons.alert_32_regular,
              //   iconActiveColor: Color(AppColors.secondaryText),
              //   text: 'Activities',
              //   leading: Stack(
              //     children: [
              //       Icon(
              //         FluentIcons.alert_32_regular,
              //         color: _currentTab == 2
              //             ? Color(AppColors.primaryColor)
              //             : Color(AppColors.secondaryText),
              //         size: 24,
              //       ),
              //       if (unreadTransactions > 0)
              //         Positioned(
              //           top: 0,
              //           right: 0,
              //           child: ClipOval(
              //             child: Container(
              //                 color: Color(0xffffb3c1),
              //                 width: 17,
              //                 height: 17,
              //                 child: Center(
              //                   child: Text(unreadTransactions.toString(),
              //                       textAlign: TextAlign.center,
              //                       style: TextStyle(
              //                           fontSize: 9.6,
              //                           fontWeight: FontWeight.bold,
              //                           color: Color(0xffc9184a),
              //                           backgroundColor: Color(0xffffb3c1))),
              //                 )),
              //           ),
              //         )
              //     ],
              //   ),
              // ),
              GButton(
                icon: quickpaisaIcons.line_awesome_wallet_solid,
                text: 'Wallet',
                iconSize: 24,
              ),
            ],
            selectedIndex: _currentTab,
            onTabChange: _onTabChange,
          ),
        ));
  }

  void _onTabChange(index) {
    if (_currentTab == 1 || _currentTab == 2) {
      FocusManager.instance.primaryFocus?.unfocus();
    }
    Provider.of<TabNavigationProvider>(context, listen: false)
        .updateTabs(_currentTab);
    setState(() {
      _currentTab = index;
    });
  }

  Future<bool> _onBackPress() {
    if (_currentTab == 0) {
      return Future.value(true);
    } else {
      int lastTab =
          Provider.of<TabNavigationProvider>(context, listen: false).lastTab;
      Provider.of<TabNavigationProvider>(context, listen: false)
          .removeLastTab();
      setTab(lastTab);
    }
    return Future.value(false);
  }
}
