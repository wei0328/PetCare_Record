import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:petcare_record/globalclass/color.dart';

class DailyEventTab extends StatelessWidget {
  final DateTime selectedDate;

  DailyEventTab({required this.selectedDate});

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
                _buildNotificationsTab(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEventsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Events And Reminders')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('PetEvents')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(children: [SizedBox(height: 40), Text('No Events')]);
        }

        List<Map<String, dynamic>> allEvents = [];

        for (var doc in snapshot.data!.docs) {
          var eventData = doc.data();
          if (eventData.containsKey('events')) {
            var events = eventData['events'] as List<dynamic>;

            List<Map<String, dynamic>> filteredEvents = events
                .where((event) {
                  DateTime eventDate =
                      (event['eventDate'] as Timestamp).toDate();
                  return eventDate.year == selectedDate.year &&
                      eventDate.month == selectedDate.month &&
                      eventDate.day == selectedDate.day;
                })
                .map((event) => event as Map<String, dynamic>)
                .toList();

            allEvents.addAll(filteredEvents);
          }
        }

        if (allEvents.isEmpty) {
          return Column(children: [SizedBox(height: 40), Text('No Events')]);
        }

        return ListView.builder(
          itemCount: allEvents.length,
          itemBuilder: (context, index) {
            var event = allEvents[index];
            var petName = event['petName'] ?? '';
            var eventType = event['type'] ?? 'No title';
            var memo = event['memo'] ?? '';
            var date = (event['eventDate'] as Timestamp).toDate();
            var formattedDate = DateFormat('yyyy-MM-dd').format(date);

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
                          Text(petName,
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: Colors.grey[800])),
                          SizedBox(height: 5),
                          Text(
                            eventType,
                            style: TextStyle(
                                fontWeight: FontWeight.w600,
                                color: Colors.grey[600]),
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
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w500),
                                ),
                              ],
                            ),
                          ],
                        ],
                      ),
                    ),
                    if (eventType == 'Picture')
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
                              fontWeight: FontWeight.bold,
                              color: PetRecordColor.theme,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildNotificationsTab() {
    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('Events And Reminders')
          .doc(FirebaseAuth.instance.currentUser?.uid)
          .collection('PetReminders')
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return Column(
              children: [SizedBox(height: 40), Text('No Notifications')]);
        }

        List<Map<String, dynamic>> allReminders = [];

        for (var doc in snapshot.data!.docs) {
          var reminderData = doc.data();
          if (reminderData.containsKey('reminders')) {
            var reminders = reminderData['reminders'] as List<dynamic>;

            for (var reminder in reminders) {
              var notificationTimes =
                  reminder['notificationTimes'] as List<dynamic>;

              for (var notificationTime in notificationTimes) {
                DateTime reminderDate =
                    (notificationTime as Timestamp).toDate();
                if (reminderDate.year == selectedDate.year &&
                    reminderDate.month == selectedDate.month &&
                    reminderDate.day == selectedDate.day) {
                  allReminders.add(reminder);
                }
              }
            }
          }
        }

        if (allReminders.isEmpty) {
          return Column(
              children: [SizedBox(height: 40), Text('No Notifications')]);
        }

        return ListView.builder(
          itemCount: allReminders.length,
          itemBuilder: (context, index) {
            var reminder = allReminders[index];
            var note = reminder['note'] ?? '';
            var isOnce = reminder['isOnce'] as bool;
            var petName = reminder['petName'] ?? 'Unknown Pet';
            var type = reminder['type'] ?? 'No type';
            var date =
                (reminder['notificationTimes'][index] as Timestamp).toDate();
            var formattedDate = DateFormat('yyyy-MM-dd').format(date);

            String subtitleText;
            if (isOnce) {
              var time = reminder['time'] ?? '';
              subtitleText = '$time';
            } else {
              subtitleText = 'Repeated Notification';
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
                          Text(petName,
                              style: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey[800])),
                          if (isOnce) ...[
                            SizedBox(height: 5),
                            Row(
                              children: [
                                Expanded(
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
                                ),
                                Icon(Icons.alarm, size: 20, color: Colors.grey),
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
                                Expanded(
                                  child: Text(
                                    type,
                                    style: TextStyle(
                                      color: Colors.grey[700],
                                      fontWeight: FontWeight.w600,
                                    ),
                                  ),
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
              ),
            );
          },
        );
      },
    );
  }
}
