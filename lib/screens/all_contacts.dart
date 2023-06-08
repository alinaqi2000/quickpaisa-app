import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickpaisa/qp_components.dart';
import 'package:quickpaisa/resources/colors.dart';

class AllContactsScreen extends StatefulWidget {
  final String userAuthKey;
  // final Function setTab;
  const AllContactsScreen({Key? key, required this.userAuthKey})
      : super(key: key);

  @override
  State<AllContactsScreen> createState() => _AllContactsScreenState();
}

class _AllContactsScreenState extends State<AllContactsScreen> {
  late TextEditingController contactSearchController;

  List<String> searchHintsList = [
    'Search...',
    'Search for a contact by their name',
    'Search by their phone number',
    'Search by their email id',
  ];
  int currentSearchHintIndex = 0;

  Timer? _updateContactsSearchingHintTimer;

  @override
  void initState() {
    super.initState();
    contactSearchController = TextEditingController();
    // _updateContactsSearchingHintTimer =
    //     Timer.periodic(Duration(seconds: 10), (timer) {
    //   if (mounted && contactSearchController.text.isEmpty) {
    //     setState(() {
    //       if (currentSearchHintIndex == searchHintsList.length - 1) {
    //         currentSearchHintIndex = 0;
    //       } else {
    //         currentSearchHintIndex++;
    //       }
    //     });
    //     //* search hint updated
    //   }
    // });
  }

