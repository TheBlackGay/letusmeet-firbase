import 'package:cloud_firestore/cloud_firestore.dart';

class MockDataService {
  static List<Map<String, dynamic>> getMockActivities() {
    return [
      {
        'id': 'mock_1',
        'title': '周末户外徒步',
        'description': '一起去爬山，享受大自然的美好！适合所有健身水平的朋友。',
        'location': '香山公园',
        'activityType': '户外运动',
        'maxParticipants': 15,
        'currentParticipantsCount': 8,
        'cost': 0.0,
        'startTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2))),
        'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 2, hours: 4))),
        'organizerId': 'mock_organizer_1',
        'coverImageUrl': 'https://images.unsplash.com/photo-1551632811-561732d1e306?w=800',
        'status': 'active',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
      },
      {
        'id': 'mock_2',
        'title': '咖啡品鉴聚会',
        'description': '专业咖啡师带你品尝世界各地的精品咖啡，学习咖啡文化。',
        'location': '星巴克臻选店',
        'activityType': '聚餐聚会',
        'maxParticipants': 10,
        'currentParticipantsCount': 6,
        'cost': 88.0,
        'startTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5))),
        'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 5, hours: 2))),
        'organizerId': 'mock_organizer_2',
        'coverImageUrl': 'https://images.unsplash.com/photo-1495474472287-4d71bcdd2085?w=800',
        'status': 'active',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 12))),
      },
      {
        'id': 'mock_3',
        'title': '摄影技巧分享',
        'description': '摄影爱好者聚会，分享拍摄技巧，一起外拍练习。',
        'location': '798艺术区',
        'activityType': '文化艺术',
        'maxParticipants': 12,
        'currentParticipantsCount': 9,
        'cost': 50.0,
        'startTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7))),
        'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 7, hours: 3))),
        'organizerId': 'mock_organizer_3',
        'coverImageUrl': 'https://images.unsplash.com/photo-1502920917128-1aa500764cbd?w=800',
        'status': 'active',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 6))),
      },
      {
        'id': 'mock_4',
        'title': 'Flutter开发交流',
        'description': '移动开发者聚会，讨论Flutter最新技术和最佳实践。',
        'location': '中关村创业大街',
        'activityType': '学习交流',
        'maxParticipants': 20,
        'currentParticipantsCount': 15,
        'cost': 0.0,
        'startTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 10))),
        'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 10, hours: 4))),
        'organizerId': 'mock_organizer_4',
        'coverImageUrl': 'https://images.unsplash.com/photo-1517077304055-6e89abbf09b0?w=800',
        'status': 'active',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(hours: 3))),
      },
      {
        'id': 'mock_5',
        'title': '古镇一日游',
        'description': '周边古镇游览，体验传统文化，品尝当地美食。',
        'location': '周庄古镇',
        'activityType': '旅游出行',
        'maxParticipants': 25,
        'currentParticipantsCount': 18,
        'cost': 150.0,
        'startTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 14))),
        'endTime': Timestamp.fromDate(DateTime.now().add(const Duration(days: 14, hours: 8))),
        'organizerId': 'mock_organizer_5',
        'coverImageUrl': 'https://images.unsplash.com/photo-1564013799919-ab600027ffc6?w=800',
        'status': 'active',
        'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(minutes: 30))),
      },
    ];
  }

  static Map<String, dynamic> getMockUser(String userId) {
    final users = {
      'mock_organizer_1': {
        'uid': 'mock_organizer_1',
        'email': 'hiker@example.com',
        'displayName': '户外达人小李',
        'nickname': '小李',
        'level': '高级用户',
        'auth_status': '已认证',
        'avatarUrl': 'https://images.unsplash.com/photo-1507003211169-0a1dd7228f2d?w=150',
      },
      'mock_organizer_2': {
        'uid': 'mock_organizer_2',
        'email': 'coffee@example.com',
        'displayName': '咖啡师小王',
        'nickname': '小王',
        'level': '专业用户',
        'auth_status': '已认证',
        'avatarUrl': 'https://images.unsplash.com/photo-1494790108755-2616b612b786?w=150',
      },
      'mock_organizer_3': {
        'uid': 'mock_organizer_3',
        'email': 'photographer@example.com',
        'displayName': '摄影师小张',
        'nickname': '小张',
        'level': '高级用户',
        'auth_status': '已认证',
        'avatarUrl': 'https://images.unsplash.com/photo-1472099645785-5658abf4ff4e?w=150',
      },
      'mock_organizer_4': {
        'uid': 'mock_organizer_4',
        'email': 'developer@example.com',
        'displayName': '程序员小刘',
        'nickname': '小刘',
        'level': '专业用户',
        'auth_status': '已认证',
        'avatarUrl': 'https://images.unsplash.com/photo-1519085360753-af0119f7cbe7?w=150',
      },
      'mock_organizer_5': {
        'uid': 'mock_organizer_5',
        'email': 'traveler@example.com',
        'displayName': '旅行家小陈',
        'nickname': '小陈',
        'level': '高级用户',
        'auth_status': '已认证',
        'avatarUrl': 'https://images.unsplash.com/photo-1438761681033-6461ffad8d80?w=150',
      },
    };
    
    return users[userId] ?? {
      'uid': userId,
      'email': 'user@example.com',
      'displayName': '用户',
      'nickname': '用户',
      'level': '基础用户',
      'auth_status': '未认证',
      'avatarUrl': '',
    };
  }

  static Future<void> simulateDelay() async {
    // Simulate network delay
    await Future.delayed(Duration(milliseconds: 300 + (DateTime.now().millisecond % 700)));
  }
}