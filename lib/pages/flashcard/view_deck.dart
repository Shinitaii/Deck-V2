import 'package:deck/backend/flashcard/flashcard_utils.dart';
import 'package:deck/backend/models/card.dart';
import 'package:deck/pages/flashcard/add_flashcard.dart';
import 'package:deck/pages/flashcard/edit_deck.dart';
import 'package:deck/pages/flashcard/edit_flashcard.dart';
import 'package:deck/pages/flashcard/play_my_deck.dart';
import 'package:deck/pages/misc/colors.dart';
import 'package:deck/pages/misc/deck_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:deck/pages/misc/widget_method.dart';
// import 'package:google_fonts/google_fonts.dart';

import '../../backend/custom_exceptions/api_exception.dart';
import '../../backend/flashcard/flashcard_ai_service.dart';
import '../../backend/models/deck.dart';
import '../../backend/models/quiz.dart';
import '../misc/custom widgets/appbar/auth_bar.dart';
import '../misc/custom widgets/buttons/custom_buttons.dart';
import '../misc/custom widgets/dialogs/alert_dialog.dart';
import '../misc/custom widgets/dialogs/confirmation_dialog.dart';
import '../misc/custom widgets/dialogs/learn_mode_dialog.dart';
import '../misc/custom widgets/functions/if_collection_empty.dart';
import '../misc/custom widgets/functions/loading.dart';
import '../misc/custom widgets/functions/tab_bar.dart';
import '../misc/custom widgets/images/cover_image.dart';
import '../misc/custom widgets/textboxes/textboxes.dart';
import '../misc/custom widgets/tiles/container_of_flashcard.dart';
import '../settings/support and policies/report_a_problem.dart';
import 'Quiz Modes/quiz_mode_identification.dart';
import 'Quiz Modes/quiz_mode_multChoice.dart';

class ViewDeckPage extends StatefulWidget {
  final Deck deck;
  final String filter;
  const ViewDeckPage({super.key, required this.deck, this.filter = "MY_DECKS"});


  @override
  _ViewDeckPageState createState() => _ViewDeckPageState();
}

class _ViewDeckPageState extends State<ViewDeckPage> {
  String coverPhoto = "no_photo";
  String username = '';
  String description = '';
  int numberOfCards = 0;
  bool isSaved = false;
  bool isFetchingMore = false;
  List<Cards> _cardsCollection = [];
  List<Cards> _starredCards = [];
  List<Cards> _filteredCards = [];
  List<Cards> _filteredStarredCards = [];
  bool _canToggleStar = true;
  User? currentUser;
  bool canPressLearn = false;
  bool _isLoading = false;
  final TextEditingController _searchController = TextEditingController();
  static const _toggleCooldown = Duration(milliseconds: 1000);

  @override
  void initState() {
    super.initState();
    isSaved = widget.filter.toString() == "SAVED_DECKS";
    _initDeckCards();
    _getCurrentUser();
    _searchController.addListener(_filterFlashcards);
  }

  /// Initialized the flashcards of the deck
  /// Retrieves the flashcards under the given deck
  Future<void> _initDeckCards() async {
    List<Cards> cards = await widget.deck.getCard();

    // Loop through cards and add those with isStarred == true to starredCards
    List<Cards> starredCards = [];
    for (var card in cards) {
      if (card.isStarred) {
        starredCards.add(card);
      }
    }

    // Assigns the fetched flashcards to the collection
    setState(() {
      _cardsCollection = cards;
      _filteredCards = _cardsCollection;
      _starredCards = starredCards;
      _filteredStarredCards = _starredCards;
      numberOfCards = widget.deck.flashcardCount;
      if(cards.isNotEmpty){
        canPressLearn = true;
      }
    });
  }

