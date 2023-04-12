import 'package:flutter/material.dart';

class Aircraft extends StatelessWidget {
  const Aircraft({required this.ctrlModel, required this.ctrlReg, super.key});

  final TextEditingController ctrlModel;
  final TextEditingController ctrlReg;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            controller: ctrlModel,
            decoration: const InputDecoration(
              labelText: 'Aircraft Model',
              icon: Icon(Icons.flight),
            ),
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.characters,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: ctrlReg,
            decoration: const InputDecoration(
              labelText: 'Registration',
              icon: Icon(Icons.tag),
            ),
            textInputAction: TextInputAction.next,
            textCapitalization: TextCapitalization.characters,
          ),
        )
      ],
    );
  }
}
