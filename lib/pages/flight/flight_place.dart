import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FlightPlace extends StatelessWidget {
  const FlightPlace({
    super.key,
    required this.ctrlPlace,
    required this.ctrlTime,
    required this.name,
    required this.calculateTotalTime,
    required this.calculateNightTime,
  });

  final TextEditingController ctrlPlace;
  final TextEditingController ctrlTime;
  final String name;
  final Function calculateTotalTime;
  final Function calculateNightTime;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Expanded(
          child: TextFormField(
            textCapitalization: TextCapitalization.characters,
            controller: ctrlPlace,
            decoration: InputDecoration(
              labelText: '$name Place',
              icon: const Icon(Icons.flight_takeoff_outlined),
            ),
            textInputAction: TextInputAction.next,
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: TextFormField(
            controller: ctrlTime,
            decoration: InputDecoration(
              labelText: '$name Time',
              icon: const Icon(Icons.watch),
            ),
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
              LengthLimitingTextInputFormatter(4)
            ],
            keyboardType: TextInputType.number,
            textInputAction: TextInputAction.next,
            onChanged: (value) {
              calculateTotalTime();
              calculateNightTime();
            },
          ),
        )
      ],
    );
  }
}
