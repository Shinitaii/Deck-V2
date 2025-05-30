import 'dart:io';
import 'package:deck/pages/misc/custom%20widgets/dialogs/alert_dialog.dart';
import 'package:flutter/material.dart';
import 'package:deck/pages/misc/colors.dart';
import 'package:deck/pages/misc/custom%20widgets/appbar/learn_mode_bar.dart';
import 'package:deck/pages/misc/custom%20widgets/buttons/custom_buttons.dart';
import 'package:file_picker/file_picker.dart';
import 'package:deck/pages/misc/custom widgets/dialogs/confirmation_dialog.dart';

import '../../../backend/models/deck.dart';
import '../../../backend/models/quiz.dart';
import '../../misc/widget_method.dart';
import '../quiz_results.dart';

class QuizMultChoice extends StatefulWidget {
  final List<QuizQuestion?> questions;
  final Deck deck;
  const QuizMultChoice({super.key, required this.deck, required this.questions});

  @override
  _QuizMultChoiceState createState() => _QuizMultChoiceState();
}

class _QuizMultChoiceState extends State<QuizMultChoice> {
  int currentQuestionIndex = 0; //to track the current question
  String title = '';
  String question = '';
  String choice1 = '';
  String choice2 = '';
  String choice3 = '';
  String choice4 = '';
  int score = 0;
  // Each result: { questionId: String, isCorrect: bool }
  final List<Map<String, dynamic>> results = [];

  ///List to hold all the questions
  late final List<Map<String, dynamic>> questions;
  ///Choices data
  late List<Map<String, dynamic>> containerData;

  @override
  void initState() {
    super.initState();

    questions = widget.questions.map((quizQuestion) {
      return {
        'id': quizQuestion!.id,
        'relatedFlashcardId': quizQuestion.relatedFlashcardId,
        'question': quizQuestion.question,
        'choices': quizQuestion.choices.map((choice) => choice.text).toList(),
        'correctIndex': quizQuestion.choices.indexWhere((choice) => choice.isCorrect),
      };
    }).toList();
    loadQuestion(currentQuestionIndex);
  }

  //Show question and choices based on index
  void loadQuestion(int index) {
    var currentQuestion = questions[index];
    setState(() {
      question = currentQuestion['question'];
      choice1 = currentQuestion['choices'][0];
      choice2 = currentQuestion['choices'][1];
      choice3 = currentQuestion['choices'][2];
      choice4 = currentQuestion['choices'][3];
    });

    //Update containerData for choices
    containerData = [
      {
        'text': choice1,
        'color': Colors.red.shade300,
      },
      {
        'text': choice2,
        'color': Colors.greenAccent,
      },
      {
        'text': choice3,
        'color': DeckColors.deckYellow,
      },
      {
        'text': choice4,
        'color': DeckColors.deckBlue,
      },
    ];
  }

  //Handle choice selection
  void handleChoiceSelection(int choiceIndex) {
    var currentQuestion = questions[currentQuestionIndex];
    bool isCorrect = choiceIndex == currentQuestion['correctIndex'];

    // Record result
    results.add({
      'questionId': currentQuestion['id'],
      'questionIndex' : currentQuestionIndex + 1,
      'question': currentQuestion['question'],
      'isCorrect': isCorrect,
      'selectedIndex': choiceIndex,
      'correctIndex': currentQuestion['correctIndex'],
    });

    if (isCorrect) score++;
    print(score);

    //Move to the next question
    if (currentQuestionIndex < questions.length - 1) {
      setState(() {
        currentQuestionIndex++;
        loadQuestion(currentQuestionIndex);
      });
    } else {
      //end of quiz, show dialog
      showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context){
            return CustomAlertDialog(
             imagePath: 'assets/images/Deck-Dialogue3.png',
              title: 'Quiz Finished!',
              message: 'Congratulations, wanderer! You\'ve completed the quiz!',
              button1: 'Ok',
              onConfirm: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  RouteGenerator.createRoute(QuizResults(result: results, score: score, deckId: widget.deck.deckId, quizType: "MULTIPLE_CHOICE_QUIZ",)),
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
              'Stop Now? You\'ll lose all your progress',
              'Stop',
                  () {
                    ///Pop twice: first, close the dialog, then navigate back to the previous page
                    Navigator.of(context).pop();
                    Navigator.of(context).pop();
                  },
            );
        },
        buttonText: 'Stop Playing',
        buttonIcon: Icons.play_arrow_rounded,
        buttonColor: DeckColors.deckRed,
        borderButtonColor: DeckColors.deckRed,
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 15.0, left: 15.0, right: 15.0),
              child: Column(
                children: [
                  Text(
                    widget.deck.title,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontFamily: 'Fraiche',
                      color: DeckColors.primaryColor,
                      fontSize: 40,
                      height: 1.1,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 15.0),
                    child: Container(
                      height: 550,
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
                              child: Container(
                                height: 100,
                                child: SingleChildScrollView(
                                  child: Text(
                                    question.isNotEmpty
                                        ? question
                                        : 'A very long sample description of a terminology that should reach 3 lines in this card.',
                                    style: const TextStyle(
                                      fontFamily: 'Nunito-Regular',
                                      color: DeckColors.primaryColor,
                                      fontSize: 16,
                                    ),
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                              ),
                            ),
                            const Divider(
                              color: DeckColors.primaryColor,
                              thickness: 2,
                            ),
                            Expanded(
                              child: ListView.builder(
                                itemCount: containerData.length,
                                itemBuilder: (context, index) {
                                  var data = containerData[index];
                                  return Padding(
                                    padding: const EdgeInsets.only(top: 10.0),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: Ink(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(15),
                                          color: data['color'],
                                        ),
                                        child: InkWell(
                                          onTap: () {
                                            handleChoiceSelection(index);
                                          },
                                          splashColor: Colors.white.withOpacity(0.2),
                                          highlightColor: Colors.white.withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(15),
                                          child: Container(
                                            width: double.infinity,
                                            height: 3 * 26.0,
                                            padding: const EdgeInsets.all(10.0),
                                            child: Center(
                                              child: SingleChildScrollView(
                                                child: Text(
                                                  data['text'],
                                                  style: const TextStyle(
                                                    fontFamily: 'Fraiche',
                                                    color: DeckColors.primaryColor,
                                                    fontSize: 24,
                                                    height: 1.1,
                                                  ),
                                                  overflow: TextOverflow.visible,
                                                  textAlign: TextAlign.center,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  );
                                },
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
                      height: 70,
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
                            color: DeckColors.primaryColor
                          ),
                        ),
                      )
                    ),
                  )
                ],
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
    );
  }
}
