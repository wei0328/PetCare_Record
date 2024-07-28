import 'package:flutter/material.dart';
import 'package:petcare_record/globalclass/color.dart';

class EventTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Column(
        children: [
          TabBar(
            indicatorColor: Colors.green,
            labelColor: Colors.green,
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
                Center(child: Text('Notification content')),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
