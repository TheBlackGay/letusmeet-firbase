import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:email_validator/email_validator.dart'; // Import the email_validator package

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }
  
  Future<void> _login() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      try {
        await FirebaseAuth.instance.signInWithEmailAndPassword(
          email: _emailController.text.trim(),
          password: _passwordController.text.trim(),
        );
        // Login successful, navigate to home page
        Navigator.of(context).pushReplacementNamed('/'); // Use your home page route name
      } on FirebaseAuthException catch (e) {
        String message;
        if (e.code == 'user-not-found') {
          message = '未找到该用户。';
        } else if (e.code == 'wrong-password') {
          message = '密码错误。';
        } else {
          message = '登录失败：${e.message}';
        }
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(message)),
        );
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('发生错误：$e')),
        );
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('账号登录'),
      ),
      body: Form(
        key: _formKey,
        child: Center(
          child: SingleChildScrollView( // Use SingleChildScrollView to prevent overflow
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: <Widget>[
                const Text(
                  '欢迎来到轻约',
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 40),
                TextFormField(
                  controller: _emailController,
                  decoration: const InputDecoration(labelText: '邮箱'),
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入邮箱';
                    }
                    if (!EmailValidator.validate(value)) {
                      return '请输入有效的邮箱地址';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 12),
                TextFormField(
                  controller: _passwordController,
                  decoration: const InputDecoration(labelText: '密码'),
                  obscureText: true,
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 6) {
                      return '密码至少需要6个字符';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 24),
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : ElevatedButton(
                        onPressed: _login,
                        child: const Text('登录'),
                      ),
                const SizedBox(height: 16),
                TextButton(
                  onPressed: () {
                    Navigator.pushNamed(context, '/registration');
                  },
                  child: const Text('还没有账号？立即注册'),
                ),
              ],
            children: <Widget>[
 Text(
 '欢迎来到轻约',
 textAlign: TextAlign.center,
 style: TextStyle(
 fontSize: 24,
 fontWeight: FontWeight.bold,
                  ),
                ),
 const SizedBox(height: 40),
 TextFormField(
 controller: _emailController,
 decoration: const InputDecoration(labelText: '邮箱'),
 keyboardType: TextInputType.emailAddress,
 validator: (value) {
 if (value == null || value.isEmpty) {
 return '请输入邮箱';
                    }
 if (!EmailValidator.validate(value)) {
 return '请输入有效的邮箱地址';
                    }
 return null;
                  },
                ),
 const SizedBox(height: 12),
 TextFormField(
 controller: _passwordController,
 decoration: const InputDecoration(labelText: '密码'),
 obscureText: true,
 validator: (value) {
 if (value == null || value.isEmpty) {
 return '请输入密码';
                    }
 if (value.length < 6) {
 return '密码至少需要6个字符';
                    }
 return null;
                  },
                ),
 const SizedBox(height: 24),
 _isLoading
 ? const Center(child: CircularProgressIndicator())
 : ElevatedButton(
 onPressed: _login,
 child: const Text('登录'),
                      ),
 const SizedBox(height: 16),
 TextButton(
 onPressed: () {
 Navigator.pushNamed(context, '/registration');
                  },
 child: const Text('还没有账号？立即注册'),
                ),
 const SizedBox(height: 8), // Add some spacing
 TextButton(
 onPressed: () {
 // TODO: Implement password reset logic
                  },
 child: const Text('忘记密码？'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}