import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:intl/intl.dart';

class EventTab extends StatelessWidget {
  final String petId;

  EventTab({required this.petId});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: PetRecordColor.theme,
            labelColor: PetRecordColor.theme,
            unselectedLabelColor: Colors.grey,
            labelStyle: TextStyle(fontWeight: FontWeight.bold),
            tabs: [
              Tab(text: 'Event'),
              Tab(text: 'Notification'),
            ],
          ),
          Expanded(
            child: TabBarView(
              children: [
                Center(child: Text('Event content')),
                _buildNotificationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNotificationsTab() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Reminders')
          .doc(petId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Center(child: Text('No notifications'));
        }

        var reminderData = snapshot.data!.data();
        if (reminderData == null || reminderData.isEmpty) {
          return Center(child: Text('No notifications'));
        }

        var reminders = reminderData['reminders'] as List<dynamic>;
        return ListView.builder(
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            var reminder = reminders[index] as Map<String, dynamic>;
            var dateTime = (reminder['dateTime'] as Timestamp).toDate();
            var time = reminder['time'] ?? 'No time specified';
            var note = reminder['note'] ?? '';
            var isOnce = reminder['isOnce'] as bool;
            var formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
            var formattedTime =
                reminder['time'] ?? DateFormat('hh:mm a').format(dateTime);

            String subtitleText;
            if (isOnce) {
              subtitleText = 'Scheduled for: $formattedDate at $formattedTime';
            } else {
              var frequencyNumber = reminder['frequencyNumber'] ?? 1;
              var frequencyUnit = reminder['frequencyUnit'] ?? 'Day';
              subtitleText = 'Repeats every $frequencyNumber $frequencyUnit';
            }

            if (note.isNotEmpty) {
              subtitleText += '\nNote: $note';
            }

            return ListTile(
              title: Text(reminder['type'] ?? 'No title'),
              subtitle: Text(subtitleText),
            );
          },
        );
      },
    );
  }
}
