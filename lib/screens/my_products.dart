import 'dart:async';
import 'dart:ffi';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:quickpaisa/components/qr_code_scanner_screen/product_qr_screen.dart';
import 'package:quickpaisa/qp_components.dart';
import 'package:quickpaisa/resources/colors.dart';
import 'package:quickpaisa/screens/add_product.dart';
import 'dart:math' as math;

class MyProductsScreen extends StatefulWidget {
  final String userAuthKey;
  final String brandId;
  final String brandName;

  // final Function setTab;
  const MyProductsScreen(
      {Key? key,
      required this.userAuthKey,
      this.brandId = "",
      this.brandName = ""})
      : super(key: key);

  @override
  State<MyProductsScreen> createState() => _MyProductsScreenState();
}

class _MyProductsScreenState extends State<MyProductsScreen>
    with TickerProviderStateMixin {
  late TextEditingController productSearchController;

  late final AnimationController _controller = AnimationController(
    duration: Duration(seconds: 2),
    vsync: this,
  )..repeat(period: Duration(seconds: 2));

  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.linear,
  );

  List<String> searchHintsList = [
    'Search...',
    'Search for a product by it\'s title',
  ];
  int currentSearchHintIndex = 0;
  bool reload = false;
  Timer? _updateContactsSearchingHintTimer;

  GlobalKey<RefreshIndicatorState> _refreshIndicatorKey =
      GlobalKey<RefreshIndicatorState>();

  @override
  void initState() {
    super.initState();
    productSearchController = TextEditingController();
    // _updateContactsSearchingHintTimer =
    //     Timer.periodic(Duration(seconds: 5), (timer) {
    //   if (mounted && productSearchController.text.isEmpty) {
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
    // _updateContactsSearchingHintTimer!.cancel();
    productSearchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    String currentSearchHint = searchHintsList[currentSearchHintIndex];
    Widget searchContacts = Container(
      margin: EdgeInsets.only(top: 28, bottom: 14, left: 28, right: 28),
      child: TextField(
        controller: productSearchController,
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
        floatingActionButton: FloatingActionButton(
          backgroundColor: Color(AppColors.primaryColor),
          child: const Icon(
            Icons.add,
            color: Color(AppColors.primaryBackground),
            size: 28,
          ),
          onPressed: () => {
            Navigator.push(
                context,
                SlideRightRoute(
                    page: AddProductScreen(
                  userAuthKey: widget.userAuthKey,
                  brandId: widget.brandId,
                )))
          },
        ),
        appBar: AppBar(
          leading: IconButton(
              onPressed: goBackToLastTabScreen,
              icon: Icon(Icons.arrow_back,
                  color: Color(AppColors.secondaryText))),
          title: Text(
              widget.brandName != ""
                  ? "${widget.brandName}'s Products"
                  : "All Products",
              style: TextStyle(color: Color(AppColors.primaryText))),
          centerTitle: true,
          actions: [
            RotationTransition(
              turns: _animation,
              child: IconButton(
                  onPressed: () {
                    setState(() {
                      reload = !reload;
                    });
                  },
                  icon: Icon(Icons.refresh,
                      color: Color(AppColors.secondaryText))),
            ),
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
                    future: _getData(), builder: buildProducts),
              ),
            )
          ],
        ));
  }

  Future<Map<String, dynamic>> _getData() async {
    _controller.repeat();
    final data = await getData(
        urlPath: widget.brandId != ""
            ? "all-brand-products/" + widget.brandId
            : "all-products",
        authKey: widget.userAuthKey);
    _controller.stop();
    return data;
  }

  void goBackToLastTabScreen() {
    Navigator.pop(context);
    // FocusManager.instance.primaryFocus?.unfocus();
    // productSearchController.clear();
    // int lastTab =
    //     Provider.of<TabNavigationProvider>(context, listen: false).lastTab;
    // Provider.of<TabNavigationProvider>(context, listen: false).removeLastTab();

    // widget.setTab(lastTab);
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

  void _tryDeleteProduct(String id) async {
    final dataReceived = await sendData(
        urlPath: "delete-brand-product/" + id,
        data: {},
        authKey: widget.userAuthKey);
    if (dataReceived.keys.join().toLowerCase().contains("error")) {
      showErrorAlert(context, dataReceived);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text("Product deleted successfully!"),
          backgroundColor: Colors.green));
      Navigator.of(context).pop();
      setState(() {
        reload = !reload;
      });
    }
  }

  Future<void> _reload() {
    return Future(() => setState(() {
          reload = !reload;
        }));
  }

  void _deleteProductDialog(String id) {
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
                "Delete Product?",
                textAlign: TextAlign.center,
                style: TextStyle(color: Color(AppColors.secondaryColorDim)),
              ),
              content: Text(
                "Are you sure, you want to delete this product",
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
                              onPressed: () => _tryDeleteProduct(id),
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

  Widget buildProducts(
      BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
    List<Widget> children;
    if (snapshot.hasData) {
      if (snapshot.data!.keys.join().toLowerCase().contains("error")) {
        WidgetsBinding.instance!.addPostFrameCallback(
            (_) => showErrorAlert(context, snapshot.data!));

        return contactsLoadingList(10);
      } else {
        List<dynamic> data;
        if (productSearchController.text.isEmpty) {
          data = snapshot.data!['products'];
        } else {
          List<dynamic> titleMatch = snapshot.data!['products']
              .where((contact) =>
                  RegExp("${productSearchController.text.toLowerCase()}")
                      .hasMatch(contact['title'].toLowerCase()))
              .toList();

          data = [...titleMatch].toSet().toList();
        }
        if (data.isEmpty) {
          return Center(
            child: Text('no matches found'),
          );
        } else {
          return RefreshIndicator(
              key: _refreshIndicatorKey,
              onRefresh: _reload,
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 28),
                child: ListView.separated(
                    padding: EdgeInsets.all(0),
                    itemBuilder: (_, index) {
                      Widget contactImage;

                      contactImage = Text(
                        data[index]['title'][0].toUpperCase(),
                        style: TextStyle(
                            fontSize: 20,
                            color: Color(AppColors.primaryColor)),
                      );

                      String tileBrand = '${data[index]['brand']['name']}';
                      String tileAmount = 'Rs. ${data[index]['amount']}';

                      return Container(
                        padding: EdgeInsets.all(5),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(Radius.circular(20)),
                          boxShadow: <BoxShadow>[
                            BoxShadow(
                                color: Color(AppColors.primaryColor)
                                    .withOpacity(0.1),
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
                              data[index]['title'],
                              style: TextStyle(
                                  fontSize: 13,
                                  color: Color(AppColors.secondaryColorDim)),
                            ),
                            onLongPress: () =>
                                _deleteProductDialog("${data[index]['id']}"),
                            subtitle: Container(
                                margin: EdgeInsets.only(top: 7.2, right: 10),
                                child: Flex(
                                  direction: Axis.horizontal,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      tileBrand,
                                      style: TextStyle(
                                          fontSize: 11,
                                          color:
                                              Color(AppColors.secondaryText)),
                                    ),
                                    Text(
                                      tileAmount,
                                      style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.bold,
                                          color:
                                              Color(AppColors.primaryColorDim)),
                                    )
                                  ],
                                )),
                            horizontalTitleGap: 18,
                            onTap: () => Navigator.push(
                                context,
                                SlideRightRoute(
                                    page: ProductQRCodeScreen(
                                  product: data[index],
                                ))
                                // SlideRightRoute(
                                //     page: FundTransferScreen(
                                //   transactionType: 'debit',
                                //   otherParty: {
                                //     'type': "product",
                                //     'title': data[index]['title'] ?? "",
                                //     'amount': data[index]['amount'] ?? "0",
                                //     'banner': data[index]['banner'] ?? "",
                                //     'brandName': data[index]['brand']['name'] ?? "",
                                //     'walletAddress':
                                //         data[index]['walletAddress'] ?? "",
                                //   },
                                // ))
                                )
                            // _showInitiateTransactionDialogBox(data[index]),
                            ),
                      );
                    },
                    separatorBuilder: (_, b) => Divider(
                          height: 14,
                          color: Colors.transparent,
                        ),
                    itemCount: data.length),
              ));
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
