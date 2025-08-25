import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class HomePage extends StatefulWidget {
  const HomePage({Key? key}) : super(key: key);
  final List<String> activities = List.generate(10, (index) => '活动 ${index + 1}');

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
          // Placeholder for filtering/sorting
          IconButton(
            icon: const Icon(Icons.filter_list),
            onPressed: () {
              // TODO: Implement filtering/sorting logic
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Placeholder for filtering/sorting UI elements
          Container(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: const [
                Text('筛选占位符'),
                Text('排序占位符'),
              ],
            ),
          ),
          Expanded(
            // Placeholder for the activity list
            child: StreamBuilder<QuerySnapshot>(
              stream: FirebaseFirestore.instance.collection('activities').snapshots(),
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
                return ListView.builder(
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
                        child: ListTile(
                          title: Text(activity['title'] ?? '无标题活动'), // Display activity title
                          subtitle: Text(activity['description'] ?? '无描述'), // Display activity description
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}