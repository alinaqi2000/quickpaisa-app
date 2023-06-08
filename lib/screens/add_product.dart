import 'package:flutter/material.dart';
import 'package:quickpaisa/qp_components.dart';
import 'package:quickpaisa/resources/colors.dart';
import 'package:quickpaisa/screens/add_brand.dart';
import 'package:select_form_field/select_form_field.dart';

class AddProductScreen extends StatefulWidget {
  final String userAuthKey;
  final String brandId;
  // final Function setTab;
  const AddProductScreen(
      {Key? key, required this.userAuthKey, this.brandId = ""})
      : super(key: key);

  @override
  State<AddProductScreen> createState() => _AddProductScreenState();
}

class _AddProductScreenState extends State<AddProductScreen> {
  List<Map<String, dynamic>> _items = [];
  bool loading = true;
  int currentSearchHintIndex = 0;

  final _formKey = GlobalKey<FormState>();
  String errorMessage1 = "";
  String errorMessage2 = "";
  String errorMessage3 = "";
  String productTitle = "";
  String productBrand = "";
  String productAmount = "";

  @override
  void initState() {
    super.initState();
  }

  @override
  void dispose() {
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
          title: Text("Add Product",
              style: TextStyle(color: Color(AppColors.primaryText))),
          centerTitle: true,
          backgroundColor: Colors.transparent,
          actions: [
            IconButton(
                onPressed: _refreshForm,
                icon:
                    Icon(Icons.refresh, color: Color(AppColors.secondaryText))),
          ],
          elevation: 0,
        ),
        extendBodyBehindAppBar: true,
        body: Column(
          children: [
            SizedBox(
              height: 60,
            ),
            Expanded(
              child: Container(
                  height: 400,
                  width: double.infinity,
                  child: FutureBuilder<Map<String, dynamic>>(
                      future: _getData(), builder: buildForm)),
            )
          ],
        ));
  }

  void _refreshForm() async {
    setState(() {
      loading = true;
    });
  }

  Future<Map<String, dynamic>> _getData() async {
    final data = await getData(
        // urlPath: "/hadwin/v3/all-brands",
        urlPath: "all-brands",
        authKey: widget.userAuthKey);
    loading = false;
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

  void errorMessageSetter(int fieldNumber, String message) {
    setState(() {
      if (fieldNumber == 1) {
        errorMessage1 = message;
      } else if (fieldNumber == 2) {
        errorMessage2 = message;
      } else {
        errorMessage3 = message;
      }
    });
  }

  void tryAddProduct() async {
    final dataReceived = await sendData(
        urlPath: "add-brand-product",
        // data: {"userInput": userInput, "password": password});
        data: {
          "brand_id": productBrand,
          "title": productTitle,
          "amount": productAmount
        },
        authKey: widget.userAuthKey);
    if (dataReceived.keys.join().toLowerCase().contains("error")) {
      showErrorAlert(context, dataReceived);
    } else {
      ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(
              content: Text("Product added successfully!"),
              backgroundColor: Colors.green))
          .closed
          .then((value) => Navigator.of(context).pop());
    }
  }

  void _validateProductDetails() {
    FocusManager.instance.primaryFocus?.unfocus();
    if (_formKey.currentState!.validate()) {
      if (errorMessage1 != "" || errorMessage2 != "" || errorMessage3 != "") {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Please provide all required details'),
            backgroundColor: Colors.redAccent,
          ),
        );
      } else {
        tryAddProduct();
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(
                content: Text('Processing...'),
                backgroundColor: Colors.blueAccent))
            .closed
            .then((value) => _formKey.currentState!.reset());
        ;
      }
    }
  }

  Widget buildForm(
      BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
    _items.clear();
    if (loading) {
      return Center(
        child: Text('Loading form...'),
      );
    }
    List<dynamic> data = [];
    if (snapshot.hasData) {
      data = snapshot.data!["brands"] ?? [];
      data.forEach((item) => {
            _items.add({
              'value': '${item["id"]}',
              'label': "${item['name']}",
            })
          });
    }
    if (_items.isEmpty) {
      return Container(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text("No brand found!"),
            Padding(
                padding: EdgeInsets.only(top: 20),
                child: InkWell(
                  onTap: () => {
                    Navigator.push(
                        context,
                        SlideRightRoute(
                            page: AddBrandScreen(
                          userAuthKey: widget.userAuthKey,
                        )))
                  },
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text("Add Brand",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(AppColors.secondaryColorDim))),
                      SizedBox(
                        width: 2,
                      ),
                      Icon(
                        Icons.add_circle_outline,
                        color: Color(AppColors.secondaryColorDim),
                        size: 16,
                      ),
                    ],
                  ),
                ))
          ],
        ),
      );
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
                      productTitle = value;
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
                border:
                    Border.all(width: 1.0, color: Color(AppColors.shadowColor)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Color(AppColors.primaryColor).withOpacity(0.1),
                      blurRadius: 48,
                      offset: Offset(2, 8),
                      spreadRadius: -16),
                ],
              ),
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
              child: SelectFormField(
                type: SelectFormFieldType.dropdown, // or can be dialog
                labelText: 'Brand',
                items: _items,
                initialValue: widget.brandId,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    errorMessageSetter(3, 'you must select a brand');
                  } else {
                    errorMessageSetter(3, "");

                    setState(() {
                      productBrand = value;
                    });
                  }

                  return null;
                },
                onChanged: (val) => print(val),
                onSaved: (val) => print(val),
              ),
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.symmetric(horizontal: 15, vertical: 5),
              decoration: BoxDecoration(
                color: Color(AppColors.secondaryBackground),
                border:
                    Border.all(width: 1.0, color: Color(AppColors.shadowColor)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Color(AppColors.primaryColor).withOpacity(0.1),
                      blurRadius: 48,
                      offset: Offset(2, 8),
                      spreadRadius: -16),
                ],
              ),
            ),
            if (errorMessage3 != '')
              Container(
                child: Text(
                  "\t\t\t\t$errorMessage3",
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(2),
              ),
            Container(
              child: InkWell(
                  onTap: () => {
                        Navigator.push(
                            context,
                            SlideRightRoute(
                                page: AddBrandScreen(
                              userAuthKey: widget.userAuthKey,
                            )))
                      },
                  child: Row(
                    children: [
                      SizedBox(
                        width: 10,
                      ),
                      Text("Add Brand",
                          style: TextStyle(
                              fontSize: 12,
                              color: Color(AppColors.secondaryColorDim))),
                      SizedBox(
                        width: 2,
                      ),
                      Icon(
                        Icons.add_circle_outline,
                        color: Color(AppColors.secondaryColorDim),
                        size: 16,
                      ),
                    ],
                  )),
              margin: EdgeInsets.all(2),
              padding: EdgeInsets.all(2),
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
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    errorMessageSetter(2, 'amount cannot be empty');
                  } else {
                    errorMessageSetter(2, "");
                    setState(() {
                      productAmount = value;
                    });
                  }
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
                  hintText: "Enter amount",
                  hintStyle: TextStyle(fontSize: 16, color: Color(0xFF929BAB)),
                ),
                style: TextStyle(
                    fontSize: 16, color: Color(AppColors.secondaryText)),
              ),
              margin: EdgeInsets.all(5),
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Color(AppColors.secondaryBackground),
                border:
                    Border.all(width: 1.0, color: Color(AppColors.shadowColor)),
                borderRadius: BorderRadius.circular(20),
                boxShadow: <BoxShadow>[
                  BoxShadow(
                      color: Color(AppColors.primaryColor).withOpacity(0.1),
                      blurRadius: 48,
                      offset: Offset(2, 8),
                      spreadRadius: -16),
                ],
              ),
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
                  onPressed: _validateProductDetails,
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
