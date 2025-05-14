import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import '../auth/privacy_policy.dart';
import '../misc/colors.dart';
import '../misc/custom widgets/appbar/auth_bar.dart';
import '../misc/custom widgets/buttons/custom_buttons.dart';
import '../misc/custom widgets/buttons/radio_button.dart';
import '../misc/custom widgets/dialogs/alert_dialog.dart';
import '../misc/custom widgets/dialogs/confirmation_dialog.dart';
import '../misc/widget_method.dart';


class BanAppealPage extends StatefulWidget {

  const BanAppealPage({super.key});

  @override
  _BanAppealPageState createState() => _BanAppealPageState();
}
class _BanAppealPageState extends State<BanAppealPage> {


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const AuthBar(
        automaticallyImplyLeading: true,
        title: 'Report A Problem',
        color: DeckColors.primaryColor,
        fontSize: 24,
      ),
      backgroundColor: DeckColors.backgroundColor,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
                child: Text('Found something on Deck that doesn’t '
                    'seem right? Help us improve Deck by reporting it.',
                  textAlign: TextAlign.justify,
                  style: TextStyle(
                    fontFamily: 'Nunito-Regular',
                    color: DeckColors.primaryColor,
                    fontSize: 16,
                    height: 1.3,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 20.0),
                child: Text('Title of your Appeal',
                  style: TextStyle(
                    fontFamily: 'Fraiche',
                    color: DeckColors.primaryColor,
                    fontSize: 32,
                    height: 1.1,
                  ),
                ),
              ),

              ///this section informs the user about the consequences or actions that will occur upon submitting the form.
              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0),
                child: Wrap(
                  alignment: WrapAlignment.start,
                  children: [
                    const Text('By submitting this form, you agree to Deck'
                        ' processing your information as outlined in our',
                      textAlign: TextAlign.justify,
                      style: TextStyle(
                        fontFamily: 'Nunito-Regular',
                        color: DeckColors.primaryColor,
                        fontSize: 16,
                        height: 1.3,
                      ),
                    ),
                    ///this handles when user clicks the privacy policy
                    InkWell(
                      onTap: () {
                        Navigator.of(context).push(
                          RouteGenerator.createRoute(const PrivacyPolicyPage()),
                        );
                      },
                      borderRadius: BorderRadius.circular(8),
                      splashColor: DeckColors.primaryColor.withOpacity(0.5),
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Text(
                          'Privacy Policy',
                          style: TextStyle(
                            fontFamily: 'Nunito-ExtraBold',
                            color: DeckColors.primaryColor,
                            fontSize: 16,
                            decoration: TextDecoration.underline,
                            decorationColor: DeckColors.primaryColor,
                            decorationThickness: 3,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
              ///------ E N D ---------

              Padding(
                padding: const EdgeInsets.only(left: 15.0, right: 15.0, top:10, bottom: 20),
                child: BuildButton(
                  onPressed: () {
                    showDialog<bool>(
                      context: context,
                      barrierDismissible: false,
                      builder: (BuildContext context) {
                        return CustomAlertDialog(
                            imagePath: 'assets/images/Deck-Dialogue3.png',
                            title: 'Report Submitted',
                            message: 'Thanks for helping keep Deck a safe space for everyone.',
                            button1: 'Ok',
                            onConfirm: () {
                              ///Pop twice: first, close the dialog, then navigate back to the previous page
                              Navigator.pop(context);
                              Navigator.pop(context);
                            }
                        );
                      },

                    );
                  },
                  buttonText: 'Submit',
                  height: 50.0,
                  width: MediaQuery.of(context).size.width,
                  backgroundColor: DeckColors.primaryColor,
                  textColor: DeckColors.white,
                  radius: 10.0,
                  borderColor: DeckColors.primaryColor,
                  fontSize: 16,
                  borderWidth: 0,
                ),
              ),
              Image.asset(
                'assets/images/Deck-Bottom-Image1.png',
                fit: BoxFit.fitWidth,
                width: MediaQuery.of(context).size.width,
              ),
            ],
          ),
        ),
      ),

    );
  }
}