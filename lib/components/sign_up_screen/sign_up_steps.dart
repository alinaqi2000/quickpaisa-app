import 'package:fluentui_system_icons/fluentui_system_icons.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:quickpaisa/components/main_app_screen/tabbed_layout_component.dart';
import 'package:quickpaisa/components/sign_up_screen/choose_username_screen.dart';
import 'package:quickpaisa/components/sign_up_screen/step_get_bank_account.dart';
import 'package:quickpaisa/components/sign_up_screen/step_get_email_password.dart';
import 'package:quickpaisa/components/sign_up_screen/step_get_name_address.dart';
import 'package:quickpaisa/database/cards_storage.dart';
import 'package:quickpaisa/database/login_info_storage.dart';
import 'package:quickpaisa/database/successful_transactions_storage.dart';
import 'package:quickpaisa/database/user_data_storage.dart';
import 'package:quickpaisa/providers/user_login_state_provider.dart';
import 'package:quickpaisa/resources/colors.dart';
import 'package:quickpaisa/utilities/quickpaisa_markdown_viewer.dart';

import 'package:quickpaisa/utilities/make_api_request.dart';
import 'package:quickpaisa/utilities/display_error_alert.dart';
import 'package:quickpaisa/utilities/slide_right_route.dart';

class SignUpSteps extends StatefulWidget {
  const SignUpSteps({Key? key}) : super(key: key);

  @override
  _SignUpStepsState createState() => _SignUpStepsState();
}

class _SignUpStepsState extends State<SignUpSteps> {
  late PageController _signUpStepController;
  LoginInfoStorage loginInfoStorage = LoginInfoStorage();

  final namesKeys = LabeledGlobalKey<FormState>("nameAddressForm");
  final emailPhoneKeys = LabeledGlobalKey<FormState>("emailPasswordForm");
  final passwordKeys = LabeledGlobalKey<FormState>("bankAccountForm");
  Map<String, String> signUpDetails = {
    'first_name': '',
    'last_name': '',
    'username': '',
    'email': '',
    'phone_number': '',
    'password': '',
  };
  Map<String, String> registraionDetails() => signUpDetails;
  int _currentStep = 0;
  List<bool> stepHasError = [false, false, false];
  List<bool> stepCompletedSuccessfully = [false, false, false];
  late List<Widget> signUpStepContent;
  bool confirmSignUpButton = false;
  @override
  void initState() {
    _signUpStepController = PageController();
    signUpStepContent = [
      StepNames(
        registrationDetails: registraionDetails,
        updateSignUpDetails: updateSignUpDetails,
        namesKeys: namesKeys,
        proceedToNextStep: _proceedToNextStep,
      ),
      StepEmailPhone(
        updateSignUpDetails: updateSignUpDetails,
        emailPhoneKeys: emailPhoneKeys,
        registrationDetails: registraionDetails,
        proceedToNextStep: _proceedToNextStep,
      ),
      StepPassword(
        updateSignUpDetails: updateSignUpDetails,
        passwordKeys: passwordKeys,
        registrationDetails: registraionDetails,
        showConfirmSignUpButton: showConfirmSignUpButton,
        finalStepProccessing: _finalStepProccessing,
      )
    ];

    super.initState();
  }

