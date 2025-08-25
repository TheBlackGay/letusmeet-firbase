import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/activity_card_widget.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  _HomePageState createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  // Method to refresh activities
  Future<void> _refreshActivities() async {
    // When using pagination, a pull-to-refresh should ideally refetch the first page
    // and clear the existing data.
    setState(() {
      _activities.clear();
      _lastDocument = null;
    });
    await _fetchFirstPage();
  }
  // State variables for filtering and sorting
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
                    // Trigger fetching the first page with new filters/sort
                    // This is already handled in the setState callbacks of the filters/sort options.
                    // We can just close the bottom sheet here.
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
  bool _isFetchingMore = false;
  DocumentSnapshot? _lastDocument; // To store the last document of the previous page
  StreamSubscription? _activitySubscription;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_onScroll);
    _fetchFirstPage(); // Fetch the first page on init
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _activitySubscription?.cancel(); // Cancel the subscription
    super.dispose();
  }

  void _onScroll() {
    if (_scrollController.position.pixels == _scrollController.position.maxScrollExtent && !_isFetchingMore) {
      // User has scrolled to the bottom and we are not already fetching
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

    _activitySubscription = query.snapshots().listen((querySnapshot) {
        setState(() {
            _activities = querySnapshot.docs;
            if (querySnapshot.docs.isNotEmpty) {
                _lastDocument = querySnapshot.docs.last;
            } else {
                _lastDocument = null;
            }
        });
    });
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
          // We are using a bottom sheet for options, so this can be removed or used for displaying current filters

          Expanded(
            // Placeholder for the activity list
            child: _activities.isEmpty && _lastDocument == null && !_isFetchingMore
                ? const Center(child: CircularProgressIndicator()) // Show loading on initial fetch
                : _activities.isEmpty && _lastDocument == null && _isFetchingMore
                  ? const Center(child: Text('No activities found.')) // Show message if no activities after initial fetch
                  : RefreshIndicator(
                  onRefresh: _refreshActivities,
                  child: ListView.builder(
                    controller: _scrollController, // Attach scroll controller
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
                      DateTime? activityTime = startTime?.toDate();

                      return InkWell( // Use InkWell for tap effect
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
                          time: '${activityTime.toLocal()}', // Format time nicely
                          location: activity['location'] ?? '未知地点',
                          imageUrl: activity['coverImageUrl'] ?? '', // Use coverImageUrl from PRD
                          organizerName: '未知组织者', // Placeholder - need to fetch organizer name
                          currentParticipants: activity['currentParticipantsCount'] ?? 0, // Use currentParticipantsCount from PRD
                          maxParticipants: activity['maxParticipants'] ?? 0, // Use maxParticipants from PRD
                        ),
                      );
                    },
                  ),
                ),
          ),
           // Show initial loading outside the list if _activities is empty
           if (_activities.isEmpty && _lastDocument == null && !_isFetchingMore)
              const Center(child: CircularProgressIndicator()),
           // Show "No activities found" message if _activities is empty and not fetching more
           if (_activities.isEmpty && !_isFetchingMore && _lastDocument != null) // Check if initial fetch is done but no activities
              const Center(child: Text('No activities found.')),
        ],
      ),
    );
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

      setState(() {
        _activities.addAll(querySnapshot.docs);
        if (querySnapshot.docs.isNotEmpty) {
          _lastDocument = querySnapshot.docs.last;
        } else {
          _lastDocument = null; // No more data
        }
        _isFetchingMore = false;
      });
    } catch (e) {
       // Handle errors during fetching more activities
       ScaffoldMessenger.of(context).showSnackBar(
         SnackBar(content: Text('Error fetching more activities: ${e.toString()}')),
       );
      setState(() {
        _isFetchingMore = false;
      });
    }
  }
}


                  return Center(child = CircularProgressIndicator());
                }

                if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                  return const Center(child: Text('No activities found.'));
                }

                // Display the list of activities
                return RefreshIndicator(
                  onRefresh = _refreshActivities,
                  child = ListView.builder(
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
