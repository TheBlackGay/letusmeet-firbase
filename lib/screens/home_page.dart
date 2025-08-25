import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/activity_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Method to refresh activities
  Future<void> _refreshActivities() async {
    Completer<void> completer = Completer<void>();
    // This will automatically trigger a rebuild of the StreamBuilder
    // when the data changes in Firestore. For simple pull-to-refresh
    // in a StreamBuilder, you don't need to explicitly re-fetch data
    // unless your stream logic is more complex (e.g., fetching a limited set).
    // Completing the completer will signal the RefreshIndicator to stop.
    completer.complete();
    return completer.future;
  }

  // State variables for filtering and sorting
  List<String> _selectedActivityTypes = []; // To store selected activity types
  String _selectedSortOption = 'dateDescending'; // Default sort option: date descending
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
              // Checkboxes for activity types
              Wrap(
                spacing: 8.0,
                children: ['聚餐', '运动', '桌游', '其他'].map((type) {
                  return FilterChip(
                    label: Text(type),
                    selected: _selectedActivityTypes.contains(type),
                    onSelected: (selected) {
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
                '按日期排序',
                style: Theme.of(context).textTheme.titleMedium,
              ),
              // Radio buttons for sorting options
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  RadioListTile<String>(
                    title: const Text('按日期降序'),
                    value: 'dateDescending',
                    groupValue: _selectedSortOption,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSortOption = value;
                        });
                      }
                    },
                  ),
                  RadioListTile<String>(
                    title: const Text('按日期升序'),
                    value: 'dateAscending',
                    groupValue: _selectedSortOption,
                    onChanged: (value) {
                      if (value != null) {
                        setState(() {
                          _selectedSortOption = value;
                        });
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Close button
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('活动列表'),
        actions: [
          // Placeholder for adding new activity button
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              Navigator.pushNamed(context, '/create_activity');
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
            },
            tooltip: 'Logout',
          ),
          // Filter/Sort Icon
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSortBottomSheet, // Call the method to show the bottom sheet
          ),
        ],
      ),
      body: Column(
        children: [
          // Placeholder for filtering/sorting UI elements
          // We might remove this later if using a bottom sheet for options
          Container(
            padding: const EdgeInsets.all(8.0),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                Text('筛选占位符'),
                Text('排序占位符'),
              ],
            ),
          ),
          Expanded(
            // Placeholder for the activity list
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('activities')
                  .where('type', whereIn: _selectedActivityTypes.isNotEmpty ? _selectedActivityTypes : null) // Apply filter if types are selected
                  .orderBy('date', descending: _selectedSortOption == 'dateDescending') // Apply sorting by date
                  .snapshots(),
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(child: Text('Error: ${snapshot.error}'));
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No activities found.'));
                }

                // Display the list of activities
                return RefreshIndicator(
                  onRefresh: _refreshActivities,
                  child: ListView.builder(
                    itemCount: snapshot.data!.docs.length,
                    itemBuilder: (context, index) {
                      var activity = snapshot.data!.docs[index].data() as Map<String, dynamic>;
                      var activityId = snapshot.data!.docs[index].id; // Get the document ID
                      return InkWell( // Use InkWell for tap effect
                        onTap: () {
                          Navigator.pushNamed(
                            context,
                            '/activity_detail',
                            arguments: activityId, // Pass the activity ID as an argument
                          );
                        },
                        child: Card(
                          margin: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: ActivityCardWidget(
                            title: activity['title'] ?? '无标题活动',
                            time: activity['time'] ?? '未知时间', // Placeholder
                            location: activity['location'] ?? '未知地点', // Placeholder
                            imageUrl: activity['imageUrl'] ?? '', // Pass imageUrl
                            organizerName: activity['organizerName'] ?? '未知组织者', // Pass organizerName
                            currentParticipants: activity['currentParticipants'] ?? 0, // Pass attendee count
                            maxParticipants: activity['maxParticipants'] ?? 0, // Pass max participants
                          ),
                        ),
                      );
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
