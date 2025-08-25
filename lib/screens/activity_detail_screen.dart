import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

class ActivityDetailScreen extends StatefulWidget {
  final String activityId;

  const ActivityDetailScreen({super.key, required this.activityId});

  @override
  _ActivityDetailScreenState createState() => _ActivityDetailScreenState();
}

class _ActivityDetailScreenState extends State<ActivityDetailScreen> {
  late final String activityId;
  late Future<Map<String, dynamic>?> _activityDetails;
  bool _isApplied = false;
  String? _dynamicSafetyCode;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    activityId = widget.activityId;
    _activityDetails = _fetchActivityDetails();
    _checkIfApplied();
  }

  String _generateSafetyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return '时间未知';
    final date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>?> _fetchActivityDetails() async {
    try {
      final doc = await _firestore.collection('activities').doc(activityId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error fetching activity details: $e');
      return null;
    }
  }

  Future<void> _checkIfApplied() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection('activities')
            .doc(activityId)
            .collection('participants')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data();
          setState(() {
            _isApplied = true;
            _dynamicSafetyCode = data?['dynamicSafetyCode'];
          });
        }
      }
    } catch (e) {
      print('Error checking application status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('活动详情'),
        actions: [
          IconButton(
            icon: const Icon(Icons.share),
            onPressed: () => _shareActivity(),
          ),
        ],
      ),
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _activityDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          
          if (snapshot.hasError) {
            return Center(child: Text('加载失败: ${snapshot.error}'));
          }
          
          final activityData = snapshot.data;
          if (activityData == null) {
            return const Center(child: Text('活动不存在'));
          }
          
          return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Activity Title
                Text(
                  activityData['title'] ?? '无标题',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 16),
                
                // Activity Time
                Row(
                  children: [
                    const Icon(Icons.access_time),
                    const SizedBox(width: 8),
                    Text(_formatTimestamp(activityData['startTime'])),
                  ],
                ),
                const SizedBox(height: 8),
                
                // Activity Location
                Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    Text(activityData['location'] ?? '未知地点'),
                  ],
                ),
                const SizedBox(height: 16),
                
                // Description
                Text(
                  '活动描述',
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 8),
                Text(activityData['description'] ?? '暂无描述'),
                const SizedBox(height: 16),
                
                // Participants info
                Row(
                  children: [
                    const Icon(Icons.people),
                    const SizedBox(width: 8),
                    Text('${activityData['currentParticipantsCount'] ?? 0}/${activityData['maxParticipants'] ?? 0} 人'),
                  ],
                ),
                const SizedBox(height: 24),
                
                // Safety Code (if applied)
                if (_isApplied && _dynamicSafetyCode != null) ...[
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Colors.green.shade50,
                      border: Border.all(color: Colors.green),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Column(
                      children: [
                        const Text('安全码', style: TextStyle(fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(
                          _dynamicSafetyCode!,
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],
                
                // Apply Button
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isApplied ? null : () => _signUpForActivity(),
                    child: Text(_isApplied ? '已报名' : '立即报名'),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _signUpForActivity() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请先登录')),
      );
      return;
    }

    try {
      // Generate safety code
      final safetyCode = _generateSafetyCode();
      
      // Add user to participants
      await _firestore
          .collection('activities')
          .doc(activityId)
          .collection('participants')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'joinedAt': FieldValue.serverTimestamp(),
        'dynamicSafetyCode': safetyCode,
      });

      // Update participant count
      await _firestore.collection('activities').doc(activityId).update({
        'currentParticipantsCount': FieldValue.increment(1),
      });

      setState(() {
        _isApplied = true;
        _dynamicSafetyCode = safetyCode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('报名成功！')),
      );
    } catch (e) {
      print('Error signing up: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('报名失败，请重试')),
      );
    }
  }

  void _shareActivity() {
    Share.share('查看这个精彩活动！');
  }
}