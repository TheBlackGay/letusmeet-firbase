// Mock authentication service for testing without Firebase
class MockAuthService {
  static final Map<String, String> _users = {};
  static String? _currentUserEmail;

  static bool get isLoggedIn => _currentUserEmail != null;
  static String? get currentUserEmail => _currentUserEmail;

  static Future<bool> register(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    if (_users.containsKey(email)) {
      throw Exception('该邮箱已被注册');
    }
    
    _users[email] = password;
    _currentUserEmail = email;
    return true;
  }

  static Future<bool> login(String email, String password) async {
    await Future.delayed(const Duration(seconds: 1)); // Simulate network delay
    
    if (!_users.containsKey(email)) {
      throw Exception('用户不存在');
    }
    
    if (_users[email] != password) {
      throw Exception('密码错误');
    }
    
    _currentUserEmail = email;
    return true;
  }

  static void logout() {
    _currentUserEmail = null;
  }
}