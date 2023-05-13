import 'dart:io';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:quickpaisa/database/user_data_storage.dart';
import 'package:quickpaisa/qp_components.dart';

import 'package:provider/provider.dart';
import 'package:quickpaisa/resources/colors.dart';
import 'package:quickpaisa/screens/all_brands.dart';
import 'package:quickpaisa/screens/all_contacts.dart';
import 'package:quickpaisa/screens/login_screen.dart';
import 'package:quickpaisa/screens/my_products.dart';
import 'package:quickpaisa/screens/all_transaction_activities_screen.dart';
import 'package:quickpaisa/database/login_info_storage.dart';

class HomeDashboardScreen extends StatefulWidget {
  final Map<String, dynamic> user;
  final String? userAuthKey;
  final Function setTab;
  const HomeDashboardScreen(
      {Key? key,
      required this.user,
      required this.userAuthKey,
      required this.setTab})
      : super(key: key);

  @override
  HomeDashboardScreenState createState() => HomeDashboardScreenState();
}

class HomeDashboardScreenState extends State<HomeDashboardScreen> {
  List<dynamic> allTransactions = [];
  bool fetching = true;
  late List<Map<String, dynamic>> response;
  Map<String, dynamic>? error = null;

  @override
  void initState() {
    super.initState();
    getTransactionsFromApi();
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> dashboardActions = [
      GestureDetector(
        onTap: goToWalletScreen,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 6),
          child: CircleAvatar(
            backgroundColor: Color(AppColors.secondaryBackground),
            radius: 26,
            child: ClipOval(
              child: Image.network(
                // "${ApiConstants.baseUrl}../storage/images/hadwin_images/hadwin_users/male/${widget.user['avatar']}",
                "${widget.user['avatar']}",
                height: 48,
                width: 48,
                fit: BoxFit.cover,
              ),
            ),
          ),
        ),
      )
    ];
    List<Widget> dashboardContents = [
      Container(
          height: 240,
          width: double.infinity,
          decoration: BoxDecoration(
            // color: Color(AppColors.secondaryColor),
            color: Color(AppColors.primaryColorDim),
            borderRadius: BorderRadius.only(
              bottomRight: Radius.circular(36),
            ),
          )),
      Positioned(
          child: Opacity(
            opacity: 0.5,
            child: Image.asset(
              "assets/images/quickpaisa_system/magicpattern-blob-1652765120695.png",
              color: Color(AppColors.secondaryBackground),
              height: 480,
            ),
          ),
          left: -156,
          top: -100),
      Positioned(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
                'assets/images/quickpaisa_system/quickpaisa-logo-lite.png',
                height: 48,
                width: 160,
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Hello, ${widget.user['first_name']}!",
                style: TextStyle(color: Colors.grey.shade300, fontSize: 17),
              ),
              SizedBox(
                height: 20,
              ),
              Text(
                "Rs. ${context.watch<UserLoginStateProvider>().bankBalance}",
                style: TextStyle(
                    color: Colors.white.withOpacity(0.80),
                    fontSize: 24,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 6.18,
              ),
              Text(
                "Your balance",
                style: TextStyle(color: Colors.white, fontSize: 15),
              )
            ],
          ),
        ),
        bottom: 20,
        left: 10,
      )
    ];
    List<Widget> transactionButtons = <Widget>[
      Padding(
        padding: EdgeInsets.only(left: 10, top: 10),
        child: ElevatedButton(
            onPressed: () => {
                  Navigator.push(
                          context, SlideRightRoute(page: MyQRCodeScreen()))
                      .whenComplete(() => setState(() {}))
                },
            child: Column(
              children: [
                SizedBox(
                  height: 10,
                ),
                Align(
                  alignment: Alignment.topLeft,
                  child: Icon(
                    Icons.qr_code_scanner_sharp,
                    size: 24,
                  ),
                ),
                Spacer(),
                Text(
                  "My QR Code",
                  style: TextStyle(fontSize: 11),
                ),
                SizedBox(
                  height: 10,
                )
              ],
            ),
            style: ElevatedButton.styleFrom(
              // primary: Color(AppColors.secondaryColor),
              primary: Color(AppColors.primaryColorDim),
              // fixedSize: Size(80, 100),
              fixedSize: Size(80, 80),
              shadowColor: Color(AppColors.secondaryColor).withOpacity(0.618),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            )),
      ),
      Padding(
        padding: EdgeInsets.only(left: 10, top: 10),
        child: ElevatedButton(
            onPressed: () => _makeATransaction('debit'),
            child: Column(children: [
              SizedBox(
                height: 10,
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Icon(
                    Icons.send_rounded,
                    size: 24,
                    color: Color(AppColors.secondaryColor),
                  )),
              Spacer(),
              Text(
                "Send Money",
                style: TextStyle(
                    color: Color(AppColors.secondaryText), fontSize: 11),
              ),
              SizedBox(
                height: 10,
              )
            ]),
            style: ElevatedButton.styleFrom(
              // fixedSize: Size(80, 100),
              backgroundColor: Color(AppColors.secondaryBackground),
              fixedSize: Size(80, 80),
              shadowColor: Color(AppColors.shadowColor).withOpacity(0.618),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            )),
      ),
      Padding(
        padding: EdgeInsets.only(left: 10, top: 10),
        child: ElevatedButton(
            onPressed: () => _makeATransaction('credit'),
            child: Column(children: [
              SizedBox(
                height: 10,
              ),
              Align(
                  alignment: Alignment.topLeft,
                  child: Icon(
                    Icons.receipt,
                    size: 24,
                    color: Color(AppColors.secondaryColor),
                  )),
              Spacer(),
              Text(
                "Request Money",
                style: TextStyle(
                    color: Color(AppColors.secondaryText), fontSize: 11),
              ),
              SizedBox(
                height: 10,
              )
            ]),
            style: ElevatedButton.styleFrom(
              // fixedSize: Size(80, 100),
              backgroundColor: Color(AppColors.secondaryBackground),
              fixedSize: Size(80, 80),
              shadowColor: Color(AppColors.shadowColor).withOpacity(0.618),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12)),
            )),
      ),
      // Padding(
      //   padding: EdgeInsets.all(10),
      //   child: ElevatedButton(
      //       onPressed: () => {
      //             Navigator.push(
      //                     context, SlideRightRoute(page: MyProductsScreen()))
      //                 .whenComplete(() => setState(() {}))
      //           },
      //       child: Column(children: [
      //         SizedBox(
      //           height: 10,
      //         ),
      //         Align(
      //             alignment: Alignment.topLeft,
      //             child: Icon(
      //               Icons.contacts_outlined,
      //               size: 24,
      //               color: Color(AppColors.secondaryColor),
      //             )),
      //         Spacer(),
      //         Text(
      //           "My Contacts",
      //           style: TextStyle(
      //               color: Color(AppColors.secondaryText), fontSize: 11),
      //         ),
      //         SizedBox(
      //           height: 10,
      //         )
      //       ]),
      //       style: ElevatedButton.styleFrom(
      //         // fixedSize: Size(80, 100),
      //         backgroundColor: Color(AppColors.secondaryBackground),
      //         fixedSize: Size(80, 80),
      //         shadowColor: Color(AppColors.shadowColor).withOpacity(0.618),
      //         shape: RoundedRectangleBorder(
      //             borderRadius: BorderRadius.circular(12)),
      //       )),
      // ),
      PopupMenuButton<_ScanOptions>(
        icon: Icon(
          FluentIcons.more_vertical_28_regular,
          color: Color(AppColors.secondaryText),
        ),
        offset: Offset(119, -27),
        onSelected: (value) {
          if (value == _ScanOptions.MyContacts) {
            Navigator.push(
                    context,
                    SlideRightRoute(
                        page: AllContactsScreen(
                            userAuthKey: widget.userAuthKey ?? "")))
                .whenComplete(() => setState(() {}));
          }
          if (value == _ScanOptions.MyBrands) {
            Navigator.push(
                    context,
                    SlideRightRoute(
                        page: AllBrandsScreen(
                            userAuthKey: widget.userAuthKey ?? "")))
                .whenComplete(() => setState(() {}));
          }
          if (value == _ScanOptions.MyProducts) {
            Navigator.push(
                context,
                SlideRightRoute(
                    page: MyProductsScreen(
                        userAuthKey: widget.userAuthKey ?? "")));
            //       .whenComplete(() => setState(() {}));
          }
          // else {
          //   Navigator.push(context, SlideRightRoute(page: MyProductsScreen()))
          //       .whenComplete(() => setState(() {}));
          // }
        },
        itemBuilder: (context) => [
          PopupMenuItem(
            child: Text("My Brands"),
            value: _ScanOptions.MyBrands,
          ),
          PopupMenuItem(
            child: Text("My Products"),
            value: _ScanOptions.MyProducts,
          ),
          PopupMenuItem(
            child: Text("My Contacts"),
            value: _ScanOptions.MyContacts,
          ),
          // PopupMenuItem(
          //   child: Text("My QR Code"),
          //   value: _ScanOptions.MyProducts,
          // )
        ],
      )
    ];

    List<Widget> homeScreenContents = <Widget>[
      Stack(
        children: dashboardContents,
      ),
      Container(
        padding: EdgeInsets.all(10),
        child: Align(
          alignment: Alignment.topLeft,
          child: Wrap(
            direction: Axis.horizontal,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 1,
            children: transactionButtons,
          ),
        ),
      ),
      Expanded(
          flex: 1,
          child: Container(
              padding: EdgeInsets.symmetric(horizontal: 10),
              height: 150,
              child: Column(
                children: <Widget>[
                  Container(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Text(
                          "Activity",
                          style: TextStyle(
                              fontSize: 21,
                              color: Color(AppColors.primaryText)),
                        ),
                        Spacer(),
                        InkWell(
                          child: Text("View all",
                              style:
                                  TextStyle(fontSize: 16, color: Colors.grey)),
                          onTap: _viewAllActivities,
                        )
                      ],
                    ),
                    width: double.infinity,
                  ),
                  Expanded(
                    child: Container(
                      height: 200,
                      margin: EdgeInsets.only(bottom: 35),
                      child: Builder(builder: _buildTransactionActivities),
                    ),
                  )
                ],
              )))
    ];

    return Scaffold(
        // backgroundColor: Color.fromARGB(255, 253, 253, 253),
        backgroundColor: Color(AppColors.primaryBackground),
        appBar: AppBar(
          actions: dashboardActions,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: CustomScrollView(slivers: [
          SliverFillRemaining(
              hasScrollBody: false,
              child: Column(
                children: homeScreenContents,
              ))
        ]));
  }

  void _makeATransaction(String transactionType) {
    Navigator.push(
            context,
            SlideRightRoute(
                page: AvailableBusinessesAndContactsScreen(
                    transactionType: transactionType)))
        .then((value) => getTransactionsFromApi());
  }

  Widget _buildTransactionActivities(BuildContext context) {
    if (error != null) {
      WidgetsBinding.instance!
          .addPostFrameCallback((_) => showErrorAlert(context, error!));

      return activitiesLoadingList(10);
    } else if (fetching) {
      return activitiesLoadingList(4);
    } else if (error == null) {
      if (allTransactions.isEmpty) {
        return Center(
          child: Text('no matches found'),
        );
      }
      List<dynamic> currentTransactions = List.from(allTransactions)
          .sublist(0, allTransactions.length < 4 ? allTransactions.length : 4);
      return Padding(
        padding: EdgeInsets.symmetric(horizontal: 15),
        child: ListView.separated(
          padding: EdgeInsets.all(0),
          separatorBuilder: (_, b) => Divider(
            height: 14,
            color: Colors.transparent,
          ),
          itemCount: currentTransactions.length,
          itemBuilder: (BuildContext context, int index) {
            Widget transactionMemberImage = FutureBuilder<int>(
              future: checkUrlValidity(
                  "${ApiConstants.baseUrl}../storage/images/hadwin_images/brands_and_businesses/${currentTransactions[index]['transactionMemberAvatar']}"),
              builder: (context, snapshot) {
                if (currentTransactions[index]
                        .containsKey('transactionMemberBusinessWebsite') &&
                    currentTransactions[index]
                        .containsKey('transactionMemberAvatar')) {
                  return ClipOval(
                    child: AspectRatio(
                      aspectRatio: 1.0 / 1.0,
                      child: ColorFiltered(
                        colorFilter: ColorFilter.mode(
                          Color(AppColors.secondaryColorDim),
                          BlendMode.color,
                        ),
                        child: ColorFiltered(
                          colorFilter: ColorFilter.mode(
                            Colors.grey,
                            BlendMode.saturation,
                          ),
                          child: Image.network(
                            currentTransactions[index]
                                        ['transactionMemberAvatar']
                                    .toString()
                                    .contains("http")
                                ? "${currentTransactions[index]['transactionMemberAvatar']}"
                                : "${ApiConstants.baseUrl}../storage/images/hadwin_images/brands_and_businesses/${currentTransactions[index]['transactionMemberAvatar']}",
                            height: 72,
                            width: 72,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ),
                    ),
                  );
                } else if (currentTransactions[index]
                        .containsKey('transactionMemberEmail') &&
                    currentTransactions[index]
                        .containsKey('transactionMemberAvatar') &&
                    snapshot.hasData) {
                  if (snapshot.data == 404) {
                    return ClipOval(
                      child: AspectRatio(
                        aspectRatio: 1.0 / 1.0,
                        child: Image.network(
                          "${ApiConstants.baseUrl}../storage/images/hadwin_images/hadwin_users/${currentTransactions[index]['transactionMemberGender'].toLowerCase()}/${currentTransactions[index]['transactionMemberAvatar']}",
                          height: 72,
                          width: 72,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  } else {
                    return ClipOval(
                      child: AspectRatio(
                        aspectRatio: 1.0 / 1.0,
                        child: Image.network(
                          currentTransactions[index]['transactionMemberAvatar']
                                  .toString()
                                  .contains("http")
                              ? "${currentTransactions[index]['transactionMemberAvatar']}"
                              : "${ApiConstants.baseUrl}../storage/images/hadwin_images/brands_and_businesses/${currentTransactions[index]['transactionMemberAvatar']}",
                          height: 72,
                          width: 72,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  }
                } else {
                  return Text(
                    currentTransactions[index]['transactionMemberName'][0]
                        .toUpperCase(),
                    style: TextStyle(
                        fontSize: 20, color: Color(AppColors.primaryColorDim)),
                  );
                }
              },
            );

            return Container(
              padding: EdgeInsets.all(2),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(20)),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      /*
                    color: Color(AppColors.shadowColor),
                    blurRadius: 4,
                    offset: Offset(0.0, 3),
                    spreadRadius: 0
                 */
                      color: Color(AppColors.primaryColor).withOpacity(0.1),
                      blurRadius: 48,
                      offset: Offset(2, 8),
                      spreadRadius: -16),
                ],
                color: Color(AppColors.secondaryBackground),
              ),
              child: ListTile(
                contentPadding:
                    EdgeInsets.only(left: 0, top: 0, bottom: 0, right: 6.18),
                leading: CircleAvatar(
                    radius: 38,
                    backgroundColor: Color(AppColors.shadowColor),
                    child: transactionMemberImage),
                title: Text(
                  currentTransactions[index]['transactionMemberName'],
                  style: TextStyle(
                      fontSize: 13,
                      fontWeight: FontWeight.bold,
                      color: Color(AppColors.secondaryColorDim)),
                ),
                subtitle: Padding(
                  padding: EdgeInsets.symmetric(vertical: 5),
                  child: Text(
                    dateFormatter(
                        currentTransactions[index]['dateGroup'],
                        DateTime.parse(
                            currentTransactions[index]['transactionDate'])),
                    style: TextStyle(
                        fontSize: 10, color: Color(AppColors.secondaryText)),
                  ),
                ),
                trailing: Padding(
                    padding: EdgeInsets.only(right: 2),
                    child: Text(
                      currentTransactions[index]['transactionType'] == "credit"
                          ? "+ Rs. ${currentTransactions[index]['transactionAmount'].toString()}"
                          : "- Rs. ${currentTransactions[index]['transactionAmount'].toString()}",
                      style: TextStyle(
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: currentTransactions[index]
                                      ['transactionType'] ==
                                  "credit"
                              ? Colors.greenAccent
                              : Colors.redAccent),
                    )),
                onTap: _viewAllActivities,
              ),
            );
          },
        ),
      );
    } else {
      return activitiesLoadingList(4);
    }
  }

  void goToWalletScreen() {
    widget.setTab(1);
    Provider.of<TabNavigationProvider>(context, listen: false).updateTabs(0);
  }

  void _viewAllActivities() {
    Provider.of<TabNavigationProvider>(context, listen: false).updateTabs(0);
    Navigator.push(
            context,
            SlideRightRoute(
                page: AllTransactionActivities(
                    user: widget.user, userAuthKey: widget.userAuthKey ?? "")))
        .whenComplete(() => setState(() {}));
  }

  void _updateTransactions() {
    setState(() {
      allTransactions
          .sort((a, b) => b['transactionDate'].compareTo(a['transactionDate']));
      for (var transaction in allTransactions) {
        String dateResponse =
            customGroup(DateTime.parse(transaction['transactionDate']));
        transaction['dateGroup'] = dateResponse;
      }
    });
  }

  Future<bool> _saveLoggedInUserData(Map<String, dynamic> user) async {
    try {
      final userIsSaved =
          await Future.wait([UserDataStorage().saveUserData(user)]);

      if (mounted) {
        Provider.of<UserLoginStateProvider>(context, listen: false)
            .initializeBankBalance(user);
        if (userIsSaved[0] && userIsSaved[1]) {
          debugPrint("user data saved");
        }
      }

      return true;
    } catch (e) {
      return false;
    }
  }

  Future<bool> _deleteLoggedInUserData() async {
    List<bool> deletionStatus = await Future.wait(
        [LoginInfoStorage().deleteFile(), UserDataStorage().deleteFile()]);
    return deletionStatus.first && deletionStatus.last;
  }

  void _logOut() async {
    bool logOutStatus = await _deleteLoggedInUserData();
    if (logOutStatus) {
      Navigator.of(context).pushAndRemoveUntil(
          MaterialPageRoute(builder: (context) => LoginScreen()),
          (route) => false);
    }
  }

  void getTransactionsFromApi() async {
    try {
      setState(() {
        fetching = true;
      });
      response = await Future.wait([
        getData(
            // urlPath: "/hadwin/v1/all-transactions", authKey: widget.userAuthKey!),
            urlPath: "all-transactions",
            authKey: widget.userAuthKey!),
        SuccessfulTransactionsStorage().getSuccessfulTransactions(),
      ]);
      final dataReceived = await getData(
          // urlPath: "/hadwin/v1/all-transactions", authKey: widget.userAuthKey!),
          urlPath: "auth/verify",
          authKey: widget.userAuthKey);

      if (dataReceived.keys.join().toLowerCase().contains("error")) {
        return _logOut();
      }
      await Future.wait([_saveLoggedInUserData(dataReceived['user'])]);

      if (response[0].keys.join().toLowerCase().contains("error") ||
          response[1].keys.join().toLowerCase().contains("error")) {
        setState(() {
          error = response[0].keys.join().toLowerCase().contains("error")
              ? response[0]
              : response[1];
          fetching = false;
        });
      } else {
        if (mounted) {
          setState(() {
            allTransactions = [
              ...response[0]['transactions'],
              ...response[1]['transactions']
            ];
            fetching = false;
          });
          _updateTransactions();
        }
      }
    } on SocketException {
      return _logOut();
    }
  }
}

enum _ScanOptions { MyContacts, MyBrands, MyProducts }
