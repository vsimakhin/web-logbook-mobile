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

  showDialog<String>(
    context: context,
    builder: (BuildContext context) => AlertDialog(
      title: const Text('Something wrong'),
      content: Text(error),
      actions: <Widget>[
        TextButton(child: const Text('Well, ok then...'), onPressed: () => Navigator.pop(context)),
      ],
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
