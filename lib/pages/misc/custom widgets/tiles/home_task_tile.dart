import 'package:deck/pages/misc/colors.dart';
import 'package:flutter/material.dart';
import 'package:auto_size_text/auto_size_text.dart';
import 'package:intl/intl.dart';

/// HomeTaskTile is a widget that represents a task item in the home screen.
///
/// It displays the task name, deadline, and folder name, along with a color-coded priority indicator.
/// - `folderName`: The name of the folder where the task belongs.
/// - `taskName`: The title of the task.
/// - `priority`: An integer representing the priority level of the task (0 = High, 1 = Medium, 3 = Low).
/// - `deadline`: The due date of the task.
/// - `onPressed`: A callback function triggered when the tile is tapped.

/// how to call
/// HomeTaskTile(
/// folderName: '',
/// taskName: '',
/// deadline: ,
/// onPressed: () {  },
/// priority:
/// )

class HomeTaskTile extends StatelessWidget {
  final String folderName;
  final String taskName;
  final String priority;
  final DateTime deadline;
  // final double cardWidth;
  //final File? deckImage;
  final VoidCallback? onPressed;

  const HomeTaskTile({
    super.key,
    required this.folderName,
    required this.taskName,
    required this.priority,
    required this.deadline,
    required this.onPressed,

  });

  String getDeadline(DateTime dateTime){
    /// formats a givenDateTime objecr into a readable string.
    ///
    /// The output format is: `"Month Day, Year || HH:MM AM/PM"`
    /// Example: `"March 02, 2025 || 12:40 AM"`
    ///
    /// - [dateTime]: The DateTime to be formatted
    String formattedDate = DateFormat("MMMM dd, yyyy").format(dateTime);
    return "Deadline: $formattedDate";
  }

  // Function to set the container color based on priority level
  Color getColor(String priority){
    Color color = DeckColors.white;
    if(priority.toLowerCase() == "high") { color = DeckColors.deckRed;}
    else if(priority.toLowerCase() == "medium") { color = DeckColors.deckYellow;}
    else if(priority.toLowerCase() == "low") { color = DeckColors.deckBlue;}
    else{color = DeckColors.white;}
    return color;
  }
  @override
  Widget build(BuildContext context) {
    return Material(
      borderRadius: BorderRadius.circular(15.0),
      color: DeckColors.white,
      child: InkWell(
        borderRadius: BorderRadius.circular(15.0),
        onTap: () {
          if (onPressed != null) {
            onPressed!();
          }
        },
        child: Container(
          decoration: BoxDecoration(
              border: Border.all(color: DeckColors.primaryColor, width: 3),
              borderRadius: BorderRadius.circular(15.0),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                  width: 20,
                  height: 80,
                  decoration: BoxDecoration(
                      color: getColor(priority),
                      borderRadius: const BorderRadius.horizontal(
                          left: Radius.circular(12)
                      )
                  )
              ),
              const SizedBox(width: 10),
              Expanded(
                child:Padding(
                  padding: const EdgeInsets.symmetric(vertical: 10),
                  child: Column(
                    crossAxisAlignment:
                    CrossAxisAlignment.start,
                    children: [
                      AutoSizeText(
                        taskName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'fraiche',
                          fontSize: 20,
                          color: DeckColors.primaryColor,
                        ),
                      ),
                      AutoSizeText(
                        getDeadline(deadline),
                        textAlign: TextAlign.start,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontFamily: 'Nunito-SemiBold',
                          fontSize: 14,
                          color: DeckColors.primaryColor,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Padding(padding: const EdgeInsets.all(10),
                child: IntrinsicWidth(
                  child: Container(
                    padding:EdgeInsets.symmetric(horizontal: 10,vertical: 2),
                    decoration:BoxDecoration(
                      color: DeckColors.deepGray,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: Text(
                      folderName,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontFamily: 'Nunito-SemiBold',
                        fontSize: 10,
                        color: DeckColors.white,
                      ),
                    ),
                  ),
                )
              ),
            ],
          ),
        ),
      ),
    );
  }
}
