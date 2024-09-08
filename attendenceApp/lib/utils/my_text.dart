import 'package:flutter/material.dart';

class MyText {
  static TextStyle? headlineLarge(BuildContext context) {
    // Use headlineLarge, fallback to headline1 or other styles as needed
    return Theme.of(context).textTheme.headlineLarge ;// Fallback to older naming
  }

  static TextStyle? bodySmall(BuildContext context) {
    // Use bodySmall, fallback to bodyText2 or other styles as needed
    return Theme.of(context).textTheme.bodySmall; // Fallback to older naming
  }

  // Example for other styles
  static TextStyle? headlineMedium(BuildContext context) {
    return Theme.of(context).textTheme.headlineMedium ;// Fallback to older naming
  }

  static TextStyle? titleLarge(BuildContext context) {
    return Theme.of(context).textTheme.titleLarge ;// Fallback to older naming
  }

  static TextStyle? titleMedium(BuildContext context) {
    return Theme.of(context).textTheme.titleMedium;
           // Fallback to older naming
  }

  static TextStyle? bodyMedium(BuildContext context) {
    return Theme.of(context).textTheme.bodyMedium ; // Fallback to older naming
  }

  static TextStyle? bodyLarge(BuildContext context) {
    return Theme.of(context).textTheme.bodyLarge ; // Fallback to older naming
  }
}
