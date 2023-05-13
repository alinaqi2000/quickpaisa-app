import 'dart:async';

import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickpaisa/qp_components.dart';
import 'package:quickpaisa/resources/colors.dart';
import 'package:quickpaisa/screens/add_product.dart';

class AddBrandScreen extends StatefulWidget {
  final String userAuthKey;
  // final Function setTab;
  const AddBrandScreen({Key? key, required this.userAuthKey}) : super(key: key);

  @override
  State<AddBrandScreen> createState() => _AddBrandScreenState();
}

class _AddBrandScreenState extends State<AddBrandScreen> {
  late TextEditingController productSearchController;
  final List<Map<String, dynamic>> _items = [];
  int currentSearchHintIndex = 0;

  Timer? _updateContactsSearchingHintTimer;

  final _formKey = GlobalKey<FormState>();
  String errorMessage1 = "";
  String errorMessage2 = "";
  String brandName = "";
  String brandHomePage = "";

  @override
  void initState() {
    super.initState();
    productSearchController = TextEditingController();
  }

  @override
  void dispose() {
    _updateContactsSearchingHintTimer!.cancel();
    productSearchController.dispose();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        // backgroundColor: Color(0xfffcfcfc),
        backgroundColor: Color(AppColors.primaryBackground),
        appBar: AppBar(
          leading: IconButton(
              onPressed: goBackToLastTabScreen,
              icon: Icon(Icons.arrow_back,
                  color: Color(AppColors.secondaryText))),
          title: Text("Add Brand",
              style: TextStyle(color: Color(AppColors.primaryText))),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            SizedBox(
              height: 80,
            ),
            Expanded(
              child: Container(
                height: 300,
                width: double.infinity,
                child: FutureBuilder<Map<String, dynamic>>(
                    future: getData(
                        // urlPath: "/hadwin/v3/all-brands",
                        urlPath: "all-brands",
                        authKey: widget.userAuthKey),
                    builder: buildProducts),
              ),
            )
          ],
        ));
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

  void errorMessageSetter(int fieldNumber, String message) {
    setState(() {
      if (fieldNumber == 1) {
        errorMessage1 = message;
      } else if (fieldNumber == 2) {
        errorMessage2 = message;
      }
    });
  }

  void tryAddBrand() async {
    final dataReceived = await sendData(
        urlPath: "add-brand",
        // data: {"userInput": userInput, "password": password});
        data: {"name": brandName, "homepage": brandHomePage},
        authKey: widget.userAuthKey);
    if (dataReceived.keys.join().toLowerCase().contains("error")) {
      showErrorAlert(context, dataReceived);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
              content: Text("Brand added successfully!"),
              backgroundColor: Colors.green))
          .closed
          .then((value) => Navigator.of(context).pop());
    }
  }

  void _validateLoginDetails() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      if (errorMessage1 != "" || errorMessage2 != "") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please provide all required details'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        tryAddBrand();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
                content: Text('Processing...'),
                backgroundColor: Colors.blueAccent))
            .closed
            .then((value) => _formKey.currentState!.reset());
      }
    }
  }

  Widget buildProducts(
      BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
    _items.clear();
    if (snapshot.hasData) {
      final data = snapshot.data!["brands"] ?? [];
      data.forEach((item) => {
            _items.add({
              'value': '${item["id"]}',
              'label': "${item['name']}",
            })
          });
    }
    return Container(
      margin: EdgeInsets.symmetric(vertical: 60, horizontal: 20),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              child: TextFormField(
                textInputAction: TextInputAction.next,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    errorMessageSetter(1, 'you must provide a title');
                  } else {
                    errorMessageSetter(1, "");

                    setState(() {
                      brandName = value;
                    });
                  }

                  return null;
                },
                autocorrect: false,
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: "Enter title",
                  hintStyle: TextStyle(fontSize: 16, color: Color(0xFF929BAB)),
                ),
                style: TextStyle(
                    fontSize: 16, color: Color(AppColors.secondaryText)),
              ),
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Color(AppColors.secondaryBackground),
                  border: Border.all(
                      width: 1.0, color: Color(AppColors.shadowColor)),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 6.18,
                        spreadRadius: 0.618,
                        offset: Offset(-4, -4),
                        // color: Colors.white38
                        color: Color(AppColors.shadowColor)),
                    BoxShadow(
                        blurRadius: 6.18,
                        spreadRadius: 0.618,
                        offset: Offset(4, 4),
                        color: Color(AppColors.shadowColor)
                        // color: Color(0xFFF5F7FA)
                        )
                  ]),
            ),
            if (errorMessage1 != '')
              Container(
                child: Text(
                  "\t\t\t\t$errorMessage1",
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(2),
              ),
            Container(
              child: TextFormField(
                textInputAction: TextInputAction.done,
                onFieldSubmitted: (value) => _validateLoginDetails(),
                validator: (value) {
                  setState(() {
                    brandHomePage = value ?? "";
                  });
                  return null;
                },
                enableSuggestions: false,
                autocorrect: false,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: "Enter website",
                  hintStyle: TextStyle(fontSize: 16, color: Color(0xFF929BAB)),
                ),
                style: TextStyle(
                    fontSize: 16, color: Color(AppColors.secondaryText)),
              ),
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                  color: Color(AppColors.secondaryBackground),
                  border: Border.all(
                      width: 1.0, color: Color(AppColors.shadowColor)),
                  borderRadius: BorderRadius.circular(20),
                  boxShadow: [
                    BoxShadow(
                        blurRadius: 6.18,
                        spreadRadius: 0.618,
                        offset: Offset(-4, -4),
                        // color: Colors.white38
                        color: Color(AppColors.shadowColor)),
                    BoxShadow(
                        blurRadius: 6.18,
                        spreadRadius: 0.618,
                        offset: Offset(4, 4),
                        color: Color(AppColors.shadowColor)
                        // color: Color(0xFFF5F7FA)
                        )
                  ]),
            ),
            if (errorMessage2 != '')
              Container(
                child: Text(
                  "\t\t\t\t$errorMessage2",
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(2),
              ),
            Container(
              margin: EdgeInsets.symmetric(vertical: 16.0),
              width: double.infinity,
              height: 64,
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                      color: Color(AppColors.shadowColor),
                      offset: Offset(0, 4),
                      blurRadius: 5.0)
                ],
                gradient: RadialGradient(colors: [
                  Color(AppColors.primaryColor),
                  Color(AppColors.secondaryColor)
                ], radius: 8.4, center: Alignment(-0.24, -0.36)),
                borderRadius: BorderRadius.circular(20),
              ),
              child: ElevatedButton(
                  onPressed: _validateLoginDetails,
                  child: Text(
                    'Add',
                    style: TextStyle(
                        fontSize: 16,
                        color: Color(AppColors.secondaryBackground),
                        fontWeight: FontWeight.w600),
                  ),
                  style: ElevatedButton.styleFrom(
                    // primary: Colors.transparent,
                    shadowColor: Color(AppColors.shadowColor),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20)),
                  )),
            ),
          ],
        ),
      ),
    );
  }
}
