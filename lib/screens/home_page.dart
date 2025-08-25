import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';

import '../widgets/activity_list_item_widget.dart'; // Import the new widget
import '../widgets/activity_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final List<String> _selectedActivityTypes = []; // To store selected activity types
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
                        // When filter changes, reset pagination and fetch first page
                        _activities.clear();
                        _lastDocument = null;
                      });
                      _fetchFirstPage(); // Re-fetch with new filters
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
                          // When sort changes, reset pagination and fetch first page
                          _activities.clear();
                          _lastDocument = null;
                        });
                        _fetchFirstPage(); // Re-fetch with new sort
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
                          // When sort changes, reset pagination and fetch first page
                          _activities.clear();
                          _lastDocument = null;
                        });
                        _fetchFirstPage(); // Re-fetch with new sort
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16.0),
              // Close button
              Center(
                child: ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: const Text('确定'),
                ),
              ),
              const SizedBox(height: 8.0), // Add some space at the bottom
              Center(
                child: TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('取消')),
              )
            ],
          ),
        );
      },
    );
  }

  final _scrollController = ScrollController();
  final int _pageSize = 10; // Define your page size
  List<DocumentSnapshot> _activities = []; // To store fetched documents
  bool _isLoadingInitial = true; // Track initial fetch
  bool _isFetchingMore = false; // Track fetching more data for pagination
  DocumentSnapshot? _lastDocument; // To store the last document of the previous page
  StreamSubscription? _activitySubscription;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchFirstPage(); // Fetch the first page on init
  }

  // Method to refresh activities (for Pull-to-Refresh)
  Future<void> _refreshActivities() async {
    // Cancel any ongoing subscription
    _activitySubscription?.cancel();
    // Reset state for a new fetch
    setState(() {
      _activities.clear();
      _lastDocument = null;
      _isLoadingInitial = true; // Set to true as we are starting a new initial fetch
    });
    // Fetch the first page again
    _fetchFirstPage();
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _activitySubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

  // Listener for scroll events to implement infinite scrolling
  void _onScroll() {
    // Check if the user is at the bottom of the list and not already fetching more
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent &&
        !_isFetchingMore &&
        _lastDocument != null) { // Only fetch more if there might be more data
      _fetchMoreActivities();
    }
  }

  Future<void> _fetchFirstPage() async {
     _activitySubscription?.cancel(); // Cancel previous subscription

    Query query = FirebaseFirestore.instance.collection('activities');

    // Apply filtering based on selected activity types
    if (_selectedActivityTypes.isNotEmpty) {
      query = query.where('type', whereIn: _selectedActivityTypes);
    }

    // Apply sorting
    if (_selectedSortOption == 'dateDescending') {
      query = query.orderBy('startTime', descending: true);
    } else if (_selectedSortOption == 'dateAscending') {
      query = query.orderBy('startTime', descending: false);
    } else {
       // Default sorting if no specific option is selected
       query = query.orderBy('startTime', descending: true);
    }

    query = query.limit(_pageSize);

    try {
       setState(() {
         _isLoadingInitial = true; // Show loading indicator
       });

        final querySnapshot = await query.get(); // Use .get() for the first fetch

        if (mounted) {
            setState(() {
                _activities = querySnapshot.docs;
                if (querySnapshot.docs.isNotEmpty) {
                    _lastDocument = querySnapshot.docs.last;
                } else {
                    _lastDocument = null;
                }
               _isLoadingInitial = false; // Hide loading indicator
            });
        }

         // Re-subscribe to real-time updates for the current query
         _activitySubscription = query.snapshots().listen((snapshot) {
            if (mounted) {
                setState(() {
                    _activities = snapshot.docs;
                    if (snapshot.docs.isNotEmpty) {
                        _lastDocument = snapshot.docs.last;
                    } else {
                         _lastDocument = null;
                    }
 });
             }
         }, onError: (error) {
            print('Error fetching initial activities: $error');
             if (mounted) {
               ScaffoldMessenger.of(context).showSnackBar(
                 SnackBar(content: Text('Error fetching activities: ${error.toString()}')),
               );
                setState(() {
                   _isLoadingInitial = false;
                });
             }
         });

    } catch (e) {
       print('Error fetching initial activities: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching activities: ${e.toString()}')),
          );
          setState(() {
                _isLoadingInitial = false;
           });
        }
    }
  }


  Future<void> _fetchMoreActivities() async {
    if (_isFetchingMore || _lastDocument == null) return;

    setState(() {
      _isFetchingMore = true;
    });

    Query query = FirebaseFirestore.instance.collection('activities');

    // Apply filtering
    if (_selectedActivityTypes.isNotEmpty) {
      query = query.where('type', whereIn: _selectedActivityTypes);
    }

    // Apply sorting
    if (_selectedSortOption == 'dateDescending') {
      query = query.orderBy('startTime', descending: true);
    } else if (_selectedSortOption == 'dateAscending') {
      query = query.orderBy('startTime', descending: false);
    } else {
      // Default sorting if no specific option is selected
      query = query.orderBy('startTime', descending: true);
    }

    query = query.startAfterDocument(_lastDocument!) // Start after the last document
        .limit(_pageSize);

    try {
      final querySnapshot = await query.get();

      if (mounted) {
         setState(() {
            _activities.addAll(querySnapshot.docs);
 if (querySnapshot.docs.isNotEmpty) {
              _lastDocument = querySnapshot.docs.last;
            } else {
              _lastDocument = null; // No more data
            }
            _isFetchingMore = false;
         });
      }
    } catch (e) {
       // Handle errors during fetching more activities
        print('Error fetching more activities: $e');
       if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Error fetching more activities: ${e.toString()}')),
          );
         setState(() {
           _isFetchingMore = false;
         });
       }
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar( // App bar for the home page
        title: const Text('活动列表'), // Title of the app bar
        actions: [
          // Add new activity button
          IconButton(
            icon: const Icon(Icons.add),
            // Navigate to the create activity screen when pressed
            // The route name '/create_activity' is defined in main.dart
            // This allows the user to publish a new activity

            onPressed: () {
              Navigator.pushNamed(context, '/create_activity');
            },
            tooltip: '发布新活动',
          ),
          // Filter/Sort Icon
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: _showFilterSortBottomSheet,
            tooltip: '筛选和排序',
          ),
          // Logout button
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              // Sign out the current user from Firebase Authentication
              await FirebaseAuth.instance.signOut();
            },
            tooltip: '退出登录',
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _refreshActivities,
        child: _isLoadingInitial
            // Show initial loading indicator
            ? const Center(child: CircularProgressIndicator())
            : _activities.isEmpty
                ? const Center(child: Text('暂无活动'))
                : ListView.builder(
                    controller: _scrollController,
                    itemCount: _activities.length + (_isFetchingMore ? 1 : 0), // Add 1 for loading indicator
                    itemBuilder: (context, index) {
                      if (index == _activities.length) {
                        return const Padding(
                          padding: EdgeInsets.all(8.0),
                          child: Center(child: CircularProgressIndicator()),
                        ); // Loading indicator at the bottom
                      }

                      var activity = _activities[index].data() as Map<String, dynamic>;
                      var activityId = _activities[index].id; // Get the document ID
                      // Use try-catch or null checks for safety when accessing data
                      var startTime = activity['startTime'] as Timestamp?;
                      var endTime = activity['endTime'] as Timestamp?;
                      DateTime? activityStartTime = startTime?.toDate();
                      DateTime? activityEndTime = endTime?.toDate();

                      // Fetch organizer name
                      // Using FutureBuilder for asynchronous data fetching for each card
                      return FutureBuilder<DocumentSnapshot>(
                          future: FirebaseFirestore.instance.collection('users').doc(activity['organizerId']).get(),
                          builder: (context, userSnapshot) {
                            String organizerName = '加载中...'; // Default while loading
                            if (userSnapshot.connectionState == ConnectionState.done) {
                               if (userSnapshot.hasData && userSnapshot.data!.exists) {
                                 final userData = userSnapshot.data!.data() as Map<String, dynamic>?;
                                 organizerName = userData?['displayName'] ?? '未知组织者';
                               } else {
                                 organizerName = '未知组织者'; // Organizer not found
                               }
                             } else {
                                // Still loading
                              }

                              // Format the date and time
                              String formattedTime = '时间未知'; // Default value
                              if (activityStartTime != null) {
                                 final startDateFormatted = DateFormat('yyyy-MM-dd').format(activityStartTime.toLocal());
                                 final startTimeFormatted = DateFormat('HH:mm').format(activityStartTime.toLocal());
                                 formattedTime = '$startDateFormatted $startTimeFormatted';

                                 if (activityEndTime != null) {
                                    final endDateFormatted = DateFormat('yyyy-MM-dd').format(activityEndTime.toLocal());
                                    final endTimeFormatted = DateFormat('HH:mm').format(activityEndTime.toLocal());

                                    if (startDateFormatted == endDateFormatted) {
                                       formattedTime += ' - $endTimeFormatted';
                                    } else {
                                       formattedTime += ' - $endDateFormatted $endTimeFormatted';
                                    }
                                 }
                              }


                              return InkWell(
                                onTap: () {
                                  Navigator.pushNamed(
                                    context,
                                    '/activity_detail',
                                    arguments: activityId, // Pass the activity ID as an argument
                                  );
                                },
                                child: ActivityCardWidget(
                                  // Provide default values in case of null
                                  title: activity['title'] ?? '无标题活动',
                                  time: formattedTime, // Use formatted time
                                  location: activity['location'] ?? '未知地点',
                                  imageUrl: activity['coverImageUrl'] ?? '',
                                  organizerName: organizerName, // Use fetched organizer name
                                  currentParticipants: activity['currentParticipantsCount'] ?? 0,
                                  maxParticipants: activity['maxParticipants'] ?? 0,
                                ),
                              );
                             }
                           );
                         }
                       );
                     }).toList(),
                   );
                 } else {
                   return const Center(child: Text('暂无活动'));
                 }
               } else {
                 return const Center(child: CircularProgressIndicator());
               }
             },
           ),
         ),
       ],
     ),
   );
 }
}