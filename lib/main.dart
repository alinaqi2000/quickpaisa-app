import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_native_splash/flutter_native_splash.dart';

import 'package:quickpaisa/components/main_app_screen/local_splash_screen_component.dart';

import 'package:quickpaisa/components/main_app_screen/tabbed_layout_component.dart';
import 'package:quickpaisa/database/cards_storage.dart';
import 'package:quickpaisa/database/login_info_storage.dart';
import 'package:quickpaisa/database/quickpaisa_user_device_info_storage.dart';
import 'package:quickpaisa/database/successful_transactions_storage.dart';
import 'package:quickpaisa/database/user_data_storage.dart';
import 'package:quickpaisa/providers/live_transactions_provider.dart';
import 'package:quickpaisa/providers/tab_navigation_provider.dart';

import 'package:quickpaisa/providers/user_login_state_provider.dart';
import 'package:quickpaisa/resources/colors.dart';
import 'package:quickpaisa/screens/login_screen.dart';
import 'package:quickpaisa/utilities/make_api_request.dart';

import 'package:provider/provider.dart';

void main() async {
  WidgetsBinding widgetsBinding = WidgetsFlutterBinding.ensureInitialized();

  FlutterNativeSplash.preserve(widgetsBinding: widgetsBinding);

  runApp(MultiProvider(
    providers: [
      ChangeNotifierProvider(
        create: (_) => UserLoginStateProvider(),
      ),
      ChangeNotifierProxyProvider<UserLoginStateProvider,
              LiveTransactionsProvider>(
          create: (BuildContext context) => LiveTransactionsProvider(),
          update: (context, userLoginAuthKey, liveTransactions) =>
              liveTransactions!..update(userLoginAuthKey)),
      ChangeNotifierProvider(create: (_) => TabNavigationProvider()),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  _MyAppState createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  UserDeviceInfoStorage userDeviceInfoStorage = UserDeviceInfoStorage();
  UserDataStorage userDataStorage = UserDataStorage();
  LoginInfoStorage loginInfoStorage = LoginInfoStorage();
  bool? _previousllyInstalled = null;
  bool? _isLoggedIn = null;
  Map<String, dynamic>? _loggedInUserData = null;

  void _checkForPreviousInstallations() async {
    final previousllyInstalledStatus =
        await userDeviceInfoStorage.wasUsedBefore;
    setState(() {
      _previousllyInstalled = previousllyInstalledStatus;
    });
  }

  void _getLoggedInUserData() async {
    final loginData = await loginInfoStorage.getPersistentLoginData;
    final loggedInUserAuthKey = loginData['authToken'];
    final loggedInUserId = loginData['userId'];
    bool loginStatus;
    if (loggedInUserAuthKey == null || loggedInUserId == null) {
      loginStatus = false;
    } else {
      Provider.of<UserLoginStateProvider>(context, listen: false)
          .setAuthKeyValue(loggedInUserAuthKey);

      await CardsStorage().initializeAvailableCards(loggedInUserAuthKey);
      await SuccessfulTransactionsStorage().initializeSuccessfulTransactions();

      final userValidity =
          await fetchUserId(loggedInUserAuthKey, loggedInUserId);
      //* user data saved

      loginStatus = userValidity;
    }
    setState(() {
      _isLoggedIn = loginStatus;
    });
  }

  @override
  void initState() {
    super.initState();
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);

    _checkForPreviousInstallations();

    _getLoggedInUserData();
  }

  @override
  void dispose() {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeRight,
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.portraitUp,
      DeviceOrientation.portraitDown,
    ]);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        title: 'QuickPaisa',
        theme: ThemeData(
            scaffoldBackgroundColor: Color(AppColors.primaryBackground),
            splashColor: Color(AppColors.primaryBackground),
            colorScheme: ColorScheme.dark(
                primary: Color(AppColors.primaryColor),
                onPrimary: Color(AppColors.primaryText),
                secondary: Color(AppColors.primaryBackground),
                onSecondary: Color(AppColors.primaryBackground),
                error: Color(AppColors.primaryBackground),
                onError: Color(AppColors.primaryBackground),
                surface: Color(AppColors.primaryBackground),
                onSurface: Color(AppColors.primaryBackground),
                background: Color(AppColors.primaryBackground),
                onBackground: Color(AppColors.primaryBackground))),
        // theme: ThemeData(
        //     colorScheme: ColorScheme(
        //         brightness: Brightness.dark,
        //         primary: Color(AppColors.primaryColor),
        //         onPrimary: Color(AppColors.primaryText),
        //         secondary: Color(AppColors.primaryBackground),
        //         onSecondary: Color(AppColors.primaryBackground),
        //         error: Color(AppColors.primaryBackground),
        //         onError: Color(AppColors.primaryBackground),
        //         surface: Color(AppColors.primaryBackground),
        //         onSurface: Color(AppColors.primaryBackground),
        //         background: Color(AppColors.primaryBackground),
        //         onBackground: Color(AppColors.primaryBackground))

        //         ),
        // theme: ThemeData(),
        // darkTheme: ThemeData.dark(), // standard dark theme
        themeMode: ThemeMode.dark,
        home: Builder(
          builder: (context) {
            // if (_previousllyInstalled == false) {
            //   FlutterNativeSplash.remove();
            //   return OnboardingScreen();
            // } else
            if (_isLoggedIn == true && _loggedInUserData != null) {
              FlutterNativeSplash.remove();
              return TabbedLayoutComponent(
                userData: _loggedInUserData!,
              );
            } else if (_isLoggedIn == false) {
              FlutterNativeSplash.remove();
              return LoginScreen();
            } else {
              return Material(
                type: MaterialType.transparency,
                child: LocalSplashScreenComponent(),
              );
            }
          },
        ),
        debugShowCheckedModeBanner: false);
  }

  Future<bool> fetchUserId(String authKey, String userId) async {
    final dataReceived =
        // await getData(urlPath: "/hadwin/v3/user/$userId", authKey: authKey);
        await getData(urlPath: "auth/verify", authKey: authKey);
    if (dataReceived.keys.join().toLowerCase().contains("error")) {
      return false;
    } else {
      bool userIsSaved =
          await UserDataStorage().saveUserData(dataReceived['user']);
      Provider.of<UserLoginStateProvider>(context, listen: false)
          .initializeBankBalance(dataReceived['user']);

      if (userIsSaved) {
        //? in case user is valid
        if (mounted) {
          setState(() {
            _loggedInUserData = dataReceived['user'];
          });
        }
      }

      return userIsSaved;
    }
  }
}
