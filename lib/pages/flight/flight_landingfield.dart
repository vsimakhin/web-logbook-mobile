import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class LandingField extends StatelessWidget {
  const LandingField({super.key, required this.ctrl, required this.name});

  final TextEditingController ctrl;
  final String name;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        controller: ctrl,
        decoration: InputDecoration(
          labelText: name,
          icon: name.contains('Day')
              ? const Icon(Icons.sunny)
              : const Icon(Icons.nightlight),
        ),
        inputFormatters: [
          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
        ],
        keyboardType: TextInputType.number,
        textInputAction: TextInputAction.done,
      ),
    );
  }
}
