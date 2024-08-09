import 'package:flutter/material.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/pages/dairy/daily_event_tab.dart';
import 'package:table_calendar/table_calendar.dart';

class DiaryPage extends StatefulWidget {
  @override
  _DiaryPageState createState() => _DiaryPageState();
}

class _DiaryPageState extends State<DiaryPage> {
  DateTime _focusedDay = DateTime.now();
  DateTime? _selectedDay = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        body: Column(
          children: [
            TableCalendar(
              firstDay: DateTime.utc(1990, 01, 01),
              lastDay: DateTime.utc(2100, 12, 31),
              focusedDay: _focusedDay,
              selectedDayPredicate: (day) {
                return isSameDay(_selectedDay, day);
              },
              onDaySelected: (selectedDay, focusedDay) {
                setState(() {
                  _selectedDay = selectedDay;
                  _focusedDay = focusedDay; // update `_focusedDay` here as well
                });
              },
              availableCalendarFormats: const {
                CalendarFormat.month: '',
              },
              headerStyle: HeaderStyle(
                titleTextStyle: TextStyle(
                  fontSize: 19,
                  fontWeight: FontWeight.w600,
                ),
                titleCentered: true,
                leftChevronIcon: Icon(
                  Icons.chevron_left,
                  color: PetRecordColor.theme,
                ),
                rightChevronIcon: Icon(
                  Icons.chevron_right,
                  color: PetRecordColor.theme,
                ),
              ),
              daysOfWeekStyle: DaysOfWeekStyle(
                weekdayStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
                weekendStyle: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w600,
                ),
              ),
              daysOfWeekHeight: 40,
              calendarStyle: CalendarStyle(
                selectedDecoration: BoxDecoration(
                  color: PetRecordColor.theme,
                  shape: BoxShape.circle,
                ),
                todayDecoration: BoxDecoration(
                  color: PetRecordColor.primary,
                  shape: BoxShape.circle,
                ),
                defaultTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                weekendTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
                outsideTextStyle: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Colors.grey,
                ),
              ),
            ),
            SizedBox(
              height: 10,
            ),
            Expanded(
              child: DailyEventTab(
                selectedDate: _selectedDay ?? DateTime.now(),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
