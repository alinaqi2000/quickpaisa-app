import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'package:quickpaisa/components/fund_transfer_screen/transaction_processing_screen.dart';
import 'package:quickpaisa/database/user_data_storage.dart';
import 'package:quickpaisa/qp_components.dart';
import 'package:quickpaisa/resources/colors.dart';

class FundTransferScreen extends StatefulWidget {
  final Map<String, dynamic> otherParty;
  final String transactionType;

  const FundTransferScreen(
      {Key? key, required this.otherParty, required this.transactionType})
      : super(key: key);

  @override
  _FundTransferScreenState createState() => _FundTransferScreenState();
}

class _FundTransferScreenState extends State<FundTransferScreen> {
  late Map<String, dynamic> userData;
  late TextEditingController _transactionAmountController;
  String _controllerHelperText = "0.00";
  late String transactionButton;
  Map<String, dynamic> transactionReceipt = {};
  Map<String, dynamic>? transactionResult = null;

  late String tileSubtitle;

  @override
  void initState() {
    super.initState();
    setUserData();
    if (widget.otherParty['type'] == 'product') {
      widget.otherParty['name'] = widget.otherParty['title'];
      widget.otherParty['avatar'] = widget.otherParty['banner'] ?? "";
      widget.otherParty['homepage'] = widget.otherParty['brandName'] ?? "";
      this._controllerHelperText = widget.otherParty['amount'];
    }

    transactionButton = widget.transactionType == 'debit' ? "Send" : 'Request';
    numPadKeys =
        List<int>.generate(9, (i) => i + 1).map(_createButton).toList();

    bottomKeys = [
      ElevatedButton(
        onPressed: _addZeroes,
        child: Text(
          "0",
          style: TextStyle(
              color: Color(AppColors.secondaryText),
              fontSize: 24,
              fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          primary: Color(AppColors.secondaryBackground),
          shape: CircleBorder(),
          elevation: 0,
          // elevation: 0.618,
          // shadowColor: Color(0xffF5F7FA)
        ),
      ),
      ElevatedButton(
        onPressed: _addDecimal,
        child: Text(
          ".",
          style: TextStyle(
              color: Color(AppColors.secondaryText),
              fontSize: 30,
              fontWeight: FontWeight.w700),
        ),
        style: ElevatedButton.styleFrom(
          primary: Color(AppColors.secondaryBackground),
          shape: CircleBorder(),
          // elevation: 0.618,
          elevation: 0,
          // shadowColor: Color(0xffF5F7FA)
        ),
      ),
      ElevatedButton(
        onPressed: _eraseDigits,
        onLongPress: _clearTransactionAmount,
        child: Text(
          String.fromCharCode(FluentIcons.backspace_24_regular.codePoint),
          style: TextStyle(
            inherit: false,
            color: Color(AppColors.secondaryText),
            fontSize: 24,
            fontWeight: FontWeight.w700,
            fontFamily: FluentIcons.backspace_24_regular.fontFamily,
            package: FluentIcons.backspace_24_regular.fontPackage,
          ),
        ),
        style: ElevatedButton.styleFrom(
            primary: Color(AppColors.secondaryBackground),
            shape: CircleBorder(),
            // elevation: .618,
            // shadowColor: Color(0xffF5F7FA)
            elevation: 0),
      ),
    ]
        .map((e) => Container(
              decoration: BoxDecoration(boxShadow: [
                BoxShadow(
                    color: Color(AppColors.primaryColor).withOpacity(0.1),
                    blurRadius: 48,
                    offset: Offset(20, 32),
                    spreadRadius: -16)
              ]),
              child: e,
            ))
        .toList();
    numPadKeys.addAll(bottomKeys);
    _transactionAmountController =
        TextEditingController(text: _controllerHelperText);
    _transactionAmountController.value = TextEditingValue(
      text: this._controllerHelperText,
    );

    initializeTransactionReceipt();
  }

  @override
  void dispose() {
    _transactionAmountController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // backgroundColor: Colors.white,
      backgroundColor: Color(AppColors.primaryBackground),
      appBar: AppBar(
        title: Text("$transactionButton Money"),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        foregroundColor: Color(AppColors.secondaryText),
      ),
      body: Column(
        children: [
          Container(
            margin: EdgeInsets.symmetric(horizontal: 27, vertical: 3),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(20)),
              boxShadow: <BoxShadow>[
                BoxShadow(
                    /*
                    color: Color(0xffF5F7FA),
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
                  child: FutureBuilder<int>(
                    // future: checkUrlValidity(
                    //     "${ApiConstants.baseUrl}../storage/images/hadwin_images/brands_and_businesses/${widget.otherParty['avatar']}"),
                    builder: (context, snapshot) {
                      Widget contactImage;
                      if (widget.otherParty.containsKey('avatar') &&
                          snapshot.hasData) {
                        contactImage = ClipOval(
                          child: AspectRatio(
                            aspectRatio: 1.0 / 1.0,
                            child: Image.network(
                              "${widget.otherParty['avatar']}",
                              height: 72,
                              width: 72,
                              fit: BoxFit.contain,
                            ),
                          ),
                        );
                      } else {
                        contactImage = Text(
                          widget.otherParty['name'][0].toUpperCase(),
                          style: TextStyle(
                              fontSize: 20,
                              color: Color(AppColors.primaryColorDim)),
                        );
                      }

                      return contactImage;
                    },
                  ),
                ),
                title: Text(
                  widget.otherParty['name'],
                  style: TextStyle(
                      fontSize: 13, color: Color(AppColors.secondaryColorDim)),
                ),
                subtitle: Text(
                  tileSubtitle,
                  style: TextStyle(
                      fontSize: 11, color: Color(AppColors.secondaryText)),
                )),
          ),
          Padding(
            padding: EdgeInsets.symmetric(horizontal: 27, vertical: 13),
            child: TextField(
              keyboardType: TextInputType.none,
              controller: _transactionAmountController,
              style: TextStyle(
                  fontSize: 40,
                  fontWeight: FontWeight.w600,
                  color: Color(AppColors.secondaryText)),
              decoration: InputDecoration(
                contentPadding:
                    EdgeInsets.symmetric(vertical: 10, horizontal: 18),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide: BorderSide(
                        color: Color(AppColors.primaryColorDim), width: 2.0)),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(20),
                    borderSide:
                        BorderSide(color: Color(AppColors.secondaryColorDim))),
                prefix: Container(
                    margin: EdgeInsets.only(right: 10),
                    child: Text(
                      "Rs.",
                      style: GoogleFonts.manrope(
                          fontSize: 40,
                          fontWeight: FontWeight.w600,
                          color: Color(AppColors.secondaryText)),
                    )),
              ),
            ),
          ),
          Expanded(
            child: Container(
              height: 190,
              padding: EdgeInsets.symmetric(horizontal: 9),
              child: GridView.count(
                crossAxisCount: 3,
                children: numPadKeys,
                crossAxisSpacing: 2,
                mainAxisSpacing: 5,
                childAspectRatio: 1.55,
              ),
            ),
          ),
          Container(
            width: MediaQuery.of(context).size.width - 45,
            height: 64,
            decoration: BoxDecoration(
              boxShadow: [
                BoxShadow(
                    color: Color(AppColors.shadowColor),
                    offset: Offset(0, 4),
                    blurRadius: 5.0)
              ],
              color: Color(AppColors
                  .primaryColorDim), // the middle one among 3 colors if possible
              borderRadius: BorderRadius.circular(20),
            ),
            child: ElevatedButton(
              onPressed: _makeTransaction,
              child: Text(transactionButton),
              style: ElevatedButton.styleFrom(
                  primary: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20))),
            ),
          ),
          SizedBox(
            height: 10,
          )
        ],
      ),
    );
  }

  void _updateHelperText(String k) {
    var cursorPos = _transactionAmountController.selection.base.offset;
    int editedOffset = _controllerHelperText.length;

    String suffixText = '', prefixText = '';

    if (cursorPos >= 0 && cursorPos < _controllerHelperText.length) {
      suffixText = _controllerHelperText.substring(cursorPos);
      prefixText = _controllerHelperText.substring(0, cursorPos);
    }

    setState(() {
      if (_controllerHelperText == "0.00") {
        _controllerHelperText = k;
        editedOffset = _controllerHelperText.length;
      } else if (cursorPos == -1 || cursorPos == _controllerHelperText.length) {
        _controllerHelperText += k;
        editedOffset = _controllerHelperText.length;
      } else {
        _controllerHelperText = prefixText + k + suffixText;
        editedOffset = cursorPos + 1;
      }
    });
    _transactionAmountController.value = TextEditingValue(
      text: _controllerHelperText,
      selection: TextSelection.fromPosition(TextPosition(offset: editedOffset)),
    );
  }

  late List<Container> bottomKeys;
  late List<Container> numPadKeys;

  void setUserData() async {
    userData = await UserDataStorage().getUserData();

    transactionReceipt['transactionInitiatorName'] =
        userData['first_name'] + " " + userData['last_name'];
    transactionReceipt['transactionInitiatorEmail'] = userData['email'];
    transactionReceipt['transactionInitiatorPhoneNumber'] =
        userData['phone_number'];
    transactionReceipt['transactionInitiatorBankName'] =
        userData['bankDetails'][0]['bankName'];
    transactionReceipt['transactionInitiatorBankAccountNo'] =
        userData['bankDetails'][0]['accountNumber'];
    transactionReceipt['transactionInitiatorUid'] = userData['uid'];
    transactionReceipt['transactionInitiatorWalletAddress'] =
        userData['walletAddress'];
  }

  Container _createButton(digit) => Container(
        decoration: BoxDecoration(boxShadow: [
          BoxShadow(
              color: Color(AppColors.shadowColor),
              blurRadius: 48,
              offset: Offset(20, 32),
              spreadRadius: -16)
        ]),
        child: ElevatedButton(
          onPressed: () => _addDigits(digit),
          child: Text(
            digit.toString(),
            style: TextStyle(
                color: Color(AppColors.secondaryText),
                fontSize: 24,
                fontWeight: FontWeight.w700),
          ),
          style: ElevatedButton.styleFrom(
            primary: Color(AppColors.secondaryBackground),
            shape: CircleBorder(),
            elevation: 0,
            // shadowColor: Color(0xffF5F7FA)
          ),
        ),
      );

  void _addDigits(int digit) {
    int cursorPos = _transactionAmountController.selection.base.offset;
    //? detect cursor position
    int validPos = cursorPos == -1 ? 0 : cursorPos;

    String desiredAmount =
        _transactionAmountController.text.substring(0, validPos) +
            digit.toString() +
            _transactionAmountController.text.substring(validPos);
    if (double.parse(desiredAmount) <= 10000 ||
        _transactionAmountController.text.isEmpty) {
      if (_controllerHelperText == "0.00") {
        _updateHelperText(digit.toString());
      } else if (!_controllerHelperText.contains('.')) {
        _updateHelperText(digit.toString());
      } else if (_controllerHelperText.contains('.') &&
          cursorPos <= _transactionAmountController.text.length - 3) {
        _updateHelperText(digit.toString());
      } else if (_controllerHelperText.contains('.') &&
          _controllerHelperText.split('.').last.length < 2) {
        _updateHelperText(digit.toString());
      }
    }
  }

  void _addZeroes() {
    int cursorPos = _transactionAmountController.selection.base.offset;

    int validPos = cursorPos == -1 ? 0 : cursorPos;

    String desiredAmount =
        _transactionAmountController.text.substring(0, validPos) +
            '0' +
            _transactionAmountController.text.substring(validPos);

    if (double.parse(desiredAmount) <= 10000 ||
        _transactionAmountController.text.isEmpty) {
      if (_controllerHelperText != "0.00" &&
          _controllerHelperText.length != 0) {
        if (!_controllerHelperText.contains('.')) {
          _updateHelperText('0');
        } else if (_controllerHelperText.contains('.') &&
            cursorPos <= _transactionAmountController.text.length - 3) {
          _updateHelperText('0');
        } else if (_controllerHelperText.contains('.') &&
            _controllerHelperText.split('.').last.length < 2) {
          _updateHelperText('0');
        }
      }
    }
  }

  void _addDecimal() {
    if (!_controllerHelperText.contains(".")) {
      setState(() {
        _controllerHelperText += ".";
      });
      _transactionAmountController.value = TextEditingValue(
        text: _controllerHelperText,
        selection: TextSelection.fromPosition(
          TextPosition(offset: _controllerHelperText.length),
        ),
      );
    }
  }

//? FUNCTIONS FOR DELETE BUTTON
  void _eraseDigits() {
    if (_controllerHelperText.length > 0) {
      var cursorPos = _transactionAmountController.selection.base.offset;
      int editedOffset = _controllerHelperText.length;

      setState(() {
        if (cursorPos == -1) {
          _controllerHelperText = _controllerHelperText.substring(
              0, _controllerHelperText.length - 1);
          editedOffset = _controllerHelperText.length;
        } else if (cursorPos == _controllerHelperText.length) {
          _controllerHelperText =
              _controllerHelperText.substring(0, cursorPos - 1);
          editedOffset = _controllerHelperText.length;
        } else if (cursorPos > 0 && cursorPos < _controllerHelperText.length) {
          _controllerHelperText =
              _controllerHelperText.substring(0, cursorPos - 1) +
                  _controllerHelperText.substring(
                      cursorPos, _controllerHelperText.length);
          editedOffset = cursorPos - 1;
        }
      });

      _transactionAmountController.value = TextEditingValue(
        text: _controllerHelperText,
        selection:
            TextSelection.fromPosition(TextPosition(offset: editedOffset)),
      );
    }
  }

  void _clearTransactionAmount() {
    setState(() {
      _controllerHelperText = "0.00";
    });
    _transactionAmountController.clear();
    _transactionAmountController.value = TextEditingValue(
      text: _controllerHelperText,
      selection: TextSelection.fromPosition(
        TextPosition(offset: _controllerHelperText.length),
      ),
    );
  }

  Future<void> _makeTransaction() async {
    transactionReceipt['transactionAmount'] =
        double.parse(_transactionAmountController.text).toStringAsFixed(2);
    if (int.parse(transactionReceipt['transactionAmount'].split('.')[1]) == 0) {
      transactionReceipt['transactionAmount'] =
          double.parse(_transactionAmountController.text).toStringAsFixed(0);
    }
    Navigator.of(context).pop();
    Navigator.push(
        context,
        SlideRightRoute(
            page: TransactionProcessingScreen(
                transactionReceipt: transactionReceipt)));
  }

  void initializeTransactionReceipt() {
    transactionReceipt['transactionType'] = widget.transactionType;

    transactionReceipt['transactionMemberName'] = widget.otherParty['name'];
    transactionReceipt['transactionMemberWalletAddress'] =
        widget.otherParty['walletAddress'];
    if (widget.otherParty.containsKey('homepage')) {
      transactionReceipt['transactionMemberBusinessWebsite'] =
          widget.otherParty['homepage'];
    } else {
      transactionReceipt['transactionMemberEmail'] =
          widget.otherParty['emailAddress'];
      transactionReceipt['transactionMemberPhoneNumber'] =
          widget.otherParty['phoneNumber'];
    }

    if (widget.otherParty.containsKey('avatar')) {
      transactionReceipt['transactionMemberAvatar'] =
          widget.otherParty['avatar'];
    }

    if (widget.otherParty.containsKey('gender')) {
      transactionReceipt['transactionMemberGender'] =
          widget.otherParty['gender'];
    }

    //? TILE SUBTITLE TEXT
    if (widget.otherParty.containsKey('emailAddress') &&
        widget.otherParty.containsKey('avatar')) {
      tileSubtitle = widget.otherParty['emailAddress'];
    } else if (widget.otherParty.containsKey('homepage') &&
        widget.otherParty.containsKey('avatar')) {
      tileSubtitle = widget.otherParty['homepage'];
    } else {
      tileSubtitle = widget.otherParty['homepage'] ?? "";
    }
  }
}
