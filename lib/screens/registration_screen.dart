import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
class RegistrationScreen extends StatefulWidget {
  const RegistrationScreen({super.key});

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    bool isButtonEnabled = _emailController.text.isNotEmpty &&
        _passwordController.text.isNotEmpty &&
        _confirmPasswordController.text.isNotEmpty &&
        _passwordController.text == _confirmPasswordController.text &&
        !_isLoading;

    // Simple email format validation (more robust validation might be needed)
    final bool isValidEmail = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(_emailController.text);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Registration'),
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              const Text(
                'Register',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                onChanged: (_) {
                  // Trigger rebuild for button state
                  setState(() {});
                },
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                decoration: const InputDecoration(labelText: 'Password'),
                onChanged: (_) {
                  // Trigger rebuild for button state
                  setState(() {});
                },
                obscureText: true,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _confirmPasswordController,
                decoration: const InputDecoration(labelText: 'Confirm Password'),
                obscureText: true,
                onChanged: (_) {
                  // Trigger rebuild for button state
                  setState(() {});
                },
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: isButtonEnabled && isValidEmail
                    ? () async {
                        setState(() {
                          _isLoading = true;
                        });
                        try {
                          await FirebaseAuth.instance.createUserWithEmailAndPassword(
                            email: _emailController.text,
                            password: _passwordController.text,
                          );
                          // Navigate to home or success screen after registration
                          
                          // Create user document in Firestore
                          await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
                            'uid': userCredential.user!.uid,
                            'email': _emailController.text,
                            'nickname': '新用户', // Default nickname
                            'level': '基础用户', // Default level
                            'auth_status': '未认证', // Default authentication status
                          });

                          

                          if (mounted) {
                             // Navigate to the authentication screen after successful registration
                             Navigator.pushReplacementNamed(context, '/authentication');
                          }
                        } on FirebaseAuthException catch (e) {
                          // Handle specific Firebase Auth errors
                          print('Registration failed: ${e.message}');
                           // TODO: Show user-friendly error message
                        } catch (e) {
                          // Handle other potential errors
                          print('An unexpected error occurred: $e');
                           // TODO: Show user-friendly error message
                        } finally {
                           if (mounted) {
                              setState(() {
                                _isLoading = false;
                              });
                           }
                        }
                      }
                    : null, // Disable button if not enabled
                child: _isLoading
                    ? const CircularProgressIndicator(color: Colors.white)
                    : const Text('Register'),            ),
              const SizedBox(height: 10),            TextButton(
                onPressed: () {
                  Navigator.pop(context); // Navigate back to login            },
                child: const Text('Already have an account? Login'),            ),
            ],          ),
        ),      ),
    );  }

  _registerUser() async {
    setState(() {
      _isLoading = true;
    });
    try {
      UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      // Create user document in Firestore
      await FirebaseFirestore.instance.collection('users').doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': _emailController.text,
        'nickname': '新用户', // Default nickname
        'level': '基础用户', // Default level
        'auth_status': '未认证', // Default authentication status
      });

      if (mounted) {
        // Navigate to the authentication screen after successful registration
        Navigator.pushReplacementNamed(context, '/authentication');
      }
    } on FirebaseAuthException catch (e) {
      // Handle specific Firebase Auth errors
      print('Registration failed: ${e.message}');
      // TODO: Show user-friendly error message
    } catch (e) {
      // Handle other potential errors
      print('An unexpected error occurred: $e');
      // TODO: Show user-friendly error message
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }
}