import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class BuildDropdownButton extends StatefulWidget {
  final String selectedPriority;

  const BuildDropdownButton({super.key, this.selectedPriority = "Low"});

  @override
  _BuildDropdownButtonState createState() => _BuildDropdownButtonState();
}

class _BuildDropdownButtonState extends State<BuildDropdownButton> {
  late String _selectedPriority;

  @override
  void initState() {
    super.initState();
    _selectedPriority = widget.selectedPriority; // Initialize it in initState
  }

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
        value: _selectedPriority, // Display the selected value
        style: GoogleFonts.nunito(
          color: Colors.white,
          fontSize: 16
        ),
        items: <String>["Low", "Medium", "High"].map((String value) {
          return DropdownMenuItem<String>(
            value: value,
            child: Text(value),
          );
        }).toList(),
        onChanged: (String? newValue) {
          setState(() {
            _selectedPriority = newValue!; // Update the value and rebuild
          });
        },
      );
  }
}