  @override
  void dispose() {
    _signUpStepController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        width: double.infinity,
        child: Column(
          children: [
            Container(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [0, 1, 2]
                    .map((e) => Wrap(
                          crossAxisAlignment: WrapCrossAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () => changeStepOnTap(e),
                              child: CircleAvatar(
                                  backgroundColor: stepHasError[e]
                                      ? Colors.red.shade600
                                      : !stepCompletedSuccessfully[e]
                                          ? Color(AppColors.secondaryBackground)
                                          : Color(AppColors.primaryColorDim),
                                  foregroundColor: !stepCompletedSuccessfully[e]
                                      ? Color(AppColors.primaryColorDim)
                                      : Colors.white,
                                  radius: 18,
                                  child: stepHasError[e]
                                      ? Icon(
                                          FluentIcons.warning_16_filled,
                                          color: Colors.white,
                                        )
                                      : stepCompletedSuccessfully[e]
                                          ? Icon(
                                              FluentIcons.checkmark_16_regular)
                                          : _currentStep == e
                                              ? Icon(FluentIcons.edit_16_filled)
                                              : Text("${e + 1}")),
                            ),
                            if (e < 2)
                              Container(
                                height: 10,
                                width: 70,
                                color: stepCompletedSuccessfully[e]
                                    ? Color(AppColors.primaryColorDim)
                                    : Colors.transparent,
                              ),
                          ],
                        ))
                    .toList(),
              ),
            ),
            SizedBox(
              height: 50,
            ),
            Container(
              width: double.infinity,
              height: _currentStep == 2 ? 230 : 300,
              child: PageView(
                clipBehavior: Clip.none,
                controller: _signUpStepController,
                physics: NeverScrollableScrollPhysics(),
                children: signUpStepContent,
              ),
            ),
            // if (_currentStep == 2)
            //   Padding(
            //       padding:
            //           const EdgeInsets.symmetric(vertical: 3.6, horizontal: 10),
            //       child: RichText(
            //           text: TextSpan(
            //               text: 'By signing up you are agreeing to the ',
            //               style:
            //                   TextStyle(fontSize: 14, color: Color(0xFF929BAB)),
            //               children: <InlineSpan>[
            //             TextSpan(
            //                 text: 'Terms & Conditions',
            //                 style: TextStyle(
            //                     fontSize: 14,
            //                     color: Color(AppColors.secondaryColorDim)),
            //                 recognizer: TapGestureRecognizer()
            //                   ..onTap = () {
            //                     FocusManager.instance.primaryFocus?.unfocus();
            //                     Future.delayed(
            //                         Duration(milliseconds: 300),
            //                         () => Navigator.push(
            //                             context,
            //                             SlideRightRoute(
            //                                 page: quickpaisaMarkdownViewer(
            //                               screenName: "Terms & Conditons",
            //                               urlRequested:
            //                                   'https://raw.githubusercontent.com/brownboycodes/quickpaisa/master/docs/TERMS_AND_CONDITIONS.md',
            //                             ))));
            //                   }),
            //             TextSpan(
            //               text: ' and our ',
            //               style:
            //                   TextStyle(fontSize: 14, color: Color(0xFF929BAB)),
            //             ),
            //             TextSpan(
            //                 text: 'End User License Agreement',
            //                 style: TextStyle(
            //                     fontSize: 14,
            //                     color: Color(AppColors.secondaryColorDim)),
            //                 recognizer: TapGestureRecognizer()
            //                   ..onTap = () {
            //                     FocusManager.instance.primaryFocus?.unfocus();
            //                     Future.delayed(
            //                         Duration(milliseconds: 300),
            //                         () => Navigator.push(
            //                             context,
            //                             SlideRightRoute(
            //                                 page: quickpaisaMarkdownViewer(
            //                               screenName:
            //                                   "End User License Agreement",
            //                               urlRequested:
            //                                   'https://raw.githubusercontent.com/brownboycodes/quickpaisa/master/docs/END_USER_LICENSE_AGREEMENT.md',
            //                             ))));
            //                   })
            //           ]))),
            confirmSignUpButton
                ? Container(
                    margin: const EdgeInsets.symmetric(vertical: 16.0),
                    width: double.infinity,
                    height: 64,
                    child: ElevatedButton(
                        onPressed: _finalStepProccessing,
                        child: Text(
                          'Create Account',
                          style: TextStyle(
                              fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                        style: ElevatedButton.styleFrom(
                          primary: Color(AppColors.primaryColorDim),
                          shadowColor: Color(AppColors.shadowColor),
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(20)),
                        )),
                  )
                : Row(
                    children: [
                      if (_currentStep > 0 && confirmSignUpButton == false)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                              onPressed: _goBackToPreviousStep,
                              child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 3.2,
                                  children: [
                                    Icon(
                                      FluentIcons.arrow_left_16_filled,
                                      color: Color(AppColors.secondaryColorDim),
                                      size: 18,
                                    ),
                                    Text(
                                      'Back',
                                      style: TextStyle(
                                          color: Color(
                                              AppColors.secondaryColorDim),
                                          fontSize: 16),
                                    ),
                                  ]),
                              style: TextButton.styleFrom(
                                primary: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              )),
                        ),
                      Spacer(),
                      if (_currentStep < signUpStepContent.length - 1)
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: TextButton(
                              onPressed: _proceedToNextStep,
                              child: Wrap(
                                  crossAxisAlignment: WrapCrossAlignment.center,
                                  spacing: 3.2,
                                  children: [
                                    Text(
                                      'Next',
                                      style: TextStyle(
                                          color:
                                              Color(AppColors.primaryColorDim),
                                          fontSize: 16),
                                    ),
                                    Icon(
                                      FluentIcons.arrow_right_16_filled,
                                      color: Color(AppColors.primaryColorDim),
                                      size: 18,
                                    )
                                  ]),
                              style: TextButton.styleFrom(
                                primary: Colors.transparent,
                                shadowColor: Colors.transparent,
                                elevation: 0,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(20)),
                              )),
                        ),
                    ],
                  ),
          ],
        ));
  }

  void _finalStepProccessing() {
    FocusManager.instance.primaryFocus?.unfocus();
    _performErrorCheck(_currentStep + 1);

    if (stepHasError[_currentStep] == false && mounted) {
      ScaffoldMessenger.of(context)
          .showSnackBar(
            SnackBar(
              content: Text('Processing'),
              backgroundColor: Color(AppColors.secondaryColorDim),
              // onVisible: _tryRegistering,
            ),
          )
          .closed
          .then((value) => _tryRegistering());
    }
  }

