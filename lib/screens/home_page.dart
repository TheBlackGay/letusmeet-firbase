import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/activity_list_item_widget.dart';

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
      builder: (BuildContext context) {
        return Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                '筛选和排序',
                style: Theme.of(context).textTheme.titleLarge,
              ),
              const SizedBox(height: 16.0),
              Text(
                '按类型筛选',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              // Activity type filters
              Wrap(
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
              const SizedBox(height: 16.0),
              Text(
                '排序方式',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              // Sort options
              Column(
                children: [
                  RadioListTile<String>(
                    title: const Text('按时间降序'),
                    value: 'dateDescending',
                    groupValue: _selectedSortOption,
                    onChanged: (String? value) {
                      setState(() {
                        _selectedSortOption = value!;
                      });
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('按时间升序'),
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
              const SizedBox(height: 16.0),
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

  Query<Map<String, dynamic>> _buildQuery() {
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance.collection('activities');

    // Apply filters
    if (_selectedActivityTypes.isNotEmpty) {
      query = query.where('activityType', whereIn: _selectedActivityTypes);
    }

    // Apply sorting
    if (_selectedSortOption == 'dateDescending') {
      query = query.orderBy('startTime', descending: true);
    } else if (_selectedSortOption == 'dateAscending') {
      query = query.orderBy('startTime', descending: false);
    }

    return query;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('轻约'),
        actions: [
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSortBottomSheet,
          ),
          IconButton(
            icon: const Icon(Icons.person),
            onPressed: () {
              Navigator.pushNamed(context, '/my_page');
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _buildQuery().snapshots(),
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
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      final doc = snapshot.data!.docs[index];
                      final activityData = doc.data() as Map<String, dynamic>;
                      final activityId = doc.id;

                      return ActivityListItemWidget(
                        activityId: activityId,
                        activityData: activityData,
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.pushNamed(context, '/create_activity');
        },
        child: const Icon(Icons.add),
      ),
    );
  }
}