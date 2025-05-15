import 'package:deck/backend/flashcard/flashcard_utils.dart';
import 'package:deck/backend/models/card.dart';
import 'package:deck/pages/flashcard/add_flashcard.dart';
import 'package:deck/pages/flashcard/edit_deck.dart';
import 'package:deck/pages/flashcard/edit_flashcard.dart';
import 'package:deck/pages/misc/colors.dart';
import 'package:deck/pages/misc/deck_icons.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:deck/pages/misc/widget_method.dart';
// import 'package:google_fonts/google_fonts.dart';

import '../../backend/models/deck.dart';
import '../misc/custom widgets/appbar/auth_bar.dart';
import '../misc/custom widgets/buttons/custom_buttons.dart';
import '../misc/custom widgets/dialogs/alert_dialog.dart';
import '../misc/custom widgets/dialogs/confirmation_dialog.dart';
import '../misc/custom widgets/dialogs/learn_mode_dialog.dart';
import '../misc/custom widgets/functions/if_collection_empty.dart';
import '../misc/custom widgets/functions/tab_bar.dart';
import '../misc/custom widgets/images/cover_image.dart';
import '../misc/custom widgets/textboxes/textboxes.dart';
import '../misc/custom widgets/tiles/container_of_flashcard.dart';
import '../settings/support and policies/report_a_problem.dart';

class ViewDeckPage extends StatefulWidget {
  final Deck deck;
  const ViewDeckPage({super.key, required this.deck});


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
  User? currentUser;
  final TextEditingController _searchController = TextEditingController();
  final ScrollController _scrollController = ScrollController();

  // List<Cards> _cardsCollection = [];
  // List<Cards> _cardsCollection = [];
  // List<Cards> _cardsCollection = [];

  @override
  void initState() {
    super.initState();
    _initDeckCards();
    _getCurrentUser();
    _scrollController.addListener(_onScroll);

    // Commented out: will switch to api calls
    // _searchController.addListener(_filterFlashcards);
  }

  /// Initialized the flashcards of the deck
  /// Retrieves the flashcards under the given deck
  void _initDeckCards() async {
    List<Cards> cards = await widget.deck.getCard();
    // TODO: retrieve starred flashcards here

    setState(() {
      // Assigns the fetched flashcards to the collection
      _cardsCollection = cards;

      // Comment out TODO: Make endpoint to retrieve the starred flashcards
      // _cardsCollection = starredCards;

      // Comment out, Used for the search function done in the client side
      // TODO: Make and endpoint that will retrieve the flashcard searched based on user query
      // _cardsCollection = List.from(cards);

      // Comment out, Used for the search function done in the client side
      // TODO: Make and endpoint that will retrieve the flashcard searched based on user query
      // _cardsCollection = List.from(starredCards);
    });
  }

  // Removed: used for client side search. Will switch to api function call
  // void _filterFlashcards() {
  //   String query = _searchController.text.toLowerCase();
  //   setState(() {
  //     _cardsCollection = _cardsCollection
  //         .where((card) =>
  //             card.term.toLowerCase().contains(query) ||
  //             card.definition.toLowerCase().contains(query))
  //         .toList();
  //
  //     _cardsCollection = _cardsCollection
  //         .where((card) =>
  //             card.term.toLowerCase().contains(query) ||
  //             card.definition.toLowerCase().contains(query))
  //         .toList();
  //     FlashcardUtils().sortByQuestion(_cardsCollection);
  //     FlashcardUtils().sortByQuestion(_cardsCollection);
  //   });
  // }

  /// Function that listens for the user scroll
  /// Will retrieve more flashcards once the user reaches a certain scroll limit
  Future<void> _onScroll() async {
    if (_scrollController.position.pixels >=
        _scrollController.position.maxScrollExtent - 200) {

      if(isFetchingMore) return;
      // if(_nextPageToken == "" || _nextPageToken.isEmpty) return;
      // isFetchingMore = true;
      //
      // var result = await _flashcardService.getDecksNextPage(nextPageToken: _nextPageToken);
      // List<Deck> decks = result['decks'];
      // String nextPageToken = result['nextPageToken'];
      // print('next page token from on scroll result: ${nextPageToken}');
      // print('current next page token from on scroll ${_nextPageToken}');
      // print(decks.map((deck) => deck.toString()).toList());
      //
      // if(decks.isNotEmpty){
        print("umabot dito");
      //   setState(() {
      //     _nextPageToken = nextPageToken;
      //     print('current next page token from on scroll being set ${_nextPageToken}');
      //     _decks.addAll(decks);
      //   });
      // }else{
      //   setState(() {
      //     _nextPageToken = "";
      //   });
      // }
      // isFetchingMore = false;
    }
  }