//? FUNCTION TO GO BACK TO PREVIOUS STEP OF THE CURRENT STEP
  void _goBackToPreviousStep() {
    FocusManager.instance.primaryFocus?.unfocus();
    _performErrorCheck(_currentStep - 1);
    if (_currentStep > 0) {
      _signUpStepController.animateToPage(_currentStep - 1,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOutCubic);
      setState(() {
        _currentStep--;
      });
    }
  }

//? FUNCTION TO MOVE TO THE NEXT STEP FROM THE CURRENT STEP
  void _proceedToNextStep() {
    FocusManager.instance.primaryFocus?.unfocus();

    _performErrorCheck(_currentStep + 1);
    if (stepHasError[_currentStep] == false) {
      if (_currentStep < signUpStepContent.length - 1) {
        _signUpStepController.animateToPage(_currentStep + 1,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic);

        setState(() {
          _currentStep++;
        });
      }
    }
  }

  void _moveToStepWithError(int step) {
    FocusManager.instance.primaryFocus?.unfocus();

    _signUpStepController.animateToPage(step,
        duration: Duration(milliseconds: 500), curve: Curves.easeInOutCubic);

    setState(() {
      _currentStep = step;
      stepHasError[step] = true;
    });
  }

//? FUNCTION TO UPDATE SIGN UP DETAILS
  void updateSignUpDetails(String key, String value) {
    setState(() {
      signUpDetails[key] = value;
    });
  }

//? FUNCTION TO TOGGLE VISIBILITY OF SIGN UP BUTTON
  void showConfirmSignUpButton(bool value) {
    if (value != confirmSignUpButton) {
      setState(() {
        confirmSignUpButton = value;
      });
    }
  }

