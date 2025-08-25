import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Assuming you'll use Firestore

class ActivityDetailScreen extends StatefulWidget {
  final String activityId;

  const ActivityDetailScreen({Key? key, required this.activityId}) : super(key: key);

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  // Future to hold the activity data
  late Future<DocumentSnapshot> _activityData;

  @override
  void initState() {
    super.initState();
    // Fetch activity data when the widget is initialized
    _activityData = FirebaseFirestore.instance
        .collection('activities')
        .doc(widget.activityId)
        .get();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('活动详情'), // Placeholder title
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future: _activityData,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading activity: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            return const Center(child: Text('Activity not found.'));
          }

          // Activity data is available
          final activityData = snapshot.data!.data() as Map<String, dynamic>;

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder for Activity Title
                Text(
                  activityData['title'] ?? '无标题活动',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: 16),

                // Placeholder for Activity Time
                Text(
                  '时间: ${activityData['time'] ?? '待定'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),

                // Placeholder for Activity Location
                Text(
                  '地点: ${activityData['location'] ?? '待定'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Placeholder for Activity Description
                Text(
                  '描述:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(
                  activityData['description'] ?? '暂无描述',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 16),

                // Placeholder for Organizer Info
                Text(
                  '组织者:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Row(
                  children: [
                    CircleAvatar(
                      radius: 20,
                      backgroundColor: Colors.grey[300], // Placeholder for avatar
                      child: Icon(Icons.person, color: Colors.grey[600]),
                    ),
                    const SizedBox(width: 8),
                    Text(
                      activityData['organizer'] ?? '未知组织者', // Assuming organizer is stored
                      style: Theme.of(context).textTheme.bodyMedium,
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                // Placeholder for Participants List
                Text(
                  '参与者:',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                // You would typically load and display participants here from another collection
                const Text(
                  '暂无参与者', // Placeholder
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 24),

                // Placeholder for "报名参与" Button
                Center(
                  child: ElevatedButton(
                    onPressed: () {
                      // TODO: Implement navigation to registration page
                      print('报名参与 button pressed for activity: ${widget.activityId}');
                    },
                    child: const Text('报名参与'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}