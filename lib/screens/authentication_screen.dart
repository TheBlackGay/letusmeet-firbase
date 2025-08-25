import 'package:flutter/material.dart';
import 'package:myapp/screens/login_screen.dart';
import 'package:myapp/screens/registration_screen.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
  // State variable to toggle between login/registration and real name verification
  bool _showRealNameVerification = false;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  final String _authenticationStatus = '等待提交认证信息';

  @override
  void dispose() {
    _nameController.dispose();
    _idNumberController.dispose();
 super.dispose();
  }

  // State variable to toggle between login and registration
  bool _isLogin = true;

  Widget _buildAuthenticationForm() {
    return SingleChildScrollView(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                isLogin ? const LoginScreen() : const RegistrationScreen(),
                TextButton(
                  onPressed: () {
                    _isLogin.value = !isLogin; // Toggle between login and registration
                    setState(() {
 _isLogin = !_isLogin;
                    });
                  },
                  child: Text(isLogin ? '没有账号？注册' : '已有账号？登录'),
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () {
                    setState(() {
                      _showRealNameVerification = true;
                    });
                  },
                  child: const Text('前往实名认证'),
                ),
 SizedBox(height: 20), // Add space between buttons
              ],
            ),
 );
  }

  @override
  Widget build(BuildContext context) {
 return Scaffold(
      appBar: AppBar(
        title: Text(_showRealNameVerification ? '实名认证' : '认证'),
      ),
      body: _showRealNameVerification
          ? RealNameVerificationScreen()
          : _buildAuthenticationForm(),
 );
  }
}

class RealNameVerificationScreen extends StatefulWidget {
  const RealNameVerificationScreen({super.key});

  @override
  State<RealNameVerificationScreen> createState() => _RealNameVerificationScreenState();
}

class _RealNameVerificationScreenState extends State<RealNameVerificationScreen> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _idNumberController = TextEditingController();
  String _authenticationStatus = '等待提交认证信息';

  @override
  void dispose() {
    _nameController.dispose();
    _idNumberController.dispose();
    super.dispose();
  }

  void _submitAuthentication() {
    // Placeholder for authentication submission logic
    setState(() {
      _authenticationStatus = '认证信息已提交，等待审核...';
    });
    // In a real application, you would call an API here
    // and update the status based on the response.
    print('Name: ${_nameController.text}');
    print('ID Number: ${_idNumberController.text}');
  }

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          TextFormField(
            controller: _nameController,
            decoration: const InputDecoration(labelText: '姓名'),
          ),
          const SizedBox(height: 16.0),
          TextFormField(
            controller: _idNumberController,
            decoration: const InputDecoration(labelText: '身份证号'),
            keyboardType: TextInputType.text, // Use text for potential X in ID number
          ),
          const SizedBox(height: 20),
          ElevatedButton(
            onPressed: _submitAuthentication,
            child: const Text('提交认证信息'),
          ),
          const SizedBox(height: 20),
          Center(
            child: Text(
              '认证状态: $_authenticationStatus',
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }
}
