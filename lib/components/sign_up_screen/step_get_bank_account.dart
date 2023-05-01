import 'package:flutter/material.dart';
import 'package:quickpaisa/resources/colors.dart';

class StepPassword extends StatefulWidget {
  final LabeledGlobalKey<FormState> passwordKeys;
  final Function updateSignUpDetails;
  final Function showConfirmSignUpButton;
  final Function registrationDetails;
  final Function finalStepProccessing;
  const StepPassword(
      {Key? key,
      required this.updateSignUpDetails,
      required this.registrationDetails,
      required this.passwordKeys,
      required this.showConfirmSignUpButton,
      required this.finalStepProccessing})
      : super(key: key);

  @override
  _StepPasswordState createState() => _StepPasswordState();
}

class _StepPasswordState extends State<StepPassword> {
  String password = "";
  String passwordErrorMessage = "";
  @override
  void initState() {
    super.initState();
    Map<String, String> signUpDetails = widget.registrationDetails();
    if (mounted) {
      setState(() {
        password = signUpDetails['password']!;
      });
    }
  }

  @override
  void dispose() {
    // widget.passwordKeys.currentState?.validate();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Form(
        key: widget.passwordKeys,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              child: TextFormField(
                initialValue: password,
                onChanged: _toggleSignUpButtonVisibility,
                validator: _validatedPassword,
                autofocus: mounted,
                autocorrect: false,
                obscureText: true,
                onFieldSubmitted: (value) {
                  if (value.isNotEmpty) {
                    widget.finalStepProccessing();
                  }
                },
                decoration: InputDecoration(
                  fillColor: Colors.white,
                  border: InputBorder.none,
                  focusedBorder: InputBorder.none,
                  enabledBorder: InputBorder.none,
                  errorBorder: InputBorder.none,
                  disabledBorder: InputBorder.none,
                  contentPadding:
                      EdgeInsets.only(left: 15, bottom: 11, top: 11, right: 15),
                  hintText: "password",
                  hintStyle: TextStyle(fontSize: 16, color: Color(0xFF929BAB)),
                ),
                style: TextStyle(fontSize: 16, color: Color(0xFF929BAB)),
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
            if (passwordErrorMessage != '')
              Container(
                child: Text(
                  "\t\t\t\t$passwordErrorMessage",
                  style: TextStyle(fontSize: 10, color: Colors.red),
                ),
                margin: EdgeInsets.all(2),
                padding: EdgeInsets.all(2),
              ),
          ],
        ));
  }

  void errorMessageSetter(String message) {
    setState(() {
      passwordErrorMessage = message;
    });
  }

  String? _validatedPassword(String? value) {
    if (value == null || value.isEmpty) {
      errorMessageSetter('you must provide a valid password number');
    } else if (value.length > 25) {
      errorMessageSetter(
          'Password number cannot contain more than 25 characters');
    } else {
      errorMessageSetter("");

      // widget.updateSignUpDetails('password', value);
      setState(() {
        password = value;
      });
    }

    return null;
  }

  void _toggleSignUpButtonVisibility(String value) {
    widget.updateSignUpDetails('password', value);
    if (value.isNotEmpty) {
      widget.showConfirmSignUpButton(true);
    } else {
      widget.showConfirmSignUpButton(false);
    }
  }
}