  @override
  void dispose() {
    _searchController.dispose();
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
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
              ? [widget.deck.isPrivate ? 'Unpublish Deck' : 'Publish Deck', 'Edit Deck Info',  'Report Deck', 'Delete Deck'] ///Owner
              : [isSaved ? 'Unsave Deck' : 'Save Deck', 'Report Deck'], ///Not owner
          icons: (widget.deck.userId == currentUser!.uid)
              ? [
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
          onItemsSelected: (index) {
            if (widget.deck.userId == currentUser!.uid) {
              ///P U B L I S H  D E C K
              if (index == 0) {
                //Show the confirmation dialog for Publish/Unpublish
                showDialog<bool>(
                  context: context,
                  barrierDismissible: false,
                  builder: (BuildContext context) {
                    return CustomConfirmDialog(
                      title: widget.deck.isPrivate ? 'Unpublish Deck?' : 'Publish Deck?',
                      message: widget.deck.isPrivate
                          ? 'Are you sure you want to unpublish this deck?'
                          : 'Are you sure you want to publish this deck?',
                      imagePath: 'assets/images/Deck-Dialogue4.png',
                      button1: widget.deck.isPrivate ? 'Unpublish Deck' : 'Publish Deck',
                      button2: 'Cancel',
                      onConfirm: () async {
                        setState(() {
                          widget.deck.isPrivate = !widget.deck.isPrivate;
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
              ///E D I T  D E C K
              else if (index == 1) {
                Navigator.of(context).push(
                    RouteGenerator.createRoute(EditDeck(deck: widget.deck,)),
                );
              }
              ///R E P O R T  D E C K
              else if (index == 2){
                setState(() {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ReportAProblem(sourcePage: 'ViewDeckOwner'),
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
                        message: 'Once deleted, this deck will no longer be playable. '
                            'But do not worry, you can still retrieve it in the trash bin.',
                        imagePath: 'assets/images/Deck-Dialogue4.png',
                        button1: 'Delete Account',
                        button2: 'Cancel',
                        onConfirm: () async {
                          Navigator.of(context).pop();
                        },
                        onCancel: () {
                          Navigator.of(context).pop(
                              false); // Close the first dialog on cancel
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
                      button1: widget.deck.isPrivate ? 'Unsave Deck' : 'Save Deck',
                      button2: 'Cancel',
                      onConfirm: () async {
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
                      builder: (context) => const ReportAProblem(sourcePage: 'FlashcardPage'),
                    ),
                  );
                });
              }
            }
            ///----- E N D  O F  N O T  O W N E R -----------
          }
          ///-------- E N D  O F  P O P  U P  M E N U  B U T T O N -------------
      ),
      /*floatingActionButton: DeckFAB(
        text: "Add FlashCard",
        fontSize: 12,
        icon: Icons.add,
        foregroundColor: DeckColors.primaryColor,
        backgroundColor: DeckColors.gray,
        onPressed: () async {
          final newCard = await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddFlashcardPage(
                      deck: widget.deck,
                    )),
          );
          if (newCard != null) {
            setState(() {
              _cardsCollection.add(newCard);
              if (newCard.isStarred) {
                _cardsCollection.add(newCard);
              }
              _filterFlashcards();
              numberOfCards = _cardsCollection.length;
            });
          }
        },
      ),*/
      body: SingleChildScrollView(
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
                /*Container(
                  height: 150,
                  width: double.infinity,
                  child: const Image(
                    image: AssetImage('assets/images/Deck-Branding1.png'),
                    fit: BoxFit.cover,
                  ),
                ),*/
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
            /*Text(
                widget.deck.title.toString(),
                overflow: TextOverflow.visible,
                style: const TextStyle(
                  fontFamily: 'Fraiche',
                  color: DeckColors.primaryColor,
                  fontSize: 32,
                  fontWeight: FontWeight.w900,
                ),
              ),*/
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
                    'By: $username',
                    overflow: TextOverflow.visible,
                    style: const TextStyle(
                      fontFamily: 'Nunito-Bold',
                      color: DeckColors.primaryColor,
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  Text(
                    '$description',
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
                          '${widget.deck.flashcardCount} cards',
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
                                final newCard = await Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (context) => AddFlashcardPage(
                                            deck: widget.deck,
                                      )),
                                );
                                if (newCard != null) {
                                  _initDeckCards();
                                }
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
                          opacity: numberOfCards == 0 ? 0.5 : 1.0,
                          child: BuildButton(
                            onPressed:numberOfCards == 0
                                ? () {}
                                : () {
                              showDialog(
                                context: context,
                                barrierDismissible: false,
                                builder: (BuildContext context) => const LearnModeDialog(),
                              );
                            },
                            /*onPressed: () async {
                              var cards = await widget.deck.getCard();
                              var starredCards = [];
                              var noStarCard = [];
                              var joinedCards = [];

                              for (int i = 0; i < cards.length; i++) {
                                if (cards[i].isStarred) {
                                  starredCards.add(cards[i]);
                                } else {
                                  noStarCard.add(cards[i]);
                                }
                              }

                              FlashcardUtils _flashcardUtils = FlashcardUtils();

                              // Shuffle cards
                              if (starredCards.isNotEmpty)
                                _flashcardUtils.shuffleList(starredCards);
                              if (noStarCard.isNotEmpty)
                                _flashcardUtils.shuffleList(noStarCard);

                              joinedCards = starredCards + noStarCard;

                              if (joinedCards.isNotEmpty) {
                                AuthService _authService = AuthService();
                                User? user = _authService.getCurrentUser();
                                if (user != null) {
                                  try {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                          builder: (context) => PlayMyDeckPage(
                                            cards: joinedCards,
                                            deck: widget.deck,
                                          )),
                                    );

                                    FlashcardService _flashCardService =
                                    FlashcardService();
                                    await _flashCardService.addDeckLogRecord(
                                        deckId: widget.deck.deckId.toString(),
                                        title: widget.deck.title.toString(),
                                        userId: user.uid.toString(),
                                        visitedAt: DateTime.now());
                                    FlashcardUtils.updateLatestReview.value = true;
                                  } catch (e) {
                                    print('View Deck Error: $e');

                                    ///display error
                                    showAlertDialog(
                                  context,
                                  "assets/images/Deck_Dialogue1.png",
                                  "Error viewing deck",
                                  "A problem occured while trying to view deck. Please try again.");
                            }
                                }
                              } else {
                                ///display error
                                showAlertDialog(context,
                              "assets/images/Deck_Dialogue1.png","Error viewing deck",
                              "The deck has no card please add a card first before playing.");
                        }
                            },*/
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
                          ///
                          ///
                          /// ------------------------- START OF TAB 'ALL' CONTENT ----------------------------

                          if (_cardsCollection.isEmpty)
                            IfCollectionEmpty(
                              ifCollectionEmptyText:
                                  'No Flashcards Yet!',
                              ifCollectionEmptySubText:
                              'Looks like you haven\'t added any flashcards yet. '
                                  'Let\'s kick things off by adding your first one.',
                              ifCollectionEmptyHeight:
                                  MediaQuery.of(context).size.height * 0.3,
                            )
                          // else if (_cardsCollection.isNotEmpty)
                          //   IfCollectionEmpty(
                          //     ifCollectionEmptyText: 'No Results Found',
                          //     ifCollectionEmptySubText:
                          //         'Try adjusting your search to \nfind what your looking for.',
                          //     ifCollectionEmptyHeight:
                          //         MediaQuery.of(context).size.height * 0.4,
                          //   )
                          else
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SingleChildScrollView(
                                controller: _scrollController,
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics: const NeverScrollableScrollPhysics(),
                                    itemCount: _cardsCollection.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6.0),
                                        child: BuildContainerOfFlashCards(
                                          titleOfFlashCard: _cardsCollection[index].term,
                                          contentOfFlashCard: _cardsCollection[index].definition,
                                          onDelete: widget.deck.userId == currentUser!.uid ? () {
                                            /*Cards removedCard =
                                                _cardsCollection[
                                                    index];
                                            final String deletedTitle =
                                                removedCard.question;
                                            setState(() {
                                              _cardsCollection
                                                  .removeAt(index);
                                              _cardsCollection.removeWhere(
                                                  (card) =>
                                                      card.cardId ==
                                                      removedCard.cardId);
                                              _cardsCollection
                                                  .removeWhere((card) =>
                                                      card.cardId ==
                                                      removedCard.cardId);
                                              _cardsCollection
                                                  .removeWhere((card) =>
                                                      card.cardId ==
                                                      removedCard.cardId);
                                              numberOfCards =
                                                  _cardsCollection.length;
                                            });
                                            showConfirmDialog(
                                                context,
                                                "assets/images/Deck_Dialogue1.png",
                                                "Delete Item?",
                                                "Are you sure you want to delete '$deletedTitle'?",
                                                "Delete Item",
                                              () async {
                                                try {
                                                  await removedCard
                                                      .updateDeleteStatus(
                                                          true,
                                                          widget.deck.deckId);
                                                } catch (e) {
                                                  print(
                                                      'View Deck Error: $e');
                                                  showAlertDialog(
                                                        context,
                                                        "assets/images/Deck_Dialogue1.png",
                                                        "Card Deletion Unsuccessful",
                                                        "An error occurred during the deletion process please try again");
                                                  setState(() {
                                                    _cardsCollection
                                                        .add(removedCard);
                                                    FlashcardUtils()
                                                        .sortByQuestion(
                                                            _cardsCollection);
                                                    _cardsCollection
                                                        .add(removedCard);
                                                    FlashcardUtils()
                                                        .sortByQuestion(
                                                            _cardsCollection);
                                                    if (removedCard
                                                        .isStarred) {
                                                      _cardsCollection
                                                          .add(removedCard);
                                                      FlashcardUtils()
                                                          .sortByQuestion(
                                                              _cardsCollection);
                                                      _cardsCollection
                                                          .add(removedCard);
                                                      FlashcardUtils()
                                                          .sortByQuestion(
                                                              _cardsCollection);
                                                    }
                                                    numberOfCards =
                                                        _cardsCollection
                                                            .length;
                                                  });
                                                }
                                              },
                                              () {
                                                setState(() {
                                                  _cardsCollection
                                                      .add(removedCard);
                                                  FlashcardUtils()
                                                      .sortByQuestion(
                                                          _cardsCollection);
                                                  _cardsCollection
                                                      .add(removedCard);
                                                  FlashcardUtils().sortByQuestion(
                                                      _cardsCollection);
                                                  if (removedCard.isStarred) {
                                                    _cardsCollection
                                                        .add(removedCard);
                                                    FlashcardUtils()
                                                        .sortByQuestion(
                                                            _cardsCollection);
                                                    _cardsCollection
                                                        .add(removedCard);
                                                    FlashcardUtils()
                                                        .sortByQuestion(
                                                            _cardsCollection);
                                                  }
                                                  numberOfCards =
                                                      _cardsCollection.length;
                                                });
                                              },
                                            );*/
                                          }
                                          : null,
                                          enableSwipeToRetrieve: false,
                                          onTap: () {
                                            print("Clicked");
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditFlashcardPage(
                                                        deck: widget.deck,
                                                        card: _cardsCollection[index],
                                                      )),
                                            );
                                          },
                                          isStarShaded: _cardsCollection[index].isStarred,
                                          onStarShaded: () {
                                            setState(() {
                                              try {
                                                _cardsCollection[index].updateStarredStatus(
                                                    true,
                                                    widget.deck.deckId
                                                );
                                                _cardsCollection.add(_cardsCollection[index]);
                                                _cardsCollection.add(
                                                    _cardsCollection[index]
                                                );
                                                _cardsCollection[index].isStarred = true;
                                              } catch (e) {
                                                print('star shaded error: $e');
                                              }
                                            });
                                          },
                                          onStarUnshaded: () {
                                            setState(() {
                                              try {
                                                _cardsCollection[index].updateStarredStatus(
                                                    false,
                                                    widget.deck.deckId
                                                );
                                                _cardsCollection.removeWhere(
                                                        (card) => card.cardId == _cardsCollection[index].cardId
                                                );
                                                _cardsCollection.removeWhere(
                                                        (card) => card.cardId == _cardsCollection[index].cardId
                                                );
                                                _cardsCollection[index].isStarred = false;
                                              } catch (e) {
                                                print('star unshaded error: $e');
                                              }
                                            });
                                          },
                                          ///Delete Icon
                                          iconOnPressed: () {
                                            print("Recognized");
                                            Cards removedCard = _cardsCollection[index];
                                            final String deletedTitle = removedCard.term;
                                            setState(() {
                                              _cardsCollection.removeAt(index);
                                              _cardsCollection.removeWhere(
                                                      (card) => card.cardId == removedCard.cardId
                                              );
                                              _cardsCollection.removeWhere(
                                                      (card) => card.cardId == removedCard.cardId
                                              );
                                              _cardsCollection.removeWhere(
                                                      (card) => card.cardId == removedCard.cardId
                                              );
                                              numberOfCards = _cardsCollection.length;
                                            });
                                          showDialog<bool>(
                                          context: context,
                                          barrierDismissible: false,
                                          builder: (BuildContext context) {
                                             return CustomConfirmDialog(
                                                imagePath: 'assets/images/Deck-Dialogue4.png',
                                                title: 'Delete this flashcard?',
                                                message: 'Are you sure you want to delete ${deletedTitle}?',
                                                button1: 'Delete Flashcard',
                                                button2: 'Cancel',
                                                onConfirm: () async {
                                                  try {
                                                    await removedCard.updateDeleteStatus(
                                                        true,
                                                        widget.deck.deckId
                                                    );
                                                  } catch (e) {
                                                    print(
                                                        'View Deck Error: $e');
                                                    showAlertDialog(
                                                      context,
                                                      "assets/images/Deck-Dialogue2.png",
                                                      "Changed flash card information!",
                                                      "Successfully changed flash card information.",
                                                    );
                                                    setState(() {
                                                      _cardsCollection
                                                          .add(removedCard);
                                                      FlashcardUtils()
                                                          .sortByQuestion(
                                                          _cardsCollection);
                                                      _cardsCollection.add(removedCard);
                                                      FlashcardUtils()
                                                          .sortByQuestion(
                                                          _cardsCollection);
                                                      if (removedCard
                                                          .isStarred) {
                                                        _cardsCollection
                                                            .add(removedCard);
                                                        FlashcardUtils()
                                                            .sortByQuestion(
                                                            _cardsCollection);
                                                        _cardsCollection
                                                            .add(removedCard);
                                                        FlashcardUtils()
                                                            .sortByQuestion(
                                                            _cardsCollection);
                                                      }
                                                      numberOfCards =
                                                          _cardsCollection
                                                              .length;
                                                    });
                                                }
                                                  Navigator.of(context).pop(true);
                                                },
                                                onCancel: () {
                                                  setState(() {
                                                    _cardsCollection
                                                        .add(removedCard);
                                                    FlashcardUtils()
                                                        .sortByQuestion(
                                                        _cardsCollection);
                                                    _cardsCollection
                                                        .add(removedCard);
                                                    FlashcardUtils()
                                                        .sortByQuestion(
                                                        _cardsCollection);
                                                    if (removedCard.isStarred) {
                                                      _cardsCollection
                                                          .add(removedCard);
                                                      FlashcardUtils()
                                                          .sortByQuestion(
                                                          _cardsCollection);
                                                      _cardsCollection
                                                          .add(removedCard);
                                                      FlashcardUtils()
                                                          .sortByQuestion(
                                                          _cardsCollection);
                                                    }
                                                    numberOfCards =
                                                        _cardsCollection.length;
                                                  });
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
                          // else if (_cardsCollection.isNotEmpty &&
                          //     _cardsCollection.isEmpty)
                          //   IfCollectionEmpty(
                          //     ifCollectionEmptyText: 'No Results Found',
                          //     ifCollectionEmptySubText:
                          //         'Try adjusting your search to \nfind what your looking for.',
                          //     ifCollectionEmptyHeight:
                          //         MediaQuery.of(context).size.height * 0.4,
                          //   )
                          else
                            Padding(
                              padding: const EdgeInsets.only(right: 8.0),
                              child: SingleChildScrollView(
                                child: Padding(
                                  padding: const EdgeInsets.only(top: 20.0),
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    physics:
                                        const NeverScrollableScrollPhysics(),
                                    itemCount:
                                        _cardsCollection.length,
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 6.0),
                                        child: BuildContainerOfFlashCards(
                                          titleOfFlashCard:
                                              _cardsCollection[
                                                      index]
                                                  .term,
                                          contentOfFlashCard:
                                              _cardsCollection[
                                                      index]
                                                  .definition,
                                          onDelete: () {
                                            /*Cards removedCard =
                                                _cardsCollection[
                                                    index];
                                            final String starredDeletedTitle =
                                                removedCard.question;
                                            setState(() {
                                              _cardsCollection.removeWhere(
                                                  (card) =>
                                                      card.cardId ==
                                                      removedCard.cardId);
                                              _cardsCollection
                                                  .removeWhere((card) =>
                                                      card.cardId ==
                                                      removedCard.cardId);
                                              _cardsCollection
                                                  .removeAt(index);
                                              _cardsCollection
                                                  .removeWhere((card) =>
                                                      card.cardId ==
                                                      removedCard.cardId);
                                              numberOfCards =
                                                  _cardsCollection.length;
                                            });
                                            showConfirmationDialog(
                                              context,
                                              "Delete Item",
                                              "Are you sure you want to delete '$starredDeletedTitle'?",
                                              () async {
                                                try {
                                                  await removedCard
                                                      .updateDeleteStatus(
                                                          true,
                                                          widget.deck.deckId);
                                                } catch (e) {
                                                  print(
                                                      'View Deck Error: $e');
                                                  showInformationDialog(
                                                      context,
                                                      'Card Deletion Unsuccessful',
                                                      'An error occurred during the deletion process please try again');
                                                  setState(() {
                                                    _cardsCollection
                                                        .add(removedCard);
                                                    FlashcardUtils()
                                                        .sortByQuestion(
                                                            _cardsCollection);
                                                    _cardsCollection
                                                        .add(removedCard);
                                                    FlashcardUtils()
                                                        .sortByQuestion(
                                                            _cardsCollection);
                                                    _cardsCollection
                                                        .add(removedCard);
                                                    FlashcardUtils()
                                                        .sortByQuestion(
                                                            _cardsCollection);
                                                    _cardsCollection
                                                        .add(removedCard);
                                                    FlashcardUtils()
                                                        .sortByQuestion(
                                                            _cardsCollection);
                                                    numberOfCards =
                                                        _cardsCollection
                                                            .length;
                                                  });
                                                }
                                              },
                                              () {
                                                setState(() {
                                                  _cardsCollection
                                                      .add(removedCard);
                                                  FlashcardUtils()
                                                      .sortByQuestion(
                                                          _cardsCollection);
                                                  _cardsCollection
                                                      .add(removedCard);
                                                  FlashcardUtils().sortByQuestion(
                                                      _cardsCollection);
                                                  _cardsCollection
                                                      .add(removedCard);
                                                  FlashcardUtils().sortByQuestion(
                                                      _cardsCollection);
                                                  _cardsCollection
                                                      .add(removedCard);
                                                  FlashcardUtils().sortByQuestion(
                                                      _cardsCollection);
                                                  numberOfCards =
                                                      _cardsCollection.length;
                                                });
                                              },
                                            );*/
                                          },
                                          enableSwipeToRetrieve: false,
                                          onTap: () {
                                            print("Clicked");
                                            Navigator.push(
                                              context,
                                              MaterialPageRoute(
                                                  builder: (context) =>
                                                      EditFlashcardPage(
                                                        deck: widget.deck,
                                                        card:
                                                            _cardsCollection[
                                                                index],
                                                      )),
                                            );
                                          },
                                          isStarShaded: true,
                                          onStarShaded: () {
                                            // No action because it's always shaded here
                                          },
                                          onStarUnshaded: () {
                                            setState(() {
                                              try {
                                                _cardsCollection[
                                                        index]
                                                    .updateStarredStatus(
                                                        false,
                                                        widget.deck.deckId);
                                                _cardsCollection[
                                                        index]
                                                    .isStarred = false;
                                                _cardsCollection
                                                    .removeWhere((card) =>
                                                        card.cardId ==
                                                        _cardsCollection[
                                                                index]
                                                            .cardId);
                                                _cardsCollection
                                                    .removeWhere((card) =>
                                                        card.cardId ==
                                                        _cardsCollection[
                                                                index]
                                                            .cardId);
                                              } catch (e) {
                                                print(
                                                    'star unshaded error: $e');
                                              }
                                            });
                                          },
                                          iconOnPressed: () {
                                            Cards removedCard =
                                            _cardsCollection[
                                            index];
                                            final String starredDeletedTitle =
                                                removedCard.term;
                                            setState(() {
                                              _cardsCollection.removeWhere(
                                                      (card) =>
                                                  card.cardId ==
                                                      removedCard.cardId);
                                              _cardsCollection
                                                  .removeWhere((card) =>
                                              card.cardId ==
                                                  removedCard.cardId);
                                              _cardsCollection
                                                  .removeAt(index);
                                              _cardsCollection
                                                  .removeWhere((card) =>
                                              card.cardId ==
                                                  removedCard.cardId);
                                              numberOfCards =
                                                  _cardsCollection.length;
                                            });
                                            showDialog<bool>(
                                              context: context,
                                              barrierDismissible: false,
                                              builder: (BuildContext context) {
                                                return CustomConfirmDialog(
                                                  imagePath: 'assets/images/Deck-Dialogue4.png',
                                                  title: 'Delete this flashcard?',
                                                  message: 'Are you sure you want to delete ${starredDeletedTitle}?',
                                                  button1: 'Delete Flashcard',
                                                  button2: 'Cancel',
                                                  onConfirm: () async {
                                                    try {
                                                      await removedCard
                                                          .updateDeleteStatus(
                                                          true,
                                                          widget.deck.deckId);
                                                    } catch (e) {
                                                      print(
                                                          'View Deck Error: $e');
                                                      showAlertDialog(
                                                          context, '',
                                                          'Card Deletion Unsuccessful',
                                                          'An error occurred during the deletion process please try again'
                                                      );
                                                      setState(() {
                                                        _cardsCollection
                                                            .add(removedCard);
                                                        FlashcardUtils()
                                                            .sortByQuestion(
                                                            _cardsCollection);
                                                        _cardsCollection
                                                            .add(removedCard);
                                                        FlashcardUtils()
                                                            .sortByQuestion(
                                                            _cardsCollection);
                                                        _cardsCollection
                                                            .add(removedCard);
                                                        FlashcardUtils()
                                                            .sortByQuestion(
                                                            _cardsCollection);
                                                        _cardsCollection
                                                            .add(removedCard);
                                                        FlashcardUtils()
                                                            .sortByQuestion(
                                                            _cardsCollection);
                                                        numberOfCards =
                                                            _cardsCollection
                                                                .length;
                                                      });
                                                    }
                                                    Navigator.of(context).pop(true);
                                                  },
                                                  onCancel: () {
                                                    setState(() {
                                                      _cardsCollection
                                                          .add(removedCard);
                                                      FlashcardUtils()
                                                          .sortByQuestion(
                                                          _cardsCollection);
                                                      _cardsCollection
                                                          .add(removedCard);
                                                      FlashcardUtils()
                                                          .sortByQuestion(
                                                          _cardsCollection);
                                                      _cardsCollection
                                                          .add(removedCard);
                                                      FlashcardUtils()
                                                          .sortByQuestion(
                                                          _cardsCollection);
                                                      _cardsCollection
                                                          .add(removedCard);
                                                      FlashcardUtils()
                                                          .sortByQuestion(
                                                          _cardsCollection);
                                                      numberOfCards =
                                                          _cardsCollection
                                                              .length;
                                                    });
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
