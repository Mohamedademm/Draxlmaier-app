import 'package:flutter/material.dart';
import '../theme/modern_theme.dart';

class ErrorHandler {
  static void showError(BuildContext context, String message, {String? title}) {
    _showSnackBar(context, message, title: title, isError: true);
  }

  static void showSuccess(BuildContext context, String message, {String? title}) {
    _showSnackBar(context, message, title: title, isError: false);
  }

  static void _showSnackBar(BuildContext context, String message, {String? title, required bool isError}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (title != null)
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                  color: Colors.white,
                ),
              ),
            Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ],
        ),
        backgroundColor: isError ? ModernTheme.error : ModernTheme.success,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        margin: const EdgeInsets.all(16),
        duration: const Duration(seconds: 4),
        action: SnackBarAction(
          label: 'OK',
          textColor: Colors.white,
          onPressed: () {
            ScaffoldMessenger.of(context).hideCurrentSnackBar();
          },
        ),
      ),
    );
  }

  static String formatException(dynamic exception) {
    if (exception is FormatException) {
      return 'Format de données invalide';
    }
    // Add more specific exception handling here
    return exception.toString().replaceAll('Exception: ', '');
  }
}
