import 'package:flutter/services.dart';
import 'package:flutter/material.dart';

class TimeField extends StatelessWidget {
  const TimeField({
    super.key,
    required this.ctrl, // field controller
    required this.tt, // total time controller
    required this.lbl, // field label
  });

  final TextEditingController ctrl;
  final TextEditingController tt;
  final String lbl;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: lbl,
          icon: GestureDetector(
            child: const Icon(Icons.timer),
            onDoubleTap: () {
              ctrl.text = tt.text;
            },
          ),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
          LengthLimitingTextInputFormatter(5),
          _TimeFormatter(),
        ],
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
      ),
    );
  }
}

// Custom TextInputFormatter for Time fields
class _TimeFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    String formattedText = newValue.text.replaceAll(':', '');

    // Only allow up to 5 characters
    if (formattedText.length > 4) {
      formattedText = formattedText.substring(0, 4);
    }

    if (formattedText.length == 4 &&
        int.parse(formattedText.substring(2)) > 59) {
      formattedText = formattedText.substring(0, 3);
    }

    if (formattedText.length > 3) {
      formattedText =
          '${formattedText.substring(0, 2)}:${formattedText.substring(2)}';
    } else if (formattedText.length > 2) {
      formattedText =
          '${formattedText.substring(0, 1)}:${formattedText.substring(1)}';
    }

    return TextEditingValue(
      text: formattedText,
      selection: TextSelection.collapsed(offset: formattedText.length),
    );
  }
}
