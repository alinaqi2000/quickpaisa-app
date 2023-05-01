import 'package:flutter/material.dart';
import 'package:quickpaisa/resources/colors.dart';

class StepEmailPhone extends StatefulWidget {
  final LabeledGlobalKey<FormState> emailPhoneKeys;
  final Function updateSignUpDetails;

  final Function registrationDetails;
  final Function proceedToNextStep;
  const StepEmailPhone(
      {Key? key,
      required this.updateSignUpDetails,
      required this.registrationDetails,
      required this.emailPhoneKeys,
      required this.proceedToNextStep})
      : super(key: key);

  @override
  _StepEmailPhoneState createState() => _StepEmailPhoneState();
}

class _StepEmailPhoneState extends State<StepEmailPhone> {
  String email = "";
  String phone = "";
  String emailErrorMessage = "";
  String phoneErrorMessage = "";
  RegExp validEmailFormat = RegExp(
      r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+");

  @override
  void initState() {
    super.initState();
    Map<String, String> signUpDetails = widget.registrationDetails();
    if (mounted) {
      setState(() {
        email = signUpDetails['email']!;
        phone = signUpDetails['phone_number']!;
      });
    }
  }

  @override
  void dispose() {
    // widget.emailPhoneKeys.currentState?.validate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: widget.emailPhoneKeys,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: TextFormField(
                textInputAction: TextInputAction.next,
                initialValue: email,
                validator: _validateEmailId,
                autofocus: mounted,
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
                  hintText: "email address",
                  hintStyle: TextStyle(fontSize: 16, color: Color(0xFF929BAB)),
                ),
                style: TextStyle(fontSize: 16, color: Color(0xFF929BAB)),
                keyboardType: TextInputType.emailAddress,
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
                        color: Color(AppColors.shadowColor)),
                    BoxShadow(
                        blurRadius: 6.18,
                        spreadRadius: 0.618,
                        offset: Offset(4, 4),
                        color: Color(AppColors.shadowColor))
                  ]),
            ),
            if (emailErrorMessage != '')
              Container(
                child: Text(
                  "\t\t\t\t$emailErrorMessage",
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(2),
              ),
            Container(
              width: double.infinity,
              child: TextFormField(
                initialValue: phone,
                validator: _validatePhone,
                autofocus: mounted,
                autocorrect: false,
                obscureText: false,
                keyboardType: TextInputType.phone,
                enableSuggestions: false,
                textInputAction: TextInputAction.next,
                onFieldSubmitted: (_) => widget.proceedToNextStep(),
                decoration: InputDecoration(
                  fillColor: Color(AppColors.secondaryBackground),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: "phone number",
                  hintStyle: TextStyle(fontSize: 16, color: Color(0xFF929BAB)),
                ),
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
                        color: Color(AppColors.shadowColor)),
                    BoxShadow(
                        blurRadius: 6.18,
                        spreadRadius: 0.618,
                        offset: Offset(4, 4),
                        color: Color(AppColors.shadowColor))
                  ]),
            ),
            if (phoneErrorMessage != '')
              Container(
                child: Text(
                  "\t\t\t\t$phoneErrorMessage",
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(2),
              ),
          ],
        ));
  }

  void errorMessageSetter(String fieldName, String message) {
    setState(() {
      switch (fieldName) {
        case 'EMAIL':
          emailErrorMessage = message;
          break;

        case 'PHONE':
          phoneErrorMessage = message;
          break;
      }
    });
  }

  String? _validateEmailId(String? value) {
    if (value == null || value.isEmpty) {
      errorMessageSetter('EMAIL', 'you must provide a valid email address');
    } else if (!validEmailFormat.hasMatch(value)) {
      errorMessageSetter('EMAIL', 'format of your email address is invalid');
    } else {
      errorMessageSetter('EMAIL', "");
      widget.updateSignUpDetails('email', value);
    }

    return null;
  }

  String? _validatePhone(String? value) {
    if (value == null || value.isEmpty) {
      errorMessageSetter('PHONE', 'phone number cannot be empty');
    } else {
      errorMessageSetter('PHONE', "");

      widget.updateSignUpDetails('phone_number', value);
    }
    return null;
  }
}
