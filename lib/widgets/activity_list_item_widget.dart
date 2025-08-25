import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart'; // Import for date formatting

import 'package:myapp/widgets/activity_card_widget.dart';

class ActivityListItemWidget extends StatelessWidget {
  final String activityId;
  final Map<String, dynamic> activityData;

  const ActivityListItemWidget({
    super.key,
    required this.activityId,
    required this.activityData,
  });

  @override
  Widget build(BuildContext context) {
    // Use try-catch or null checks for safety when accessing data
    var startTime = activityData['startTime'] as Timestamp?;
    var endTime = activityData['endTime'] as Timestamp?;
    DateTime? activityStartTime = startTime?.toDate();
    DateTime? activityEndTime = endTime?.toDate();

    // Fetch organizer name
    // Using FutureBuilder for asynchronous data fetching for each card
    return FutureBuilder<DocumentSnapshot>(
      future: FirebaseFirestore.instance
          .collection('users')
          .doc(activityData['organizerId'])
          .get(),
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
          final startDateFormatted =
              DateFormat('yyyy-MM-dd').format(activityStartTime.toLocal());
          final startTimeFormatted =
              DateFormat('HH:mm').format(activityStartTime.toLocal());
          formattedTime = '$startDateFormatted $startTimeFormatted';

          if (activityEndTime != null) {
            final endDateFormatted =
                DateFormat('yyyy-MM-dd').format(activityEndTime.toLocal());
            final endTimeFormatted =
                DateFormat('HH:mm').format(activityEndTime.toLocal());

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
            title: activityData['title'] ?? '无标题活动',
            time: formattedTime, // Use formatted time
            location: activityData['location'] ?? '未知地点',
            imageUrl: activityData['coverImageUrl'] ?? '',
            organizerName: organizerName, // Use fetched organizer name
            currentParticipants: activityData['currentParticipantsCount'] ?? 0,
            maxParticipants: activityData['maxParticipants'] ?? 0,
          ),
        );
      },
    );
  }
}