  Future<void> _toggleStar(Cards card, bool starred) async {
    if (!_canToggleStar) return;
    _canToggleStar = false;

    try{
      // 1) update the database
      await card.updateStarredStatus(starred, widget.deck.deckId);

      setState(() {
        // 2) update the in-memory flag
        card.isStarred = starred;

        // 3) rebuild your starred master list
        _starredCards = _cardsCollection.where((c) => c.isStarred).toList();

        // 4) re-filter everything
        _filterFlashcards();
      });
    }catch(error){
      Future.delayed(_toggleCooldown, () {
        if (mounted) setState(() => _canToggleStar = true);
      });
    }finally{
      _canToggleStar = true;
    }
  }

  void _filterFlashcards() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredCards = _cardsCollection
          .where((card) =>
      card.term.toLowerCase().contains(query) ||
          card.definition.toLowerCase().contains(query))
          .toList();
      FlashcardUtils().sortByTerm(_filteredCards);

      _filteredStarredCards = _starredCards
          .where((card) =>
      card.term.toLowerCase().contains(query) ||
          card.definition.toLowerCase().contains(query))
          .toList();
      FlashcardUtils().sortByTerm(_filteredCards);
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  ///Retrieve the currently signed-in user from Firebase Authentication
  void _getCurrentUser() {
    setState(() {
      currentUser = FirebaseAuth.instance.currentUser;
      isSaved = (widget.deck.userId == currentUser!.uid);
    });
  }

