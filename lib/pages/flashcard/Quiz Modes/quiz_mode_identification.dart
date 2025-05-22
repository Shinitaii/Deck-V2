import 'dart:io';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:deck/pages/misc/colors.dart';
import 'package:deck/pages/misc/custom%20widgets/appbar/learn_mode_bar.dart';
import 'package:deck/pages/misc/custom%20widgets/buttons/custom_buttons.dart';
import 'package:deck/pages/misc/custom%20widgets/textboxes/textboxes.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import '../../misc/custom widgets/dialogs/alert_dialog.dart';
import '../../misc/custom widgets/dialogs/confirmation_dialog.dart';
import '../../misc/widget_method.dart';
import '../quiz_results.dart';

class QuizIdentification extends StatefulWidget {
  const QuizIdentification({super.key});

  @override
  _QuizIdentificationState createState() => _QuizIdentificationState();
}

class _QuizIdentificationState extends State<QuizIdentification> {
  String title = '';
  String question = '';
  final answerController = TextEditingController();
  int currentQuestionIndex = 0; //track the current question
  List<Map<String, String>> questions = [
    {
      'question': 'sino project manager ng group odyssey',
      'answer': 'richmond',
    },
    {
      'question': 'ano ang unang project ng group oydssey',
      'answer': 'archivary',
    },
    {
      'question': 'sino front end leader ng odyssey',
      'answer': 'pole',
    },
    {
      'question': 'ano unang pangalan ng grp odyssey',
      'answer': 'maiteam',
    },
  ];

  //initialize the first question
  @override
  void initState() {
    super.initState();
    question = questions[currentQuestionIndex]['question']!;
  }

  void handleSubmit() {
    String userAnswer = answerController.text.trim();
    var currentQuestion = questions[currentQuestionIndex];

    if (userAnswer == currentQuestion['answer']) {
      print('Correct!');
    } else {
      print('Incorrect!');
    }

    //Move to the next question
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        question = questions[currentQuestionIndex]['question']!;
        answerController.clear();
      });
    } else {
      //end of quiz, show the dialog
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context){
            return CustomAlertDialog(
              imagePath: 'assets/images/Deck-Dialogue3.png',
              title: 'Quiz Finished!',
              message: 'Congratulations, wanderer! You\'ve completed the quiz! Let\'s now take a look at your results!',
              button1: 'Ok',
              onConfirm: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  RouteGenerator.createRoute(const QuizResults()),
                );
              },
            );
          }
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: DeckColors.backgroundColor,
      resizeToAvoidBottomInset: false,
      appBar: LearnModeBar(
        title: 'Quiz Mode',
        color: DeckColors.primaryColor,
        fontSize: 24,
        onButtonPressed: () {
          showConfirmDialog(
              context,
              'assets/images/Deck-Dialogue4.png',
              'Stop Quiz Mode?',
              'Are you sure you want to stop? You will lose all progress if you stop now.',
              'Stop',
                  () {
                ///Pop twice: first, close the dialog, then navigate back to the previous page
                Navigator.of(context).pop();
                Navigator.of(context).pop();
              },
          );
        },
      ),
      body: Stack(
        children: [
          Column(
            children: [
              Expanded(
                child: SingleChildScrollView(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 30.0, vertical: 15.0),
                    child: Column(
                      children: [
                        AutoSizeText(
                          title.isNotEmpty ? title : 'A Very long deck title that is more than 2 lines',
                          overflow: TextOverflow.visible,
                          maxLines: 3,
                          style: const TextStyle(
                            fontFamily: 'Fraiche',
                            color: DeckColors.primaryColor,
                            fontSize: 40,
                            height: 1,
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 15.0),
                          child: Container(
                            height: 400,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: DeckColors.white,
                              border: Border.all(
                                color: DeckColors.primaryColor,
                                width: 3.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.all(15.0),
                                    child: Center(
                                      child: Text(
                                        question,
                                        style: const TextStyle(
                                          fontFamily: 'Nunito-Regular',
                                          color: DeckColors.primaryColor,
                                          fontSize: 16,
                                        ),
                                        textAlign: TextAlign.center,
                                      ),
                                    ),
                                  ),
                                  Spacer(),
                                  const Divider(
                                    color: DeckColors.primaryColor,
                                    thickness: 2,
                                  ),
                                  const Padding(
                                    padding: EdgeInsets.only(top: 10.0),
                                    child: Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Answer',
                                        style: TextStyle(
                                          fontFamily: 'Nunito-Bold',
                                          fontSize: 16,
                                          color: DeckColors.primaryColor,
                                        ),
                                      ),
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 8.0),
                                    child: BuildTextBox(
                                      hintText: 'Type Answer',
                                      controller: answerController,
                                    ),
                                  ),
                                  Padding(
                                    padding: const EdgeInsets.only(top: 15.0),
                                    child: BuildButton(
                                      onPressed: handleSubmit,
                                      buttonText: 'Submit Answer',
                                      height: 50.0,
                                      width: MediaQuery.of(context).size.width,
                                      backgroundColor: DeckColors.primaryColor,
                                      textColor: DeckColors.white,
                                      radius: 10.0,
                                      fontSize: 16,
                                      borderWidth: 3,
                                      borderColor: DeckColors.primaryColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(vertical: 10.0),
                          child: Container(
                            width: MediaQuery.of(context).size.width,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(15.0),
                              color: DeckColors.accentColor,
                              border: Border.all(
                                color: DeckColors.primaryColor,
                                width: 3.0,
                              ),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.1),
                                  spreadRadius: 2,
                                  blurRadius: 20,
                                  offset: const Offset(0, 4),
                                ),
                              ],
                            ),
                            child: Center(
                              child: Text(
                                '${currentQuestionIndex + 1}/${questions.length}',
                                style: const TextStyle(
                                    fontFamily: 'Fraiche',
                                    fontSize: 32,
                                    color: DeckColors.primaryColor),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
              Image.asset(
                'assets/images/Deck-Bottom-Image1.png',
                fit: BoxFit.fitWidth,
                width: MediaQuery.of(context).size.width,
              ),
            ],
          ),
        ],
      ),
    );
  }
}
