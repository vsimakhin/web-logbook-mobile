import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class DateField extends StatelessWidget {
  const DateField({
    super.key,
    required this.ctrl, // field controller
  });

  final TextEditingController ctrl;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: TextFormField(
        controller: ctrl,
        decoration: const InputDecoration(
          labelText: 'Date',
          icon: Icon(Icons.calendar_today),
        ),
        validator: _validator,
        textInputAction: TextInputAction.next,
        onTap: () => _onTap(context),
      ),
    );
  }

  String? _validator(String? value) {
    if (value == null || value.isEmpty) {
      return 'Please enter a date';
    }
    return null;
  }

  Future<void> _onTap(BuildContext context) async {
    DateTime? pickedDate = await showDatePicker(
        context: context,
        initialDate: DateTime.now(),
        firstDate: DateTime(1980),
        lastDate: DateTime(2101));

    if (pickedDate != null) {
      String formattedDate = DateFormat('dd/MM/yyyy').format(pickedDate);

      ctrl.text = formattedDate;
    }
  }
}
