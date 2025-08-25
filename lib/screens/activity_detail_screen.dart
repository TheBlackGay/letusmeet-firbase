import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Assuming you'll use Firestore
import 'package:firebase_auth/firebase_auth.dart';

// Convert to StatefulWidget
class ActivityDetailScreen extends StatefulWidget {
  final String activityId;

  const ActivityDetailScreen({Key? key, required this.activityId}) : super(key: key);

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  // Future to hold the activity data
  late Future<Map<String, dynamic>?> _activityDetails;
  bool _isParticipant = false;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    // Fetch activity data when the widget is initialized
    _activityDetails = _fetchActivityDetails();
    _checkIfParticipant();
  }

  Future<Map<String, dynamic>?> _fetchActivityDetails() async {
    try {
      final activityDoc = await _firestore
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
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _activityDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error loading activity: ${snapshot.error}'));
          }
          if (!snapshot.hasData || snapshot.data == null) {
            return const Center(child: Text('Activity not found.'));
          }

          // Activity data is available
          final activityData = snapshot.data!;
          final Timestamp? startTime = activityData['startTime'] as Timestamp?;
          final DateTime? activityDateTime = startTime?.toDate();

          // Format date and time
          String formattedDateTime = '待定';
          if (activityDateTime != null) {
            formattedDateTime =
                '${activityDateTime.year}-${activityDateTime.month}-${activityDateTime.day} ${activityDateTime.hour}:${activityDateTime.minute.toString().padLeft(2, '0')}';
          }

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Placeholder for Activity Title
                Text(
                  activityData['title'] ?? '无标题活动',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 16),

                // Placeholder for Activity Time
                Text(
                  '时间: $formattedDateTime',
                  style: Theme.of(context).textTheme.bodyMedium,

                ),
                const SizedBox(height: 8),

                // Placeholder for Activity Location
                Text(
                  '地点: ${activityData['location'] ?? '线上活动'}',
                  style: Theme.of(context).textTheme.bodyMedium,

                ),
                const SizedBox(height: 16),

                // Display Max Participants and Current Participants
                Text(
                  '人数: ${activityData['currentParticipantsCount'] ?? 0} / ${activityData['maxParticipants'] ?? '不限'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 8),

                // Display Cost
                 Text(
                  '费用: ${activityData['cost'] ?? '免费'}',
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                 const SizedBox(height: 16),

                // Display Activity Type
                 Text(
                  '类型: ${activityData['type'] ?? '其他'}',
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

                // Organizer Info
                Text(
                  '组织者:',
                  style: Theme.of(context).textTheme.titleMedium,

                ),
                const SizedBox(height: 8),
                FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                  future: _firestore.collection('users').doc(activityData['organizerId']).get(),
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return const Text('组织者信息加载失败或不存在');
                    }
                    final userData = userSnapshot.data!.data();
                    final organizerName = userData?['displayName'] ?? '未知用户';
                    // You can add more organizer info here, like avatar, certification status, etc.
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 20,
                           // You would load the organizer's avatar here
                          backgroundColor: Colors.grey[300],
                          child: Icon(Icons.person, color: Colors.grey[600]),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          organizerName,
                          style: Theme.of(context).textTheme.bodyMedium,
                        ),
                        // Add more organizer info widgets here
                      ],
                    );
                  },
                ),
                const SizedBox(height: 16),

                // Participants List
                Text(
                  '参与者:',
                  style: Theme.of(context).textTheme.titleMedium,

                ),
                const SizedBox(height: 8),
                FutureBuilder<QuerySnapshot<Map<String, dynamic>>>(
                  future: _firestore
                      .collection('activity_applications')
                      .where('activityId', isEqualTo: widget.activityId)
                      .where('applicationStatus', isEqualTo: 'approved') // Assuming you only show approved participants
                      .get(),
                  builder: (context, participantsSnapshot) {
                     if (participantsSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (participantsSnapshot.hasError) {
                      return const Text('参与者信息加载失败');
                    }
                    if (!participantsSnapshot.hasData || participantsSnapshot.data!.docs.isEmpty) {
                      return const Text('暂无参与者');
                    }

                    final participants = participantsSnapshot.data!.docs;

                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: participants.map((doc) {
                        final participantData = doc.data();
                        final participantUserId = participantData['userId'];
                        // Fetch participant user data
                        return FutureBuilder<DocumentSnapshot<Map<String, dynamic>>>(
                           future: _firestore.collection('users').doc(participantUserId).get(),
                           builder: (context, participantUserSnapshot) {
                             if (participantUserSnapshot.connectionState == ConnectionState.waiting) {
                               return const Text('加载中...');
                             }
                             if (participantUserSnapshot.hasError || !participantUserSnapshot.hasData || !participantUserSnapshot.data!.exists) {
                               return const Text('未知参与者');
                             }
                             final participantUserData = participantUserSnapshot.data!.data();
                             final participantName = participantUserData?['displayName'] ?? '未知用户';
                             return Padding(
                               padding: const EdgeInsets.symmetric(vertical: 4.0),
                               child: Row(
                                  children: [
                                     CircleAvatar(
                                      radius: 15,
                                       // You would load the participant's avatar here
                                      backgroundColor: Colors.blueGrey[200],
                                       child: Icon(Icons.person_outline, color: Colors.blueGrey[600]),
                                    ),
                                    const SizedBox(width: 8),
                                    Text(participantName),
                                    // Add more participant info here if needed
                                  ],
                               ),
                             );
                           },
                        );
                      }).toList(),
                    ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // "报名参与" Button (conditionally displayed)
                Center(
                  child: _isParticipant
                      ? const Text('您已报名该活动', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold))
                      : ElevatedButton(
                          onPressed: _signUpForActivity,
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

  // Function to fetch activity details including organizer and participants
  Future<Map<String, dynamic>?> _fetchActivityDetails() async {
    try {
      final activityDoc = await _firestore
          .collection('activities')
          .doc(widget.activityId)
          .get();

      if (!activityDoc.exists) {
        return null;
      }

      return activityDoc.data();

    } catch (e) {
      print('Error fetching activity details: $e');
      throw e; // Re-throw the error for FutureBuilder to handle
    }
  }

  // Function to check if the current user is already a participant
  Future<void> _checkIfParticipant() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _isParticipant = false;
      });
      return;
    }

    try {
      final querySnapshot = await _firestore
          .collection('activity_applications')
          .where('activityId', isEqualTo: widget.activityId)
          .where('userId', isEqualTo: currentUser.uid)
          .limit(1) // We only need to know if at least one application exists
          .get();

      setState(() {
        _isParticipant = querySnapshot.docs.isNotEmpty;
      });
    } catch (e) {
      print('Error checking participation status: $e');
      // Handle error, maybe set _isParticipant to false and show an error message
       setState(() {
        _isParticipant = false;
      });
    }
  }

  // Function to handle activity sign-up
  Future<void> _signUpForActivity() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      // Prompt user to login
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录以报名活动')),
      );
      return;
    }

    try {
      // Add application to activity_applications collection
      await _firestore.collection('activity_applications').add({
        'activityId': widget.activityId,
        'userId': currentUser.uid,
        'applicationStatus': 'pending', // Initial status can be 'pending', 'approved', etc.
        'appliedAt': DateTime.now(),
      });

      // Update current participants count in activities collection (optional, but good practice)
      // Note: This is a basic update. For concurrent updates, consider using transactions or Cloud Functions.
      final activityRef = _firestore.collection('activities').doc(widget.activityId);
      _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(activityRef);
        if (snapshot.exists) {
          final currentCount = snapshot.data()?['currentParticipantsCount'] ?? 0;
          transaction.update(activityRef, {'currentParticipantsCount': currentCount + 1});
        }
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('报名成功！等待组织者审核。')), // Or '报名成功！' if no approval needed
      );

      // Update UI to reflect participation status
      setState(() {
        _isParticipant = true;
      });

    } catch (e) {
      print('Error signing up for activity: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('报名失败：$e')),
      );
    }
  }
}