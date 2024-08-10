import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:petcare_record/globalclass/color.dart';
import 'package:intl/intl.dart';
import 'package:petcare_record/pages/addEvent/event.dart';
import 'package:petcare_record/pages/myPets/my_pets_page.dart';
import 'package:petcare_record/pages/addEvent/reminder.dart';

class EventTab extends StatelessWidget {
  final Pet pet;

  const EventTab({Key? key, required this.pet}) : super(key: key);

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
                _buildEventsTab(),
                _buildNotificationsTab(context),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Events And Reminders')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('PetEvents')
          .doc(pet.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Column(children: [SizedBox(height: 40), Text('No Events')]);
        }

        var eventData = snapshot.data!.data();
        if (eventData == null || eventData.isEmpty) {
          return Column(children: [SizedBox(height: 40), Text('No Events')]);
        }

        var events = eventData['events'] as List<dynamic>;
        return ListView.builder(
          itemCount: events.length,
          itemBuilder: (context, index) {
            var event = events[index] as Map<String, dynamic>;
            var date = (event['eventDate'] as Timestamp).toDate();
            var formattedDate = DateFormat('yyyy-MM-dd').format(date);
            var memo = event['memo'] ?? '';
            var eventType = event['type'] ?? 'No title';
            var isPictureEvent = eventType == 'Picture';

            String rightSideText = '';
            Color indicatorColor = Colors.grey;
            if (eventType == 'Weight') {
              rightSideText = '${event['weight']} ${event['weightUnit']}';
              indicatorColor = Colors.orange[100]!;
            } else if (eventType == 'Temperature') {
              rightSideText =
                  '${event['temperature']} ${event['temperatureUnit']}';
              indicatorColor = Colors.blue[100]!;
            } else if (eventType == 'Picture') {
              indicatorColor = Colors.green[100]!;
            } else if (eventType == 'Other') {
              rightSideText = event['description'] ?? 'No description';
              indicatorColor = Colors.blueGrey[100]!;
            }

            return IntrinsicHeight(
              child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 6,
                        color: indicatorColor,
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(eventType,
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800])),
                            SizedBox(height: 5),
                            Text(
                              formattedDate,
                              style: TextStyle(
                                  color: Colors.grey[600],
                                  fontWeight: FontWeight.w500,
                                  fontSize: 14),
                            ),
                            if (memo.isNotEmpty) ...[
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.edit_document,
                                      size: 20, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(
                                    memo,
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                          ],
                        ),
                      ),
                      if (isPictureEvent)
                        Container(
                          width: 50,
                          height: 50,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.grey[300],
                          ),
                          child: event['imagePath'] != null
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(10),
                                  child: Image.file(
                                    File(event['imagePath']),
                                    fit: BoxFit.cover,
                                  ),
                                )
                              : Icon(Icons.image, size: 30),
                        )
                      else if (rightSideText.isNotEmpty)
                        Container(
                          padding: EdgeInsets.all(8.0),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: Colors.transparent,
                          ),
                          child: Center(
                            child: Text(
                              rightSideText,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: PetRecordColor.theme,
                                  fontSize: 16),
                            ),
                          ),
                        ),
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Event(
                          pet: pet,
                          existingEvent: event,
                        ),
                      ),
                    );
                  }),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationsTab(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Events And Reminders')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('PetReminders')
          .doc(pet.id)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || !snapshot.data!.exists) {
          return Column(
              children: [SizedBox(height: 40), Text('No Notifications')]);
        }

        var reminderData = snapshot.data!.data();
        if (reminderData == null || reminderData.isEmpty) {
          return Column(
              children: [SizedBox(height: 40), Text('No Notifications')]);
        }

        var reminders = reminderData['reminders'] as List<dynamic>;

        return ListView.builder(
          itemCount: reminders.length,
          itemBuilder: (context, index) {
            var reminder = reminders[index] as Map<String, dynamic>;

            Timestamp? timestamp = reminder['dateTime'] as Timestamp?;
            DateTime dateTime =
                timestamp != null ? timestamp.toDate() : DateTime.now();

            var formattedDate = DateFormat('yyyy-MM-dd').format(dateTime);
            var formattedTime =
                reminder['time'] ?? DateFormat('hh:mm a').format(dateTime);
            var note = reminder['note'] ?? '';
            var isOnce = reminder['isOnce'] as bool;

            String subtitleText;
            if (isOnce) {
              subtitleText = '$formattedDate  $formattedTime';
            } else {
              var frequencyNumber = reminder['frequencyNumber'] ?? 1;
              var frequencyUnit = reminder['frequencyUnit'] ?? 'Day';
              subtitleText = 'Every $frequencyNumber $frequencyUnit';
            }

            return IntrinsicHeight(
              child: ListTile(
                  contentPadding:
                      EdgeInsets.symmetric(vertical: 10.0, horizontal: 16.0),
                  title: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Container(
                        width: 6,
                        color: Colors.grey[300],
                      ),
                      SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(reminder['type'] ?? 'No title',
                                style: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: Colors.grey[800])),
                            if (isOnce) ...[
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.alarm,
                                      size: 20, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(
                                    subtitleText,
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ] else ...[
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.loop_sharp,
                                      size: 20, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(
                                    subtitleText,
                                    style: TextStyle(
                                        color: Colors.grey[600],
                                        fontWeight: FontWeight.w500,
                                        fontSize: 14),
                                  ),
                                ],
                              ),
                            ],
                            if (note.isNotEmpty) ...[
                              SizedBox(height: 5),
                              Row(
                                children: [
                                  Icon(Icons.edit_document,
                                      size: 20, color: Colors.grey),
                                  SizedBox(width: 5),
                                  Text(
                                    note,
                                    style: TextStyle(
                                        color: Colors.grey[700],
                                        fontWeight: FontWeight.w500),
                                  ),
                                ],
                              )
                            ]
                          ],
                        ),
                      )
                    ],
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => Reminder(
                          pet: pet,
                          existingReminder: reminder,
                        ),
                      ),
                    );
                  }),
            );
          },
        );
      },
    );
  }
}