  @override
  Widget build(BuildContext context) {
    double topPadding =
        (_cardsCollection.isNotEmpty)
            ? 20.0
            : 40.0;
    return Scaffold(
      backgroundColor: DeckColors.backgroundColor,
      appBar:  AuthBar(
        automaticallyImplyLeading: true,
        title: 'View Deck',
        color: DeckColors.primaryColor,
        fontSize: 24,
          showPopMenu: true,
          items: (widget.deck.userId == currentUser!.uid)
              ? [widget.deck.isPrivate ? 'Publish Deck' : 'Unpublish Deck', 'Edit Deck Info',  'Report Deck', 'Delete Deck'] ///Owner
              : [isSaved ? 'Unsave Deck' : 'Save Deck', 'Report Deck'], ///Not owner
          icons: (widget.deck.userId == currentUser!.uid) ? [
            widget.deck.isPrivate ? Icons.undo_rounded : Icons.publish_rounded,
            DeckIcons.pencil,
            Icons.report,
            DeckIcons.trash_bin,
          ]///Owner
              : [
            isSaved? Icons.remove_circle : Icons.save,
            Icons.report,
          ], ///Not Owner

          ///START FOR LOGIC OF POP UP MENU BUTTON (ung three dots)
          /// If owner, show these options in the popup menu
          onItemsSelected: (index) async {
            if (widget.deck.userId == currentUser!.uid) {
              ///P U B L I S H  D E C K
              if (index == 0) {
                BuildContext parentContext = context;
                //Show the confirmation dialog for Publish/Unpublish
                showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return CustomConfirmDialog(
                      title: widget.deck.isPrivate ? 'Publish Deck?' : 'Unpublish Deck?',
                      message: widget.deck.isPrivate
                          ? 'Are you sure you want to publish this deck?'
                          : 'Are you sure you want to unpublish this deck?',
                      imagePath: 'assets/images/Deck-Dialogue4.png',
                      button1: widget.deck.isPrivate ? 'Publish Deck' : 'Unpublish Deck',
                      button2: 'Cancel',
                        onConfirm: () {
                          Navigator.of(context).pop(); // close confirm dialog
                          Future(() async {
                            // Put delay to ensure the current dialog is popped out of the stack
                            await Future.delayed(Duration(milliseconds: 100));
                            try {
                              // Fire up request
                              await widget.deck.publishOrUnpublishDeck();

                              // Show Dialog
                              if (parentContext.mounted) {
                                // Conditional Message
                                String message = widget.deck.isPrivate ?
                                "Successfully made a publish request! Please wait for our moderator's approval" :
                                "Successfully unpublished the deck! You may now make changes to the deck.";
                                // Conditional Title
                                String title = widget.deck.isPrivate ?
                                'Publish request for "${widget.deck.title}" deck has been made!' :
                                'Successfully Unpublished "${widget.deck.title}';

                                //Set the decks' field to true if its was published or public (isPrivate = false) already
                                if(!widget.deck.isPrivate) widget.deck.isPrivate = true;

                                showAlertDialog(
                                  parentContext,
                                  "assets/images/Deck-Dialogue3.png",
                                  title,
                                  message,
                                );

                                setState(() {});
                              }
                            } catch (e) {
                              print('Caught error: $e');
                              String errorMessage = e is ApiException ? e.message : 'An unexpected error occurred.';
                              if (parentContext.mounted) {
                                showAlertDialog(
                                  parentContext,
                                  "assets/images/Deck-Dialogue1.png",
                                  "Uh Oh An Error Has Occured",
                                  errorMessage,
                                );
                              }
                            }
                          });
                        },
                      onCancel: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              }
              ///E D I T  D E C K
              else if (index == 1) {
                if(widget.deck.isPrivate){
                  await Navigator.of(context).push(
                    RouteGenerator.createRoute(EditDeck(deck: widget.deck,)),
                  );
                  setState(() {});
                  return;
                }
                showAlertDialog(
                  context,
                  "assets/images/Deck-Dialogue1.png",
                  "Sorry but you cannot edit an already published deck.",
                  "Published decks are reviewed by our moderator to ensure appropriate content. Please unpublish first to edit your deck.",
                );
              }
              ///R E P O R T  D E C K
              else if (index == 2){
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportAProblem(sourcePage: 'ViewDeckOwner', deckID: widget.deck.deckId),
                    ),
                  );
                });
              }
              ///D E L E T E  D E C K
              else if (index == 3) {
                showDialog<bool>(
                    context: context,
                    barrierDismissible: false,
                    builder: (BuildContext context) {
                      return CustomConfirmDialog(
                        title: 'Delete this deck?',
                        message: 'Deleted decks move to trash and can be recovered.',
                        imagePath: 'assets/images/Deck-Dialogue4.png',
                        button1: 'Delete Deck',
                        button2: 'Cancel',
                        onConfirm: () async {
                          // Grab the NavigatorState once.
                          final navigator = Navigator.of(context);
                          navigator.pop(); // Pop the pop-up
                          await widget.deck.updateDeleteStatus(true);
                          navigator.pop(); // pop to the next frame
                        },
                        onCancel: () {
                          Navigator.of(context).pop(false); // Close the first dialog on cancel
                        },
                      );
                    }
                );
              }
            }
            ///----- E N D  O F  O W N E R -----------

            ///If not owner, show these options
            else {
              ///S A V E  D E C K
              if (index == 0) {
                showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return CustomConfirmDialog(
                      title: isSaved ? 'Unsave Deck?' : 'Save Deck?',
                      message: isSaved
                          ? 'Are you sure you want to save this deck?'
                          : 'Are you sure you want to unsave this deck?',
                      imagePath: 'assets/images/Deck-Dialogue4.png',
                      button1: isSaved ? 'Unsave Deck' : 'Save Deck',
                      button2: 'Cancel',
                      onConfirm: () async {
                        if(isSaved){
                          await widget.deck.unsaveDeck();
                        }else{
                          await widget.deck.saveDeck();
                        }
                        setState(() {
                          isSaved = !isSaved;
                          Navigator.of(context).pop();
                        });
                      },
                      onCancel: () {
                        Navigator.of(context).pop();
                      },
                    );
                  },
                );
              }
              ///R E P O R T  P A G E
              else if (index == 1) {
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ReportAProblem(sourcePage: 'FlashcardPage', deckID: widget.deck.deckId ),
                    ),
                  );
                });
              }
            }
            ///----- E N D  O F  N O T  O W N E R -----------
          }
          ///-------- E N D  O F  P O P  U P  M E N U  B U T T O N -------------
      ),
      body: _isLoading ? const DeckLoadingDialog(
        message: "Getting your cards ready for the challenge!",
      ):SingleChildScrollView(
        //padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Stack(
              children: [
                Container(
                  height: 150,
                  width: double.infinity,
                  child: BuildCoverImage(
                    // Conditionally pass CoverPhotofile based on coverPhoto value
                    imageUrl: widget.deck.coverPhoto ?? "no_image",
                    borderRadiusContainer: 0,
                    borderRadiusImage: 0,
                    isHeader: true,
                  ),
                ),
                //For fading effect on the bottom, refer at figma if confused
                Container(
                  width: double.infinity,
                  height: 150,
                  decoration: BoxDecoration(
                      gradient: LinearGradient(
                    colors: [
                      Colors.transparent,
                      DeckColors.backgroundColor.withOpacity(0.3),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    stops: [0.85, 1.0],
                  )),
                )
              ],
            ),
            Padding(
              padding: const EdgeInsets.only(
                  top: 15, left: 20, right: 20, bottom: 20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ///Start of deck title, made by who and description
                  Text(
                    widget.deck.title.toString(),
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontFamily: 'Fraiche',
                      color: DeckColors.primaryColor,
                      fontSize: 32,

                    ),
                  ),
                  Text(
                    'By: ${widget.deck.deckOwnerName}',
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontFamily: 'Nunito-Bold',
                      color: DeckColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    widget.deck.description,
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontFamily: 'Nunito-Regular',
                      color: DeckColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  ///-------E N D ----------
                  Padding(
                    padding: const EdgeInsets.only(top: 8.0),
                    child: Row(
                      children: [
                        Text(
                          '${_cardsCollection.length} cards',
                          overflow: TextOverflow.visible,
                          style: const TextStyle(
                            fontFamily: 'Nunito-Regular',
                            fontSize: 16,
                            color: DeckColors.primaryColor,
                          ),
                        ),
                        Spacer(),
                        if(widget.deck.userId == currentUser!.uid)
                        Padding(
                          padding: const EdgeInsets.only(right: 8.0),
                          child: BuildButton(
                              onPressed: () async {
                                if(widget.deck.flashcardCount >= 100){
                                  showAlertDialog(
                                    context,
                                    "assets/images/Deck-Dialogue1.png",
                                    "Sorry but you cannot add anymore cards.",
                                    "A deck can only hold 100 flashcards. Creating a new deck is advised so that you will not overwhelmed",
                                  );

                                  return;
                                }
                                if(widget.deck.isPrivate){
                                  await Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddFlashcardPage(deck: widget.deck),
                                    ),
                                  );
                                  widget.deck.flashcardCount++;
                                  await _initDeckCards();
                                  return;
                                }
                                showAlertDialog(
                                  context,
                                  "assets/images/Deck-Dialogue1.png",
                                  "Sorry but you cannot add a flashcard to an already published deck.",
                                  "Published decks are reviewed by our moderator to ensure appropriate content. Please unpublish first to edit your deck.",
                                );
                              },
                              buttonText: 'Add',
                              icon: Icons.add,
                              paddingIconText: 3,
                              iconColor: DeckColors.primaryColor,
                              height: 35,
                              width: 110,
                              radius: 20,
                              backgroundColor: DeckColors.deckYellow,
                              textColor: DeckColors.primaryColor,
                              fontSize: 16,
                              borderWidth: 1,
                              borderColor: DeckColors.primaryColor),
                        ),
                        Opacity(
                          opacity: canPressLearn ? 1.0 : 0.5,
                          child: BuildButton(
                            onPressed:canPressLearn ? () async {
                              final result = await showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) => LearnModeDialog(deck: widget.deck),
                              );

                              if (result != null && result is Map<String, dynamic>) {
                                setState(() {
                                  _isLoading = true;
                                });

                                final selectedMode = result['mode'] as String;
                                final numberOfCards = result['numberOfCards'] as int;

                                try{
                                  if (selectedMode == 'Quiz') {
                                    final quizType = result['quizType'] as String;
                                    if (quizType == "Multiple Choice") {
                                      FlashcardAiService aiService = FlashcardAiService();
                                      Quiz? quiz = await aiService.retrieveQuizForDeck(
                                          deckId: widget.deck.deckId, numOfQuiz: numberOfCards);
                                      List<QuizQuestion>? questions = quiz?.questions;
                                      if (questions != null) {
                                        await Navigator.of(context).push(
                                          RouteGenerator.createRoute(QuizMultChoice(
                                            deck: widget.deck,
                                            questions: questions,
                                          )),
                                        );
                                      }
                                    } else if (quizType == "Identification") {
                                      List<Cards> randomizedCards = await widget.deck.getCardRandom(numberOfCards);
                                      await Navigator.of(context).push(
                                        RouteGenerator.createRoute(QuizIdentification(
                                          cards: randomizedCards,
                                          deck: widget.deck,
                                        )),
                                      );
                                    }
                                  } else if (selectedMode == 'Study') {
                                    final cardOrientation = result['cardOrientation'] as String;
                                    print('Card Orientation: $cardOrientation');
                                    await Navigator.of(context).push(
                                      RouteGenerator.createRoute(PlayMyDeckPage(
                                        cards: await widget.deck.getCardRandom(numberOfCards),
                                        deck: widget.deck,
                                        orientation: cardOrientation,
                                      )),
                                    );
                                  }
                                }catch(e){
                                  String errorMessage = "";
                                  if(selectedMode == 'Quiz') {
                                    errorMessage = "Sorry an unknown kind of error has occurred during the creation of your quiz. Please try again later.";
                                  }else if(selectedMode == 'Study'){
                                    errorMessage = "Sorry an unknown kind of error has occurred while assembling your flashcard. Please try again later";
                                  }
                                  showAlertDialog(
                                      context,
                                      "assets/images/Deck-Dialogue2.png",
                                      "An unknown error has occurred",
                                      errorMessage
                                  );
                                  return;
                                }finally{
                                  setState(() {
                                    _isLoading = false;
                                  });
                                }
                              }
                            } : () {
                              // Do nothing
                            },
                            buttonText: 'Learn',
                            height: 35,
                            width: 110,
                            radius: 20,
                            backgroundColor: DeckColors.primaryColor,
                            textColor: DeckColors.white,
                            fontSize: 16,
                            borderWidth: 1,
                            borderColor: DeckColors.primaryColor,
                            icon: Icons.play_arrow_rounded,
                            paddingIconText: 3,
                            iconColor: DeckColors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (_cardsCollection.isNotEmpty)
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: BuildTextBox(
                        controller: _searchController,
                        hintText: 'Search Flashcard',
                        showPassword: false,
                        rightIcon: Icons.search,
                      ),
                    ),
                  Padding(
                    padding: EdgeInsets.only(top: topPadding),
                    child: SizedBox(
                      width: MediaQuery.of(context).size.width,
                      height: MediaQuery.of(context).size.height * .6,
                      child: BuildTabBar(
                        titles: ['All', 'Starred'],
                        length: 2,
                        tabContent: [
                          /// ------------------------- START OF TAB 'ALL' CONTENT ----------------------------
                          if (_cardsCollection.isEmpty)
                            IfCollectionEmpty(
                              ifCollectionEmptyText:
                                  'No Flashcards Yet!',
                              ifCollectionEmptySubText:
                              'Haven’t added any cards? Let\'s get started!',
                              ifCollectionEmptyHeight:
                                  MediaQuery.of(context).size.height * 0.3,
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _filteredCards.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6.0),
                                        child: BuildContainerOfFlashCards(
                                          titleOfFlashCard: _filteredCards[index].term,
                                          contentOfFlashCard: _filteredCards[index].definition,
                                          onDelete: widget.deck.userId == currentUser!.uid ? () {
                                            Cards removedCard = _filteredCards[index];
                                            final String deletedTitle = removedCard.term;
                                            showConfirmDialog(
                                                context,
                                                "assets/images/Deck_Dialogue1.png",
                                                "Delete Item?",
                                                "Are you sure you want to delete '$deletedTitle'?",
                                                "Delete Item",
                                                () async {
                                                  try {
                                                    await removedCard.deleteCard(true, widget.deck.deckId);
                                                    setState(() {
                                                      _filteredCards.removeAt(index);
                                                      _cardsCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                                      _starredCards.removeWhere((card) => card.cardId == removedCard.cardId);
                                                      _filteredStarredCards.removeWhere((card) => card.cardId == removedCard.cardId);
                                                      numberOfCards = _cardsCollection.length;
                                                    });
                                                    Navigator.pop(context); // close the dialog after successful deletion
                                                  } catch (e) {
                                                    print('View Deck Error: $e');
                                                    showAlertDialog(
                                                        context,
                                                        "assets/images/Deck_Dialogue1.png",
                                                        "Card Deletion Unsuccessful",
                                                        "An error occurred during the deletion process"
                                                    );
                                                  }
                                                }
                                            );
                                          }
                                          : null,
                                          enableSwipeToRetrieve: false,
                                          onTap: () async{
                                            await Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditFlashcardPage(
                                                        deck: widget.deck,
                                                        card: _cardsCollection[index],
                                                      )),
                                            );
                                            setState(() {});
                                          },
                                          isStarShaded: _filteredCards[index].isStarred,
                                          onStarShaded: () => _toggleStar(_filteredCards[index], true),
                                          onStarUnshaded: () => _toggleStar(_filteredCards[index], false),
                                          ///Delete Icon
                                          iconOnPressed: () {
                                            showDialog<bool>(
                                            context: context,
                                            barrierDismissible: false,
                                            builder: (BuildContext context) {
                                              Cards removedCard = _filteredCards[index];
                                              final String deletedTitle = removedCard.term;
                                               return CustomConfirmDialog(
                                                  imagePath: 'assets/images/Deck-Dialogue4.png',
                                                  title: 'Delete this flashcard?',
                                                  message: 'Are you sure you want to delete?',
                                                  button1: 'Delete Flashcard',
                                                  button2: 'Cancel',
                                                  onConfirm: () async {
                                                    try {
                                                      await removedCard.deleteCard(true, widget.deck.deckId);
                                                      setState(() {
                                                        _filteredCards.removeAt(index);
                                                        _cardsCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                                        _starredCards.removeWhere((card) => card.cardId == removedCard.cardId);
                                                        _filteredStarredCards.removeWhere((card) => card.cardId == removedCard.cardId);
                                                        numberOfCards = _cardsCollection.length;
                                                      });
                                                    } catch (e) {
                                                      print('View Deck Delete Error: $e');
                                                      showAlertDialog(
                                                        context,
                                                        "assets/images/Deck-Dialogue2.png",
                                                        "Changed flash card information!",
                                                        "Successfully changed flash card information.",
                                                      );
                                                    }
                                                    Navigator.of(context).pop(true);
                                                  },
                                                  onCancel: () {
                                                    Navigator.of(context).pop();
                                                  },
                                               );
                                              },
                                            );
                                          },
                                          showStar: true,
                                          showIcon: (widget.deck.userId == currentUser!.uid),

                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),

                          ///
                          ///
                          /// ------------------------- END OF TAB 'ALL' CONTENT ----------------------------

                          ///
                          ///
                          /// ------------------------- START OF TAB 'STARRED' CONTENT ----------------------------
                          if (_cardsCollection.isEmpty)
                            IfCollectionEmpty(
                              ifCollectionEmptyText:
                                  'No Starred Flashcards Yet!',
                              ifCollectionEmptySubText:
                              'Looks like you haven\'t starred any flashcards yet.',
                              ifCollectionEmptyHeight:
                                  MediaQuery.of(context).size.height * 0.3,
                            )
                          else
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _filteredStarredCards.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6.0),
                                        child: BuildContainerOfFlashCards(
                                          titleOfFlashCard: _filteredStarredCards[index].term,
                                          contentOfFlashCard: _filteredStarredCards[index].definition,
                                          onDelete: widget.deck.userId == currentUser!.uid ? () {
                                            Cards removedCard = _filteredStarredCards[index];
                                            final String deletedTitle = removedCard.term;
                                            showConfirmDialog(
                                              context,
                                              "assets/images/Deck_Dialogue1.png",
                                              "Delete Item?",
                                              "Are you sure you want to delete '$deletedTitle'?",
                                              "Delete Item",
                                                  () async {
                                                try {
                                                  await removedCard.deleteCard(true, widget.deck.deckId);
                                                  setState(() {
                                                    _filteredCards.removeAt(index);
                                                    _cardsCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                                    _starredCards.removeWhere((card) => card.cardId == removedCard.cardId);
                                                    _filteredStarredCards.removeWhere((card) => card.cardId == removedCard.cardId);
                                                    numberOfCards = _cardsCollection.length;
                                                  });
                                                } catch (e) {
                                                  print('View Deck Error: $e');
                                                  showAlertDialog(
                                                      context,
                                                      "assets/images/Deck_Dialogue1.png",
                                                      "Card Deletion Unsuccessful",
                                                      "An error occurred during the deletion process"
                                                  );
                                                }
                                              },
                                            );
                                          } : null,
                                          enableSwipeToRetrieve: false,
                                          onTap: () {
                                            print("Clicked");
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditFlashcardPage(
                                                        deck: widget.deck,
                                                        card: _filteredStarredCards[index],
                                                      )),
                                            );
                                          },
                                          isStarShaded: true,
                                          onStarShaded: () {
                                            // No action because it's always shaded here
                                          },
                                          onStarUnshaded: () => _toggleStar(_filteredStarredCards[index], false),
                                          iconOnPressed: () {
                                            showDialog<bool>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                Cards removedCard = _filteredStarredCards[index];
                                                final String deletedTitle = removedCard.term;
                                                return CustomConfirmDialog(
                                                  imagePath: 'assets/images/Deck-Dialogue4.png',
                                                  title: 'Delete this flashcard?',
                                                  message: 'Are you sure you want to delete?',
                                                  button1: 'Delete Flashcard',
                                                  button2: 'Cancel',
                                                  onConfirm: () async {
                                                    try {
                                                      await removedCard.deleteCard(true, widget.deck.deckId);
                                                      setState(() {
                                                        _filteredStarredCards.removeAt(index);
                                                        _cardsCollection.removeWhere((card) => card.cardId == removedCard.cardId);
                                                        _starredCards.removeWhere((card) => card.cardId == removedCard.cardId);
                                                        _filteredCards.removeWhere((card) => card.cardId == removedCard.cardId);
                                                        numberOfCards = _filteredCards.length;
                                                      });
                                                    } catch (e) {
                                                      print('View Deck Delete Error: $e');
                                                      showAlertDialog(
                                                        context,
                                                        "assets/images/Deck-Dialogue2.png",
                                                        "Changed flash card information!",
                                                        "Successfully changed flash card information.",
                                                      );
                                                    }
                                                    Navigator.of(context).pop(true);
                                                  },
                                                  onCancel: () {
                                                    Navigator.of(context).pop(true);
                                                  },
                                                );
                                              },
                                            );
                                          },
                                          showStar: true,
                                          showIcon: (widget.deck.userId == currentUser!.uid),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ),
                        ],
                      ),
                    ),
                  )
                ],
              ),
            ),
          ],
        ),
      ),

      ///
      ///
      /// ------------------------- END OF TAB 'STARRED' CONTENT ----------------------------
    );
  }
}
