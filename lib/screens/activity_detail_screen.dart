import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart'; // Assuming you'll use Firestore
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

// Convert to StatefulWidget
class ActivityDetailScreen extends StatefulWidget {
  final String activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late final String activityId;
  // Future to hold the activity data
  late Future<Map<String, dynamic>?> _activityDetails;
  bool _isApplied = false; // Changed to non-final for state updates
  String? _dynamicSafetyCode;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    activityId = widget.activityId;
    super.initState();
    // Fetch activity data and check application status when the widget is initialized
    _activityDetails = _fetchActivityDetails();
    _checkIfApplied();
  }

  // Function to generate a simple random string for the safety code
  String _generateSafetyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  // Helper to format Timestamp to a readable date/time string
  String _formatTimestamp(Timestamp? timestamp) {
    // TODO: Implement proper date and time formatting based on duration and locale
    if (timestamp == null) return '待定';
  Future<Map<String, dynamic>?> _fetchActivityDetails() async {
    print('Fetching activity details for ID: $activityId');
    try {
      final activityDoc = await _firestore
        .collection('activities')
        .doc(activityId)
        .get();

      if (!activityDoc.exists) {
        return null;
      }
       print('Activity data fetched: ${activityDoc.data()}'); // Debugging line
      // Return the data directly. FutureBuilder will handle null/error.
      return activityDoc.data();
    } catch (e) {
      return activityDoc.data();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('活动详情'), // Placeholder title
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: _shareActivity,
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _activityDetails, // Use the future to build the UI
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
          final Timestamp? startTime = activityData['startTime'] as Timestamp?; // Keep Timestamp
          final Timestamp? endTime = activityData['endTime'] as Timestamp?; // Fetch end time
          final DateTime? activityStartDateTime = startTime?.toDate(); // Convert to DateTime for comparison/formatting
          final DateTime? activityEndDateTime = endTime?.toDate();

          final int currentParticipants = activityData['currentParticipantsCount'] ?? 0;
          final int maxParticipants = activityData['maxParticipants'] ?? 0;
          // Format date and time
          String formattedDateTime = _formatTimestamp(startTime);

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
                  '人数: $currentParticipants / ${maxParticipants == 0 ? '不限' : maxParticipants}',
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

                // Display Dynamic Safety Code (conditionally)
                if (_dynamicSafetyCode != null) ...[
                  Text(
                    '动态安全码:',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _dynamicSafetyCode!,
                    style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                      color: Theme.of(context).primaryColor, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 16),
                ],

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
                  future: activityData['organizerId'] != null
                      ? _firestore.collection('users').doc(activityData['organizerId']).get()
                      : Future.value(null), // Handle case where organizerId might be missing
                  builder: (context, userSnapshot) {
                    if (userSnapshot.connectionState == ConnectionState.waiting) {
                      return const CircularProgressIndicator();
                    }
                    if (userSnapshot.hasError || !userSnapshot.hasData || !userSnapshot.data!.exists) {
                      return const Text('组织者信息加载失败或不存在');
                    }
                    final userData = userSnapshot.data!.data();
                    final organizerName = userData?['displayName'] ?? '未知用户';
                    final organizerAvatarUrl = userData?['photoUrl'] as String?;
                    // You can add more organizer info here, like avatar, certification status, etc.
                    return Row(
                      children: [
                        CircleAvatar(
                          radius: 20, // Increase avatar size
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
                      .where('activityId', isEqualTo: activityId)
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
                               return const Text('加载参与者...');
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
                                      radius: 15, // Default avatar size
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
                      }).toList(),
                    ),
                    );
                  },
                ),

                const SizedBox(height: 24),

                // Organizer Application Management Section (TODO)
                if (_auth.currentUser?.uid == activityData['organizerId']) ...[
                  const Text(
                    'Organizer Application Management Section (TODO)',
                    style: TextStyle(fontStyle: FontStyle.italic),
                  ),
                const SizedBox(height: 24),

                // "报名参与" Button (conditionally displayed)
                Center(
                  child: _isApplied
                      ? const Text(
                          '您已报名该活动',
                          style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold), // Change text to reflect application status
                        )
                      : (maxParticipants > 0 && currentParticipants >= maxParticipants)
                          ? const Text(
                              '人数已满',
                              style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
                            )
                      : ElevatedButton(
                          onPressed: (maxParticipants > 0 && currentParticipants >= maxParticipants) ? null : _signUpForActivity, // Disable if full
                          child: const Text('报名参与'),
                        ),
                ),
              ],
            ),
          )
        },
      ),
    )
  }
        return null;
      }

      return activityDoc.data();

    } catch (e) {
      print('Error fetching activity details: $e');
      throw e; // Re-throw the error for FutureBuilder to handle
    }
  }

  // Function to check if the current user is already a participant
 Future<void> _checkIfApplied() async {
    final currentUser = _auth.currentUser;
    if (currentUser == null) {
      setState(() {
        _isApplied = false;
        // _isParticipant = false; // Assuming _isParticipant was a typo and should be _isApplied
      });
      return;
    }

    try {
      final querySnapshot = await _firestore // Changed from _isParticipant to _isApplied
          .collection('activity_applications')
          .where('activityId', isEqualTo: activityId)
          .where('userId', isEqualTo: currentUser.uid)
          .limit(1) // We only need to know if at least one application exists
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final applicationData = querySnapshot.docs.first.data();
        final applicationStatus = applicationData['applicationStatus'];
        final safetyCode = applicationData['safetyCode'] as String?;

        // Check if activity has started
        final activityDoc = await _firestore.collection('activities').doc(activityId).get();
        final activityData = activityDoc.data();
        final Timestamp? startTime = activityData?['startTime'] as Timestamp?;
        final DateTime? activityDateTime = startTime?.toDate();
        final bool hasStarted = activityDateTime != null && activityDateTime.isBefore(DateTime.now());

        // If activity has started, user is applied, and safety code is missing, generate and save it
        if (hasStarted && applicationStatus == 'approved' && safetyCode == null) { // Assuming 'approved' is the status for participation
          final newSafetyCode = _generateSafetyCode();
          await _firestore.collection('activity_applications').doc(querySnapshot.docs.first.id).update({ // Update the first (and should be only) application document
            'safetyCode': newSafetyCode,
          });
          _dynamicSafetyCode = newSafetyCode; // Update local state
        }
        setState(() {
          _isApplied = true; // User has an application
          // Display safety code only if activity has started and application is approved (adjust status as per your logic)
          if (hasStarted && applicationStatus == 'approved' && safetyCode != null) {
             _dynamicSafetyCode = safetyCode;
          }
        });
      } else {
         setState(() {
          _isApplied = false;
        });
      }
    } catch (e) {
      print('Error checking application status: $e');
       setState(() {
        _isApplied = false;
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
       // Check if the user has already applied to avoid duplicate applications
      final existingApplication = await _firestore
          .collection('activity_applications')
          .where('activityId', isEqualTo: activityId)
          .where('userId', isEqualTo: currentUser.uid)
          .limit(1)
          .get();

      if (existingApplication.docs.isNotEmpty) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('您已经报名过该活动了')),
          );
          return;
      }

      // Add application to activity_applications collection
      await _firestore.collection('activity_applications').add({
        'activityId': activityId,
        'userId': currentUser.uid, 'applicationStatus': 'pending', // Initial status can be 'pending', 'approved', etc.
        'appliedAt': DateTime.now(), 'safetyCode': null, // Add safetyCode field, initially null
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
        _isApplied = true;
      });

    } catch (e) {
      print('Error signing up for activity: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('报名失败：$e')),
      );
    }
  }

  // Function to handle activity sharing
  void _shareActivity() async {
     final activityData = await _activityDetails; // Await the future to get the data
     if (activityData == null) {
       // Handle case where activity data is not loaded
       ScaffoldMessenger.of(context).showSnackBar(
         const SnackBar(content: Text('活动详情未加载，无法分享。')),
       );
       return;
     }

     final String title = activityData['title'] ?? '一个活动';
     final String location = activityData['location'] ?? '线上';
     final Timestamp? startTime = activityData['startTime'] as Timestamp?;
     final DateTime? activityDateTime = startTime?.toDate();
     final String formattedDateTime = activityDateTime != null ? '${activityDateTime.year}-${activityDateTime.month}-${activityDateTime.day} ${activityDateTime.hour}:${activityDateTime.minute.toString().padLeft(2, '0')}' : '待定';
     final String shareText = '快来看看这个活动："$title"！\n时间：$formattedDateTime\n地点：$location\n\n[分享链接待定]'; // You might want to generate a proper shareable link
     Share.share(shareText, subject: '推荐一个活动给你');
  }

}