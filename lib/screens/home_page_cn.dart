import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/activity_list_item_widget.dart';
import '../widgets/animated_activity_card.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_staggered_animations/flutter_staggered_animations.dart';
import '../config/app_config.dart';
import '../services/mock_data_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _selectedActivityTypes = [];
  String _selectedSortOption = 'dateDescending';

  void _showFilterSortBottomSheet() {
    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (BuildContext context) {
        return Container(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '筛选和排序',
                style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.bold,
                ),
              ).animate().fadeIn(delay: 200.ms),
              const SizedBox(height: 24),

              Text(
                '活动类型',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                children: [
                  '户外运动',
                  '聚餐聚会',
                  '文化艺术',
                  '学习交流',
                  '旅游出行',
                  '其他'
                ].map((type) {
                  return FilterChip(
                    label: Text(type),
                    selected: _selectedActivityTypes.contains(type),
                    onSelected: (bool selected) {
                      setState(() {
                        if (selected) {
                          _selectedActivityTypes.add(type);
                        } else {
                          _selectedActivityTypes.remove(type);
                        }
                      });
                    },
                  );
                }).toList(),
              ),
              const SizedBox(height: 24),
              
              Text(
                '排序方式',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('最新优先'),
                    value: 'dateDescending',
                    groupValue: _selectedSortOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedSortOption = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('最早优先'),
                    value: 'dateAscending',
                    groupValue: _selectedSortOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedSortOption = value!;
                      });
                    },
                  ),
                ],
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      setState(() {
                        _selectedActivityTypes.clear();
                        _selectedSortOption = 'dateDescending';
                      });
                      Navigator.pop(context);
                    },
                    child: const Text('重置'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context);
                    },
                    child: const Text('应用'),
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Query<Map<String, dynamic>>? _buildQuery() {
    if (AppConfig.useMockData) {
      return null;
    }

    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('activities');

    if (_selectedActivityTypes.isNotEmpty) {
      query = query.where('activityType', whereIn: _selectedActivityTypes);
    }

    if (_selectedSortOption == 'dateDescending') {
      query = query.orderBy('startTime', descending: true);
    } else if (_selectedSortOption == 'dateAscending') {
      query = query.orderBy('startTime', descending: false);
    }

    return query;
  }

  List<Map<String, dynamic>> _getFilteredMockData() {
    List<Map<String, dynamic>> activities = MockDataService.getMockActivities();
    
    if (_selectedActivityTypes.isNotEmpty) {
      activities = activities.where((activity) {
        return _selectedActivityTypes.contains(activity['activityType']);
      }).toList();
    }
    
    if (_selectedSortOption == 'dateDescending') {
      activities.sort((a, b) => (b['startTime'] as Timestamp).compareTo(a['startTime'] as Timestamp));
    } else if (_selectedSortOption == 'dateAscending') {
      activities.sort((a, b) => (a['startTime'] as Timestamp).compareTo(b['startTime'] as Timestamp));
    }
    
    return activities;
  }

  String _formatActivityTime(Map<String, dynamic> activityData) {
    final startTime = activityData['startTime'] as Timestamp?;
    if (startTime == null) return '时间待定';
    
    final date = startTime.toDate();
    return DateFormat('MM月dd日 • HH:mm').format(date);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          '轻约',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: 24,
          ),
        ).animate().fadeIn(delay: 300.ms),
        elevation: 0,
        backgroundColor: Theme.of(context).colorScheme.surface,
        actions: [
          IconButton(
            icon: const Icon(Icons.tune),
            onPressed: _showFilterSortBottomSheet,
            tooltip: '筛选和排序',
          ).animate().scale(delay: 500.ms),
          IconButton(
            icon: const Icon(Icons.person_outline),
            onPressed: () {
              Navigator.pushNamed(context, '/my_page');
            },
            tooltip: '个人资料',
          ).animate().scale(delay: 600.ms),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: AppConfig.useMockData 
              ? _buildMockDataView()
              : _buildFirestoreView(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.pushNamed(context, '/create_activity');
        },
        icon: const Icon(Icons.add),
        label: const Text('发布活动'),
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.onPrimary,
      ).animate()
       .scale(delay: 800.ms, duration: 600.ms)
       .then()
       .shimmer(delay: 2000.ms, duration: 1000.ms),
    );
  }

  Widget _buildMockDataView() {
    AppConfig.log('Using mock data for activities');
    final activities = _getFilteredMockData();
    
    if (activities.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.event_busy, size: 64, color: Colors.grey),
            SizedBox(height: 16),
            Text('暂无活动', style: TextStyle(fontSize: 18, color: Colors.grey)),
            SizedBox(height: 8),
            Text('尝试调整筛选条件', style: TextStyle(color: Colors.grey)),
          ],
        ),
      );
    }

    return RefreshIndicator(
      onRefresh: () async {
        await MockDataService.simulateDelay();
        setState(() {});
      },
      child: AnimationLimiter(
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 8),
          itemCount: activities.length,
          itemBuilder: (context, index) {
            final activityData = activities[index];
            final activityId = activityData['id'];
            final organizerData = MockDataService.getMockUser(activityData['organizerId']);

            return AnimationConfiguration.staggeredList(
              position: index,
              duration: const Duration(milliseconds: 600),
              child: SlideAnimation(
                verticalOffset: 50.0,
                child: FadeInAnimation(
                  child: AnimatedActivityCard(
                    title: activityData['title'] ?? '无标题',
                    time: _formatActivityTime(activityData),
                    location: activityData['location'] ?? '未知地点',
                    imageUrl: activityData['coverImageUrl'] ?? '',
                    organizerName: organizerData['displayName'] ?? '未知组织者',
                    currentParticipants: activityData['currentParticipantsCount'] ?? 0,
                    maxParticipants: activityData['maxParticipants'] ?? 0,
                    index: index,
                    onTap: () {
                      Navigator.pushNamed(
                        context,
                        '/activity_detail',
                        arguments: activityId,
                      );
                    },
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildFirestoreView() {
    final query = _buildQuery();
    if (query == null) return Container();

    return StreamBuilder<QuerySnapshot>(
      stream: query.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text('错误: ${snapshot.error}'));
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child: CircularProgressIndicator());
        }

        if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
          return const Center(child: Text('暂无活动'));
        }

        return RefreshIndicator(
          onRefresh: () async {
            setState(() {});
          },
          child: AnimationLimiter(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 8),
              itemCount: snapshot.data!.docs.length,
              itemBuilder: (context, index) {
                final doc = snapshot.data!.docs[index];
                final activityData = doc.data() as Map<String, dynamic>;
                final activityId = doc.id;

                return AnimationConfiguration.staggeredList(
                  position: index,
                  duration: const Duration(milliseconds: 600),
                  child: SlideAnimation(
                    verticalOffset: 50.0,
                    child: FadeInAnimation(
                      child: AnimatedActivityCard(
                        title: activityData['title'] ?? '无标题',
                        time: _formatActivityTime(activityData),
                        location: activityData['location'] ?? '未知地点',
                        imageUrl: activityData['coverImageUrl'] ?? '',
                        organizerName: '加载中...', // Will be loaded async
                        currentParticipants: activityData['currentParticipantsCount'] ?? 0,
                        maxParticipants: activityData['maxParticipants'] ?? 0,
                        index: index,
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/activity_detail',
                            arguments: activityId,
                          );
                        },
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        );
      },
    );
  }
}