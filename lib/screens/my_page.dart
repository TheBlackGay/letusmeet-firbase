import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:myapp/lib/widgets/activity_card_widget.dart';
import 'package:myapp/lib/screens/emergency_contact_settings_screen.dart';
import 'package:myapp/lib/screens/activity_detail_screen.dart';

class MyPage extends StatefulWidget { // Convert MyPage to StatefulWidget
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
  final currentUser = FirebaseAuth.instance.currentUser; // Fetch current user

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) { // Add this check
      // Handle case where user is not logged in, though the routing should prevent this
      return const Center(child: Text('User not logged in'));
    }

    // Fetch user data from Firestore
    // Using a StreamBuilder to listen for real-time updates to the user document
    return Scaffold(
      appBar: AppBar( // Added AppBar
        title: const Text('我的'),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
      ),
      body: StreamBuilder<DocumentSnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }
          if (!snapshot.hasData || !snapshot.data!.exists) {
            // Handle case where user document doesn't exist (shouldn't happen after registration) // Added data not found handling
            return const Center(child: Text('User data not found.'));
          }

          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final displayName = userData['displayName'] ?? '新用户';
          final photoUrl = userData['photoUrl'];
          // You can fetch other user data like credit score, auth status here when available

          return Padding(
            padding: const EdgeInsets.all(16.0), // Added padding
            child: ListView( // Use ListView for scrolling content
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    CircleAvatar(
                      radius: 40,
                      backgroundColor: Colors.grey, // Placeholder color
                      backgroundImage: photoUrl != null ? NetworkImage(photoUrl) : null,
                      child: photoUrl == null ? const Icon(Icons.person, size: 40, color: Colors.white) : null,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      displayName,
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    // Placeholder for other user info like level, auth status, credit score
                    const SizedBox(height: 24),
                  ],
                ),
                // Placeholder for Navigation Options
                Card( // Wrap ListTile in Card for better visual separation
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                  leading: const Icon(Icons.event_note), // Added leading icon
                  title: const Text('我的报名'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16), // Added trailing icon
                  onTap: () {
                    // TODO: Navigate to a dedicated page for '我参与的活动' if needed, or show in this page
                  },
                ),
                const Divider(),
                Card( // Wrap ListTile in Card for better visual separation
                  margin: const EdgeInsets.symmetric(vertical: 4.0),
                  child: ListTile(
                    leading: const Icon(Icons.contact_phone), // Changed icon to match PRD
                    title: const Text('紧急联系人设置'),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {
                      Navigator.of(context).push(
                        MaterialPageRoute(builder: (context) => const EmergencyContactSettingsScreen()),
                      );
                    },
                  )),
                Text(
                  '我参与的活动',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                // StreamBuilder for activities the user has applied for
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('activity_applications')
                      .where('userId', isEqualTo: currentUser!.uid)
                      .snapshots(),
                  builder: (context, applicationSnapshot) {
                    if (applicationSnapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (applicationSnapshot.hasError) {
                      return Center(child: Text('Error loading applications: ${applicationSnapshot.error}'));
                    }
                    if (!applicationSnapshot.hasData || applicationSnapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('您还没有报名的活动。'));
                    }

                    final appliedActivityIds = applicationSnapshot.data!.docs.map((doc) => doc['activityId']).toList();

                    if (appliedActivityIds.isEmpty) {
                       return const Center(child: Text('您还没有报名的活动。'));
                    }

                    // Now fetch the actual activity details for these IDs
                    return FutureBuilder<QuerySnapshot>( // Using FutureBuilder as we have a list of IDs
                       future: FirebaseFirestore.instance
                           .collection('activities')
                           .where(FieldPath.documentId, whereIn: appliedActivityIds)
                           .get(),
                       builder: (context, activitySnapshot) {
                         if (activitySnapshot.connectionState == ConnectionState.waiting) {
                           return const Center(child: CircularProgressIndicator());
                         }
                         if (activitySnapshot.hasError) {
                           return Center(child: Text('Error loading applied activities: ${activitySnapshot.error}'));
                         }
                         if (!activitySnapshot.hasData || activitySnapshot.data!.docs.isEmpty) {
                            return const Center(child: Text('未能加载报名的活动。'));
                         }

                         final appliedActivities = activitySnapshot.data!.docs;

                         return ListView.builder(
                           shrinkWrap: true, // Important for nested ListViews
                           physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this inner list
                           itemCount: appliedActivities.length,
                           itemBuilder: (context, index) {
                             final activity = appliedActivities[index];
                             return ActivityCardWidget(activity: activity); // Reuse ActivityCardWidget
                           },
                         );
                       },
                    );
                  },
                ),

                const SizedBox(height: 24),
                Text(
                  '我发布的活动',
                  style: Theme.of(context).textTheme.titleLarge,
                ),
                const SizedBox(height: 8),
                // StreamBuilder for activities the user has organized
                StreamBuilder<QuerySnapshot>(
                  stream: FirebaseFirestore.instance
                      .collection('activities')
                      .where('organizerId', isEqualTo: currentUser!.uid)
                      .snapshots(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return const Center(child: CircularProgressIndicator());
                    }
                    if (snapshot.hasError) {
                      return Center(child: Text('Error loading organized activities: ${snapshot.error}'));
                    }
                    if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                      return const Center(child: Text('您还没有发布的活动。'));
                    }

                    final organizedActivities = snapshot.data!.docs;

                    return ListView.builder(
                      shrinkWrap: true, // Important for nested ListViews
                      physics: const NeverScrollableScrollPhysics(), // Disable scrolling for this inner list
                      itemCount: organizedActivities.length,
                      itemBuilder: (context, index) {
                        final activity = organizedActivities[index];
                        return ActivityCardWidget(activity: activity); // Reuse ActivityCardWidget
                      },
                    );
                  },
                ),

                const SizedBox(height: 40), // Space before logout button
                ElevatedButton(
                  onPressed: () async { // Added logout button
                    await FirebaseAuth.instance.signOut();
                     if (mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/authentication', (route) => false); // Navigate to authentication screen after logout
                     }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                  ),
                  child: const Text('退出登录'),
                ),
              ],
            ),
          ); // Wrap in ListView for scrolling
        },
      ),
    );
  }
}