import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class MyPage extends StatefulWidget {
  const MyPage({super.key});

  @override
  State<MyPage> createState() => _MyPageState();
}

class _MyPageState extends State<MyPage> {
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
        title: const Text('我的页面'),
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
          final nickname = userData['nickname'] ?? '新用户';
          final authStatus = userData['auth_status'] ?? '未知';
          final level = userData['level'] ?? '基础用户';
          // Placeholder for credit score, assuming it will be added later // Added credit score placeholder
          const creditScore = '--';

          return Padding(
            padding: const EdgeInsets.all(16.0), // Added padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                const CircleAvatar(
                  radius: 40,
                  backgroundColor: Colors.grey, // Placeholder color
                  child: Icon(Icons.person, size: 40, color: Colors.white), // Placeholder icon
                ), // Added avatar placeholder
                const SizedBox(height: 16),
                Text(
                  nickname,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: 8),
                Text('等级: $level', style: Theme.of(context).textTheme.titleMedium), // Display level
                const SizedBox(height: 8),
                Text('认证状态: $authStatus', style: Theme.of(context).textTheme.titleMedium), // Display auth status
                const SizedBox(height: 8),
                Text('信用分: $creditScore', style: Theme.of(context).textTheme.titleMedium), // Display credit score placeholder
                const SizedBox(height: 24),
                // Placeholder for Navigation Options
                ListTile(
                  leading: const Icon(Icons.history),
                  title: const Text('活动历史'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16), // Added trailing icon
                  onTap: () {
                    // TODO: Navigate to Activity History Page
                  },
                ),
                const Divider(),
                ListTile(
                  leading: const Icon(Icons.event_note), // Added leading icon
                  title: const Text('我的报名'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16), // Added trailing icon
                  onTap: () {
                    // TODO: Navigate to My Registrations Page
                  },
                ),
                const Divider(), // Added Divider
                ListTile(
                  leading: const Icon(Icons.settings),
                  title: const Text('设置'),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                  onTap: () {
                    // TODO: Navigate to Settings Page
                  },
                ),
                const Divider(),
                const Expanded(child: SizedBox()), // Pushes logout button to the bottom
                ElevatedButton(
                  onPressed: () async { // Added logout button
                    await FirebaseAuth.instance.signOut();
                     if (mounted) {
                      Navigator.of(context).pushNamedAndRemoveUntil('/login', (route) => false);
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
          );
        },
      ),
    );
  }
}