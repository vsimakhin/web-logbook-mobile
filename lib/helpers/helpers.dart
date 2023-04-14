import 'package:flutter/material.dart';
import 'package:logger/logger.dart';

void showInfo(BuildContext context, String info) {
  var logger = Logger();
  logger.i(info);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(info),
      duration: const Duration(seconds: 2),
    ),
  );
}

void showError(BuildContext context, String error) {
  var logger = Logger();
  logger.e(error);

  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(error),
      duration: const Duration(seconds: 2),
      backgroundColor: Theme.of(context).colorScheme.error,
    ),
  );
}

int getEpochTime() {
  return DateTime.now().millisecondsSinceEpoch ~/ 1000;
}

String formatLandings(int landings) {
  if (landings == 0) {
    return '';
  } else {
    return landings.toString();
  }
}
