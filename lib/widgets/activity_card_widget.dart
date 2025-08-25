import 'package:flutter/material.dart';

class ActivityCardWidget extends StatelessWidget {
  const ActivityCardWidget({Key? key}) : super(key: key);
  final String title;
  final String time;
  final String location;
  final String imageUrl;
  final String organizerName;
  final int currentParticipants;
  final int maxParticipants;

  const ActivityCardWidget({
    Key? key,
    required this.title,
    required this.time,
    required this.location,
    required this.imageUrl,
    required this.organizerName,
    required this.currentParticipants,
    required this.maxParticipants,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      elevation: 2.0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Placeholder for Activity Image
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                imageUrl,
                height: 150.0,
                width: double.infinity,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  height: 150.0,
                  color: Colors.grey[300],
                  child: Icon(Icons.image_not_supported, color: Colors.grey[600]),
                ),
              ),
            ),
            const SizedBox(height: 8.0),
            // Activity Title
            Text(
              title,
              style: Theme.of(context).textTheme.titleLarge?.copyWith(fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 4.0),
            // Activity Time
            Text(
              '时间: $time',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 4.0),
            // Activity Location
            Text(
              '地点: $location',
              style: Theme.of(context).textTheme.bodyMedium,
            ),
            const SizedBox(height: 8.0),
            // Placeholder for other details like organizer, participants, tags, etc.
            Row(
              children: <Widget>[
                Text(
                  '组织者: $organizerName',
                  style: Theme.of(context).textTheme.bodySmall,
                ),
                const Spacer(), // Pushes the participant count to the right
                Text(
                  '已报名: $currentParticipants / $maxParticipants',
                  style: Theme.of(context).textTheme.bodySmall,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Theme.of(context).primaryColor),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}