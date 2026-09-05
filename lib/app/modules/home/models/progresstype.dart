import 'package:flutter/material.dart';

// Represents the three progress views: Front, Side, and Back
enum ProgressType { front, side, back }

// Extension to easily map the enum to colors and text labels
extension ProgressTypeExtension on ProgressType {
  Color getColor(Map<String, Color> colorMap) {
    switch (this) {
      // Using AppColor static names, mapped to the provided colors
      case ProgressType.front:
        return colorMap['customPurple'] ??
            Colors.deepPurple; // Mock: Purple/Magenta
      case ProgressType.side:
        return colorMap['green22C55E'] ?? Colors.green; // Mock: Green
      case ProgressType.back:
        return colorMap['cyan06B6D4'] ?? Colors.cyan; // Mock: Cyan/Blue
    }
  }

  String get label {
    switch (this) {
      case ProgressType.front:
        return 'Front';
      case ProgressType.side:
        return 'Side';
      case ProgressType.back:
        return 'Back';
    }
  }
}

// Represents a single progress entry on a calendar day (the colored dot)
class DailyProgress {
  final DateTime date;
  final Set<ProgressType> types; // A set to ensure unique dot colors per day

  DailyProgress({required this.date, required this.types});
}
