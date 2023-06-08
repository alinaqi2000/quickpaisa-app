import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickpaisa/qp_components.dart';
import 'package:quickpaisa/resources/colors.dart';
import 'package:quickpaisa/screens/add_brand.dart';
import 'package:quickpaisa/screens/my_products.dart';

class AllBrandsScreen extends StatefulWidget {
  final String userAuthKey;
  // final Function setTab;
  const AllBrandsScreen({Key? key, required this.userAuthKey})
      : super(key: key);

  @override
  State<AllBrandsScreen> createState() => _AllBrandsScreenState();
}

class _AllBrandsScreenState extends State<AllBrandsScreen> {
  late TextEditingController brandSearchController;

  List<String> searchHintsList = [
    'Search...',
    'Search for a brand by it\'s title',
  ];
  int currentSearchHintIndex = 0;

  Timer? _updateBrandsSearchingHintTimer;

  @override
  void initState() {
    super.initState();
    brandSearchController = TextEditingController();
    // _updateBrandsSearchingHintTimer =
    //     Timer.periodic(Duration(seconds: 10), (timer) {
    //   if (mounted && brandSearchController.text.isEmpty) {
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
    _updateBrandsSearchingHintTimer!.cancel();
    brandSearchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentSearchHint = searchHintsList[currentSearchHintIndex];
    Widget searchBrands = Container(
      margin: EdgeInsets.only(top: 28, bottom: 14, left: 28, right: 28),
      child: TextField(
        controller: brandSearchController,
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
          title: Text("My Brands",
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(AppColors.primaryColorDim),
          child: const Icon(
            Icons.add,
            color: Color(AppColors.primaryBackground),
            size: 28,
          ),
          onPressed: () => {
            Navigator.push(
                context,
                SlideRightRoute(
                    page: AddBrandScreen(
                  userAuthKey: widget.userAuthKey,
                )))
          },
        ),
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            searchBrands,
            Expanded(
              child: Container(
                height: 300,
                width: double.infinity,
                child: FutureBuilder<Map<String, dynamic>>(
                    future: getData(
                        // urlPath: "/hadwin/v3/all-brands",
                        urlPath: "all-brands",
                        authKey: widget.userAuthKey),
                    builder: buildBrands),
              ),
            )
          ],
        ));
  }

  void goBackToLastTabScreen() {
    Navigator.pop(context);
    // FocusManager.instance.primaryFocus?.unfocus();
    // brandSearchController.clear();
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

  void _tryDeleteBrand(String id) async {
    final dataReceived = await sendData(
        urlPath: "delete-brand/" + id, data: {}, authKey: widget.userAuthKey);
    print(dataReceived);
    if (dataReceived.keys.join().toLowerCase().contains("error")) {
      showErrorAlert(context, dataReceived);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Brand deleted successfully!"),
          backgroundColor: Colors.green));
      Navigator.of(context).pop();
    }
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

  void _deleteBrandDialog(String id) {
    Decoration buttonDecoration = BoxDecoration(
      borderRadius: BorderRadius.circular(10),
    );
    ButtonStyle successButtonStyle = ElevatedButton.styleFrom(
      primary: Color(AppColors.secondaryColorDim),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
    ButtonStyle delButtonStyle = ElevatedButton.styleFrom(
      primary: Colors.redAccent,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    );
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
              backgroundColor: Color(AppColors.secondaryBackground),
              title: Text(
                "Delete Brand?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(AppColors.secondaryColorDim)),
              ),
              content: Text(
                "Are you sure, you want to delete this brand and it's products",
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
                          decoration: buttonDecoration,
                          child: ElevatedButton(
                              onPressed: () => _tryDeleteBrand(id),
                              child: Text('Delete'),
                              style: delButtonStyle),
                        ),
                        SizedBox(
                          width: 24,
                        ),
                        Container(
                          height: 48,
                          width: 100,
                          decoration: buttonDecoration,
                          child: ElevatedButton(
                              onPressed: () {
                                Navigator.of(context).pop();
                              },
                              child: Text('Cancel'),
                              style: successButtonStyle),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: 20,
                    ),
                  ],
                )
              ],
            ));
  }

  void openQRCodeScanner() {
    FocusManager.instance.primaryFocus?.unfocus();
    Navigator.push(context, SlideRightRoute(page: QRCodeScannerScreen()));
  }

  Widget buildBrands(
      BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
    List<Widget> children;
    if (snapshot.hasData) {
      if (snapshot.data!.keys.join().toLowerCase().contains("error")) {
        WidgetsBinding.instance!.addPostFrameCallback(
            (_) => showErrorAlert(context, snapshot.data!));

        return contactsLoadingList(10);
      } else {
        List<dynamic> data;
        if (brandSearchController.text.isEmpty) {
          data = snapshot.data!['brands'];
        } else {
          List<dynamic> nameMatch = snapshot.data!['brands']
              .where((brand) =>
                  RegExp("${brandSearchController.text.toLowerCase()}")
                      .hasMatch(brand['name'].toLowerCase()))
              .toList();

          data = [...nameMatch].toSet().toList();
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
                  Widget brandImage;
                  if (data[index].containsKey('avatar')) {
                    brandImage = ClipOval(
                      child: AspectRatio(
                        aspectRatio: 1.0 / 1.0,
                        child: Image.network(
                          "${ApiConstants.baseUrl}../storage/images/hadwin_images/brands_and_businesses/${data[index]['avatar']}",
                          // "${data[index]['avatar']}",
                          height: 68,
                          width: 68,
                          fit: BoxFit.contain,
                        ),
                      ),
                    );
                  } else {
                    brandImage = Text(
                      data[index]['name'][0].toUpperCase(),
                      style: TextStyle(
                          fontSize: 20,
                          color: Color(AppColors.primaryColorDim)),
                    );
                  }

                  String tileSubtitle = data[index]['homepage'] ?? "";

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
                        child: brandImage,
                        backgroundColor: Color(AppColors.shadowColor),
                        radius: 36.0,
                      ),
                      title: Text(
                        data[index]['name'],
                        style: TextStyle(
                            fontSize: 13,
                            color: Color(AppColors.secondaryColor)),
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
                      onLongPress: () =>
                          _deleteBrandDialog("${data[index]['id']}"),
                      onTap: () => Navigator.push(
                          context,
                          SlideRightRoute(
                              page: MyProductsScreen(
                            brandId: "${data[index]['id']}",
                            brandName: "${data[index]['name']}",
                            userAuthKey: widget.userAuthKey,
                          ))),
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
