import 'package:flutter/material.dart';
import 'package:quickpaisa/resources/colors.dart';

class StepNames extends StatefulWidget {
  final LabeledGlobalKey<FormState> namesKeys;
  final Function updateSignUpDetails;

  final Function registrationDetails;
  final Function proceedToNextStep;
  const StepNames(
      {Key? key,
      required this.updateSignUpDetails,
      required this.namesKeys,
      required this.registrationDetails,
      required this.proceedToNextStep})
      : super(key: key);

  @override
  _StepNamesState createState() => _StepNamesState();
}

class _StepNamesState extends State<StepNames> {
  String firstName = "";
  String firstNameErrorMessage = "";
  String lastName = "";
  String lastNameErrorMessage = "";
  String userName = "";
  String userNameErrorMessage = "";

  @override
  void initState() {
    super.initState();
    Map<String, String> signUpDetails = widget.registrationDetails();
    if (mounted) {
      setState(() {
        firstName = signUpDetails['first_name']!;
        lastName = signUpDetails['last_name']!;
        userName = signUpDetails['username']!;
      });
    }
  }

  @override
  void dispose() {
    // widget.namesKeys.currentState?.validate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: widget.namesKeys,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: TextFormField(
                initialValue: firstName,
                validator: _validateFirstName,
                autofocus: mounted,
                autocorrect: false,
                decoration: InputDecoration(
                  fillColor: Color(AppColors.secondaryBackground),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: "first name",
                  hintStyle: TextStyle(
                      fontSize: 16, color: Color(AppColors.secondaryText)),
                ),
                style: TextStyle(
                    fontSize: 16, color: Color(AppColors.secondaryText)),
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
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
            if (firstNameErrorMessage != '')
              Container(
                child: Text(
                  "\t\t\t\t$firstNameErrorMessage",
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(2),
                width: double.infinity,
              ),

            Container(
              width: double.infinity,
              child: TextFormField(
                initialValue: lastName,
                validator: _validateLastName,
                autofocus: mounted,
                autocorrect: false,
                decoration: InputDecoration(
                  fillColor: Color(AppColors.secondaryBackground),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: "last name",
                  hintStyle: TextStyle(
                      fontSize: 16, color: Color(AppColors.secondaryText)),
                ),
                style: TextStyle(
                    fontSize: 16, color: Color(AppColors.secondaryText)),
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
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
            if (lastNameErrorMessage != '')
              Container(
                child: Text(
                  "\t\t\t\t$lastNameErrorMessage",
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(2),
                width: double.infinity,
              ),
            Container(
              width: double.infinity,
              child: TextFormField(
                initialValue: userName,
                validator: _validateUserName,
                autofocus: mounted,
                autocorrect: false,
                decoration: InputDecoration(
                  fillColor: Color(AppColors.secondaryBackground),
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: "username",
                  hintStyle: TextStyle(
                      fontSize: 16, color: Color(AppColors.secondaryText)),
                ),
                style: TextStyle(
                    fontSize: 16, color: Color(AppColors.secondaryText)),
                keyboardType: TextInputType.name,
                textInputAction: TextInputAction.next,
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
            if (userNameErrorMessage != '')
              Container(
                child: Text(
                  "\t\t\t\t$userNameErrorMessage",
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(2),
                width: double.infinity,
              ),

            // input field for RESIDENTIAL-ADDRESS ends here
          ],
        ));
  }

  void errorMessageSetter(String fieldName, String message) {
    setState(() {
      switch (fieldName) {
        case 'FIRST-NAME':
          firstNameErrorMessage = message;
          break;
        case 'LAST-NAME':
          lastNameErrorMessage = message;
          break;
        case 'USER-NAME':
          userNameErrorMessage = message;
          break;
      }
    });
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      errorMessageSetter('FIRST-NAME', 'you must provide your first name');
    } else if (value.length > 100) {
      errorMessageSetter(
          'FIRST-NAME', 'name cannot contain more than 100 characters');
    } else {
      errorMessageSetter('FIRST-NAME', "");

      widget.updateSignUpDetails('first_name', value);
    }

    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      errorMessageSetter('LAST-NAME', 'you must provide your last name');
    } else if (value.length > 100) {
      errorMessageSetter(
          'LAST-NAME', 'name cannot contain more than 100 characters');
    } else {
      errorMessageSetter('LAST-NAME', "");

      widget.updateSignUpDetails('last_name', value);
    }

    return null;
  }

  String? _validateUserName(String? value) {
    if (value == null || value.isEmpty) {
      errorMessageSetter('USER-NAME', 'you must provide your username');
    } else if (value.length > 100) {
      errorMessageSetter(
          'USER-NAME', 'name cannot contain more than 100 characters');
    } else {
      errorMessageSetter('USER-NAME', "");

      widget.updateSignUpDetails('username', value);
    }

    return null;
  }
}
