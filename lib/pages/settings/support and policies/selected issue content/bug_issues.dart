import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../../../misc/colors.dart';
import '../../../misc/custom widgets/dialogs/confirmation_dialog.dart';
import '../../../misc/custom widgets/images/screenshot_image.dart';
import '../../../misc/custom widgets/textboxes/textboxes.dart';

class BugIssues extends StatefulWidget {

  @override
  _BugIssuesState createState() => _BugIssuesState();
}
  class _BugIssuesState extends State<BugIssues>{
  final detailsController = TextEditingController();
  bool hasUploadedImages = false;

  ///This tracks if images are uploaded
  void _onImageUploadChange(bool hasImages) {
    setState(() {
      hasUploadedImages = hasImages;
    });
  }

  ///This tracks if there are unsaved changes
  bool _hasUnsavedChanges() {
    return detailsController.text.isNotEmpty ||
        hasUploadedImages;
  }

  ///This disposes controllers to free resources and prevent memory leaks
  @override
  void dispose() {
    detailsController.dispose();
    super.dispose();
  }
  
    @override
    Widget build(BuildContext context){
      return PopScope(
        canPop: false,
        onPopInvoked: (bool didPop) async {
          if (didPop) {
            return;
          }

          //Check for unsaved changes
          if (_hasUnsavedChanges()) { // TODO FIX THIS
            /* final shouldPop = await showDialog<bool>(
              context: context,
              builder: (BuildContext context) {
                return ShowConfirmationDialog(
                  title: 'Are you sure you want to go back?',
                  text: 'If you go back now, you will lose all your progress',
                  onConfirm: () {
                    Navigator.of(context).pop(); //Return true to allow pop
                  },
                  onCancel: () {
                    //Return false to prevent pop
                  },
                );
              },
            );

            //If the user confirmed, pop the current route
            if (shouldPop == true) {
              Navigator.of(context).pop(true);
            }*/ 
          } else {
            //No unsaved changes, allow pop without confirmation
            Navigator.of(context).pop(true);
          }
        },
        child: Padding(
            padding: EdgeInsets.only(left: 15, right: 15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Tell us what you were doing in Deck when you saw the bug, '
                    'and what you expected to happen instead. Include as much '
                    'detail as possible.',
                style: TextStyle(
                  fontFamily: 'Fraiche',
                  fontSize: 24,
                  color: DeckColors.primaryColor,
                  height: 1.2,
                ),
              ),
              ///Textbox to enter additional details about the bug issues content being reported
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: BuildTextBox(
                  showPassword: false,
                  hintText: 'Enter additional details',
                  controller: detailsController,
                  isMultiLine: true,
                ),
              ),
              ///----- E N D ------
              const Padding(
                padding: EdgeInsets.only(left: 15.0, right: 15.0, top: 5.0),
                child: Text('Don’t include any sensitive information such as you password in your message.',
                  style: TextStyle(
                    fontFamily: 'Nunito-Regular',
                    color: DeckColors.primaryColor,
                    fontSize: 12,
                    height: 1,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(top: 10.0),
                child: Text(
                  'Attach a screenshot of the content you’re reporting',
                  style: TextStyle(
                    fontFamily: 'Fraiche',
                    fontSize: 24,
                    color: DeckColors.primaryColor,
                  ),
                ),
              ),
               Center(
                child: Padding(
                  padding: EdgeInsets.only(top: 10),
                  ///This calls the screen shot images containers
                  child: BuildScreenshotImage(
                    onImageUploadChange: _onImageUploadChange,
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.only(bottom: 15.0),
                child: Center(
                  child: Text('Upload up to 3 PNG or JPG files. Max file size 10 MB.',
                    style: TextStyle(
                      fontFamily: 'Nunito-Regular',
                      color: DeckColors.primaryColor,
                      fontSize: 12,
                      height: 1,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      );
    }
  }


