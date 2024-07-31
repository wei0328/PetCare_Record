import 'package:flutter/material.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:petcare_record/pages/addEvent/add_event.dart';
import 'package:petcare_record/pages/addEvent/add_reminder.dart';
import 'package:petcare_record/pages/myPets/my_pets_page.dart';

class AddNew extends StatelessWidget {
  final Pet pet;

  AddNew({required this.pet});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.white,
          elevation: 0,
          leading: IconButton(
            icon: Icon(Icons.arrow_back, color: PetRecordColor.theme),
            onPressed: () {
              Navigator.pop(context);
            },
          ),
        ),
        body: Center(
          child: Transform.translate(
            offset: Offset(0, -50),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                _buildOptionCard(
                  context,
                  icon: Icons.alarm,
                  text: 'Add a Reminder',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddReminder(pet: pet)),
                    );
                  },
                ),
                SizedBox(height: 46),
                _buildOptionCard(
                  context,
                  icon: Icons.edit_calendar_outlined,
                  text: 'Add an Event',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => AddEvent(pet: pet)),
                    );
                  },
                ),
              ],
            ),
          ),
        ));
  }
}

Widget _buildOptionCard(BuildContext context,
    {required IconData icon,
    required String text,
    required VoidCallback onTap}) {
  return GestureDetector(
    onTap: onTap,
    child: SizedBox(
      width: 200,
      child: Card(
        color: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(icon, color: PetRecordColor.theme, size: 60),
              SizedBox(height: 8),
              Text(
                text,
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: PetRecordColor.theme),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