//? FUNCTION TO CHECK FOR ERRORS IN ANY STEPS PRIOR FROM THE ONE REQUESTED
  void _performErrorCheck(int requestedIndex) {
    if (_currentStep < requestedIndex) {
      for (var i = 0; i < requestedIndex; i++) {
        bool errorStatus = false;
        switch (i) {
          case 0:
            namesKeys.currentState?.validate();
            if (signUpDetails["first_name"]!.isEmpty ||
                signUpDetails["last_name"]!.isEmpty ||
                signUpDetails["username"]!.isEmpty) {
              errorStatus = true;
            }

            break;
          case 1:
            emailPhoneKeys.currentState?.validate();
            if (stepCompletedSuccessfully[1]) {
              errorStatus = false;
            } else if (stepCompletedSuccessfully[0] && _currentStep == 1) {
              // emailPhoneKeys.currentState?.validate();
              if (signUpDetails["email"]!.isEmpty ||
                  signUpDetails["phone_number"]!.isEmpty) {
                errorStatus = true;
              }
            } else {
              errorStatus = true;
            }
            break;
          case 2:
            passwordKeys.currentState?.validate();
            if (signUpDetails["password"]!.isEmpty) {
              errorStatus = true;
            }

            break;
        }

        setState(() {
          stepHasError[i] = errorStatus;
          stepCompletedSuccessfully[i] = !stepHasError[i];
        });
        if (errorStatus) {
          break;
        }
      }
    } else {
      for (var i = _currentStep; i >= 0; i--) {
        bool errorStatus = false;
        switch (i) {
          case 0:
            namesKeys.currentState?.validate();
            if (signUpDetails["first_name"]!.isEmpty ||
                signUpDetails["last_name"]!.isEmpty ||
                signUpDetails["username"]!.isEmpty) {
              errorStatus = true;
            }

            break;
          case 1:
            emailPhoneKeys.currentState?.validate();
            if (stepCompletedSuccessfully[1]) {
              errorStatus = false;
            } else if (stepCompletedSuccessfully[0] && _currentStep == 1) {
              // emailPhoneKeys.currentState?.validate();
              if (signUpDetails["email"]!.isEmpty ||
                  signUpDetails["phone_number"]!.isEmpty) {
                errorStatus = true;
              }
            } else {
              errorStatus = true;
            }
            break;
          case 2:
            passwordKeys.currentState?.validate();
            if (signUpDetails["password"]!.isEmpty) {
              errorStatus = true;
            }
            break;
        }

        setState(() {
          stepHasError[i] = errorStatus;
          stepCompletedSuccessfully[i] = !stepHasError[i];
        });
        if (errorStatus) {
          break;
        }
      }
    }
  }

  void _tryRegistering() {
    sendData(urlPath: 'auth/register', data: signUpDetails)
        .then((response) async {
      ScaffoldMessenger.of(context).hideCurrentSnackBar();

      if (response.keys.join().toLowerCase().contains("error")) {
        if (response.values.join().toLowerCase().contains("username") ||
            response.values.join().toLowerCase().contains("first") ||
            response.values.join().toLowerCase().contains("last")) {
          _moveToStepWithError(0);
        } else if (response.values.join().toLowerCase().contains("email") ||
            response.values.join().toLowerCase().contains("phone")) {
          _moveToStepWithError(1);
        } else if (response.values.join().toLowerCase().contains("password")) {
          _moveToStepWithError(2);
        }
        showErrorAlert(context, response);
      } else {
        final status = await Future.wait([
          _saveLoggedInUserData(
              response['authorization_token'], response['user']),
          CardsStorage()
              .initializeAvailableCards(response['authorization_token']),
          SuccessfulTransactionsStorage().initializeSuccessfulTransactions()
        ]);
        // print(status);
        if (status[0] == true && status[1] == true && status[2] == true) {
          ScaffoldMessenger.of(context)
              .showSnackBar(SnackBar(
                  content: Text("Login Successful"),
                  backgroundColor: Colors.green))
              .closed
              .then((value) => Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute(
                      builder: (context) => TabbedLayoutComponent(
                            userData: response['user'],
                          )),
                  (route) => false));
        }

        // Navigator.of(context).pushAndRemoveUntil(
        //     MaterialPageRoute(
        //         builder: (context) => ChooseUsername(
        //               userAuthKey: response['authorization_token'],
        //               userData: response['user'],
        //             )),
        //     (route) => false);
      }
    });
  }

  Future<bool> _saveLoggedInUserData(
      String loggedInUserAuthKey, Map<String, dynamic> user) async {
    try {
      final userIsSaved = await Future.wait([
        UserDataStorage().saveUserData(user),
        loginInfoStorage.setPersistentLoginData(
            user['id'].toString(), loggedInUserAuthKey)
      ]);

      if (mounted) {
        Provider.of<UserLoginStateProvider>(context, listen: false)
            .setAuthKeyValue(loggedInUserAuthKey);

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

//? FUNCTION TO CHANGE STEP ON TAPPING THE OVERHEAD STEP NUMBERS
  void changeStepOnTap(int requestedIndex) {
    FocusManager.instance.primaryFocus?.unfocus();

    if (requestedIndex < _currentStep) {
      _signUpStepController.animateToPage(requestedIndex,
          duration: Duration(milliseconds: 500), curve: Curves.easeInOutCubic);

      _performErrorCheck(requestedIndex);
      setState(() {
        _currentStep = requestedIndex;
      });
    } else if (requestedIndex > _currentStep &&
        requestedIndex != _currentStep) {
      _performErrorCheck(requestedIndex);

      if (!stepHasError.sublist(0, requestedIndex).contains(true)) {
        if (_currentStep < signUpStepContent.length - 1) {
          _signUpStepController.animateToPage(requestedIndex,
              duration: Duration(milliseconds: 500),
              curve: Curves.easeInOutCubic);

          setState(() {
            _currentStep = requestedIndex;
          });
        }
      } else {
        int stepWithError =
            stepHasError.sublist(0, requestedIndex).indexOf(true);
        _signUpStepController.animateToPage(stepWithError,
            duration: Duration(milliseconds: 500),
            curve: Curves.easeInOutCubic);

        setState(() {
          _currentStep = stepWithError;
        });
      }
    }
  }
}
