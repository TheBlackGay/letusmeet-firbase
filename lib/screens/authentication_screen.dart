import 'package:flutter/material.dart';

class AuthenticationScreen extends StatefulWidget {
  const AuthenticationScreen({super.key});

  @override
  State<AuthenticationScreen> createState() => _AuthenticationScreenState();
}

class _AuthenticationScreenState extends State<AuthenticationScreen> {
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
    return Scaffold(
      appBar: AppBar(
        title: const Text('实名认证'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView( // Use ListView for potential scrolling on smaller screens
          children: <Widget>[
            const Text(
              '请填写您的真实身份信息以完成实名认证。',
              style: TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: const InputDecoration(
                labelText: '姓名',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: _idNumberController,
              decoration: const InputDecoration(
                labelText: '身份证号码',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.number,
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Placeholder for selecting and uploading front ID photo
                print('Upload Front ID Photo');
              },
              child: const Text('上传身份证正面照片 (占位符)'),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Placeholder for selecting and uploading back ID photo
                print('Upload Back ID Photo');
              },
              child: const Text('上传身份证反面照片 (占位符)'),
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
      ),
    );
  }
}