  @override
  void dispose() {
    _updateContactsSearchingHintTimer!.cancel();
    contactSearchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentSearchHint = searchHintsList[currentSearchHintIndex];
    Widget searchContacts = Container(
      margin: EdgeInsets.only(top: 28, bottom: 14, left: 28, right: 28),
      child: TextField(
        controller: contactSearchController,
        onChanged: (value) {
          setState(() {});
        },
        style: TextStyle(color: Color(AppColors.secondaryText)),
        decoration: InputDecoration(
            focusedBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color(AppColors.secondaryBackground), width: 1.618),
                borderRadius: BorderRadius.all(Radius.circular(16))),
            enabledBorder: OutlineInputBorder(
                borderSide: BorderSide(
                    color: Color(AppColors.secondaryBackground), width: 1.618),
                borderRadius: BorderRadius.all(Radius.circular(16))),
            hintText: currentSearchHint,
            hintStyle: TextStyle(color: Color(0xff929BAB))),
      ),
    );

    return Scaffold(
        // backgroundColor: Color(0xfffcfcfc),
        backgroundColor: Color(AppColors.primaryBackground),
        appBar: AppBar(
          leading: IconButton(
              onPressed: goBackToLastTabScreen,
              icon: Icon(Icons.arrow_back,
                  color: Color(AppColors.secondaryText))),
          title: Text("My Contacts",
              style: TextStyle(color: Color(AppColors.primaryText))),
          centerTitle: true,
          actions: [
            IconButton(
                onPressed: openQRCodeScanner,
                icon: Icon(FluentIcons.qr_code_28_regular,
                    color: Color(AppColors.secondaryText))),
          ],
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            searchContacts,
            Expanded(
              child: Container(
                height: 300,
                width: double.infinity,
                child: FutureBuilder<Map<String, dynamic>>(
                    future: getData(
                        // urlPath: "/hadwin/v3/all-contacts",
                        urlPath: "all-contacts",
                        authKey: widget.userAuthKey),
                    builder: buildContacts),
              ),
            )
          ],
        ));
  }

  void goBackToLastTabScreen() {
    Navigator.pop(context);
    // FocusManager.instance.primaryFocus?.unfocus();
    // contactSearchController.clear();
    // int lastTab =
    //     Provider.of<TabNavigationProvider>(context, listen: false).lastTab;
    // Provider.of<TabNavigationProvider>(context, listen: false).removeLastTab();

    // widget.setTab(lastTab);
  }

  void _showInitiateTransactionDialogBox(Map<String, dynamic> otherParty) {
    WidgetsBinding.instance!.addPostFrameCallback((_) => showDialog(
        context: context,
        builder: (context) => AlertDialog(
              backgroundColor: Color(AppColors.secondaryBackground),
              title: Text(
                "Pay/Request",
                textAlign: TextAlign.center,
              ),
              content: Text(
                "Decide what you want to do",
                style: TextStyle(color: Color(AppColors.secondaryText)),
                textAlign: TextAlign.center,
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              actionsAlignment: MainAxisAlignment.center,
              actions: [
                Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          height: 48,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: RadialGradient(colors: [
                                Color(AppColors.primaryColorDim),
                                Color(AppColors.primaryColorDim)
                              ], radius: 8.4, center: Alignment(-0.24, -0.36))),
                          child: ElevatedButton(
                              onPressed: () =>
                                  _makeATransaction(otherParty, 'debit'),
                              child: Text('Pay'),
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                primary: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              )),
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Container(
                          height: 48,
                          width: 100,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                              gradient: RadialGradient(colors: [
                                Color(AppColors.secondaryColorDim),
                                Color(AppColors.secondaryColorDim)
                              ], radius: 8.4, center: Alignment(-0.24, -0.36))),
                          child: ElevatedButton(
                              onPressed: () =>
                                  _makeATransaction(otherParty, 'credit'),
                              child: Text('Request'),
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.transparent,
                                primary: Colors.transparent,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                              )),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 18,
                    ),
                    Padding(
                      padding: EdgeInsets.all(10),
                      child: Text(
                        "tap the back button or outside this dialog box to cancel",
                        style: TextStyle(color: Color(AppColors.secondaryText)),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    SizedBox(
                      height: 18,
                    ),
                  ],
                )
              ],
            )));
  }

  void _makeATransaction(
      Map<String, dynamic> otherParty, String transactionType) {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.of(context).pop();
    Navigator.push(
        context,
        SlideRightRoute(
            page: FundTransferScreen(
          otherParty: otherParty,
          transactionType: transactionType,
        )));
  }

  void openQRCodeScanner() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.push(context, SlideRightRoute(page: QRCodeScannerScreen()));
  }

  Widget buildContacts(
      BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
    List<Widget> children;
    if (snapshot.hasData) {
      if (snapshot.data!.keys.join().toLowerCase().contains("error")) {
        WidgetsBinding.instance!.addPostFrameCallback(
            (_) => showErrorAlert(context, snapshot.data!));

        return contactsLoadingList(10);
      } else {
        List<dynamic> data;
        if (contactSearchController.text.isEmpty) {
          data = snapshot.data!['contacts'];
        } else {
          List<dynamic> nameMatch = snapshot.data!['contacts']
              .where((contact) =>
                  RegExp("${contactSearchController.text.toLowerCase()}")
                      .hasMatch(contact['name'].toLowerCase()))
              .toList();
          List<dynamic> emailMatch = snapshot.data!['contacts']
              .where((contact) =>
                  RegExp("${contactSearchController.text.toLowerCase()}")
                      .hasMatch(contact['emailAddress'].toLowerCase()))
              .toList();
          List<dynamic> phoneNumberMatch = snapshot.data!['contacts']
              .where((contact) =>
                  RegExp("${contactSearchController.text.toLowerCase()}")
                      .hasMatch(contact['phoneNumber'].toLowerCase()))
              .toList();
          data = [...nameMatch, ...emailMatch, ...phoneNumberMatch]
              .toSet()
              .toList();
        }
        if (data.isEmpty) {
          return Center(
            child: Text('no matches found'),
          );
        } else {
          return Padding(
            padding: EdgeInsets.symmetric(horizontal: 28),
            child: ListView.separated(
                padding: EdgeInsets.all(0),
                itemBuilder: (_, index) {
                  Widget contactImage;
                  // if (data[index].containsKey('avatar')) {
                  //   contactImage = ClipOval(
                  //     child: AspectRatio(
                  //       aspectRatio: 1.0 / 1.0,
                  //       child: Image.network(
                  //         // "${ApiConstants.baseUrl}/dist/images/hadwin_images/brands_and_businesses/${data[index]['avatar']}",
                  //         "${data[index]['avatar']}",
                  //         height: 68,
                  //         width: 68,
                  //         fit: BoxFit.contain,
                  //       ),
                  //     ),
                  //   );
                  // } else {
                  contactImage = Text(
                    data[index]['name'][0].toUpperCase(),
                    style: TextStyle(
                        fontSize: 20, color: Color(AppColors.primaryColorDim)),
                  );
                  // }

                  String tileSubtitle;

                  // if (data[index].containsKey('emailAddress') &&
                  //     data[index].containsKey('avatar')) {
                  //   tileSubtitle = data[index]['emailAddress'];
                  // } else {
                  tileSubtitle = data[index]['phoneNumber'];
                  // }

                  return Container(
                    padding: EdgeInsets.all(5),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.all(Radius.circular(20)),
                      boxShadow: <BoxShadow>[
                        BoxShadow(
                            color:
                                Color(AppColors.primaryColor).withOpacity(0.1),
                            blurRadius: 48,
                            offset: Offset(2, 8),
                            spreadRadius: -16),
                      ],
                      color: Color(AppColors.secondaryBackground),
                    ),
                    child: ListTile(
                      contentPadding: EdgeInsets.all(0),
                      leading: CircleAvatar(
                        child: contactImage,
                        backgroundColor: Color(AppColors.shadowColor),
                        radius: 36.0,
                      ),
                      title: Text(
                        data[index]['name'],
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(AppColors.secondaryColorDim)),
                      ),
                      subtitle: Container(
                          margin: EdgeInsets.only(top: 7.2),
                          child: Text(
                            tileSubtitle,
                            style: TextStyle(
                                fontSize: 11,
                                color: Color(AppColors.secondaryText)),
                          )),
                      horizontalTitleGap: 18,
                      onTap: () =>
                          _showInitiateTransactionDialogBox(data[index]),
                    ),
                  );
                },
                separatorBuilder: (_, b) => Divider(
                      height: 14,
                      color: Colors.transparent,
                    ),
                itemCount: data.length),
          );
        }
      }
    } else if (snapshot.hasError) {
      children = <Widget>[
        const Icon(
          Icons.error_outline,
          color: Colors.red,
          size: 60,
        ),
        Padding(
          padding: const EdgeInsets.only(top: 16),
          child: Text('Error: ${snapshot.error}'),
        )
      ];
    } else {
      return contactsLoadingList(10);
    }
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: children,
      ),
    );
  }
}
