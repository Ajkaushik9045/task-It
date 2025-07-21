// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:frontend/core/constant/util.dart';

class DateSelector extends StatefulWidget {
  final DateTime selectedDate;
  final Function(DateTime) onTap;
  const DateSelector({
    super.key,
    required this.selectedDate,
    required this.onTap,
  });

  @override
  State<DateSelector> createState() => _DateSelectorState();
}

class _DateSelectorState extends State<DateSelector> {
  int weekOffset = 0;
  late DateTime baseMonday;

  @override
  void initState() {
    super.initState();
    baseMonday = DateTime.now().subtract(
      Duration(days: DateTime.now().weekday - 1),
    );
  }

  @override
  Widget build(BuildContext context) {
    final weekDates = generateWeekDates(baseMonday, weekOffset);
    String monthName = DateFormat("MMMM").format(weekDates.first);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 16,
          ).copyWith(bottom: 10),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                onPressed: () {
                  setState(() {
                    weekOffset = (weekOffset - 1).clamp(
                      -52,
                      52,
                    ); // support going back
                  });
                },
                icon: const Icon(Icons.arrow_back_ios_new_sharp),
              ),
              Text(
                monthName,
                style: const TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                ),
              ),
              IconButton(
                onPressed: () {
                  setState(() {
                    weekOffset = (weekOffset + 1).clamp(
                      -52,
                      52,
                    ); // support going forward
                  });
                },
                icon: const Icon(Icons.arrow_forward_ios),
              ),
            ],
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: SizedBox(
            height: 80,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: weekDates.length,
              itemBuilder: (context, index) {
                final date = weekDates[index];
                bool isSelected =
                    DateFormat("d").format(widget.selectedDate) ==
                        DateFormat("d").format(date) &&
                    widget.selectedDate.month == date.month &&
                    widget.selectedDate.year == date.year;
                return GestureDetector(
                  onTap: () => widget.onTap(date),
                  child: Container(
                    width: 70,
                    margin: const EdgeInsets.only(right: 8),
                    decoration: BoxDecoration(
                      color: isSelected ? Colors.deepOrangeAccent : null,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(
                        color: isSelected
                            ? Colors.deepOrangeAccent
                            : Colors.grey,
                        width: 2,
                      ),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          DateFormat("d").format(date),
                          style: TextStyle(
                            fontSize: 22,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          DateFormat("E").format(date),
                          style: TextStyle(
                            fontSize: 14,
                            color: isSelected ? Colors.white : Colors.black87,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ],
    );
  }
}
