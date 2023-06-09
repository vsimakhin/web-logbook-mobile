import 'package:flutter/material.dart';

class StatsTableRow extends TableRow {
  StatsTableRow({
    required String name,
    required List<String> values,
    isHeader = false,
  }) : super(
            decoration: isHeader
                ? const BoxDecoration(
                    color: Colors.grey,
                  )
                : null,
            children: [
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  name,
                  textAlign: isHeader ? TextAlign.center : null,
                  style: isHeader
                      ? const TextStyle(fontWeight: FontWeight.bold)
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  values[0],
                  textAlign: TextAlign.center,
                  style: isHeader
                      ? const TextStyle(fontWeight: FontWeight.bold)
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  values[1],
                  textAlign: TextAlign.center,
                  style: isHeader
                      ? const TextStyle(fontWeight: FontWeight.bold)
                      : null,
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Text(
                  values[2],
                  textAlign: TextAlign.center,
                  style: isHeader
                      ? const TextStyle(fontWeight: FontWeight.bold)
                      : null,
                ),
              ),
            ]);
}
