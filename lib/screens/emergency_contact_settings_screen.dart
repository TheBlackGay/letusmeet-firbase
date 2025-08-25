import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyContactSettingsScreen extends StatefulWidget {
  const EmergencyContactSettingsScreen({Key? key}) : super(key: key);

  @override
  _EmergencyContactSettingsScreenState createState() =>
      _EmergencyContactSettingsScreenState();
}

class _EmergencyContactSettingsScreenState
    extends State<EmergencyContactSettingsScreen> {
  final _formKey = GlobalKey<FormState>();
  final List<TextEditingController> _nameControllers = [];
  final List<TextEditingController> _phoneControllers = [];
  final int _maxContacts = 3;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadEmergencyContacts();
  }

  @override
  void dispose() {
    for (var controller in _nameControllers) {
      controller.dispose();
    }
    for (var controller in _phoneControllers) {
      controller.dispose();
    }
    super.dispose();
  }

  Future<void> _loadEmergencyContacts() async {
    setState(() {
      _isLoading = true;
    });
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId != null) {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        if (userDoc.exists) {
          final data = userDoc.data();
          if (data != null && data['emergencyContacts'] != null) {
            final contacts = List<Map<String, dynamic>>.from(
                data['emergencyContacts']);
            for (var contact in contacts) {
              _nameControllers
                  .add(TextEditingController(text: contact['name'] ?? ''));
              _phoneControllers
                  .add(TextEditingController(text: contact['phone'] ?? ''));
            }
          }
        }
      }
      // Add empty controllers if less than max contacts loaded
      while (_nameControllers.length < _maxContacts) {
        _nameControllers.add(TextEditingController());
        _phoneControllers.add(TextEditingController());
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('加载紧急联系人失败：$e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _saveEmergencyContacts() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });
      try {
        final userId = FirebaseAuth.instance.currentUser?.uid;
        if (userId != null) {
          final List<Map<String, dynamic>> contactsToSave = [];
          for (int i = 0; i < _maxContacts; i++) {
            if (_nameControllers[i].text.isNotEmpty ||
                _phoneControllers[i].text.isNotEmpty) {
              contactsToSave.add({
                'name': _nameControllers[i].text.trim(),
                'phone': _phoneControllers[i].text.trim(),
              });
            }
          }

          await FirebaseFirestore.instance
              .collection('users')
              .doc(userId)
              .update({'emergencyContacts': contactsToSave});

          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('紧急联系人保存成功！')),
          );
          Navigator.of(context).pop(); // Navigate back after saving

        }
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('保存紧急联系人失败：$e')),
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
        title: const Text('紧急联系人设置'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: ListView.builder(
                  itemCount: _maxContacts + 1, // +1 for the save button
                  itemBuilder: (context, index) {
                    if (index < _maxContacts) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('紧急联系人 ${index + 1}'),
                            const SizedBox(height: 8.0),
                            TextFormField(
                              controller: _nameControllers[index],
                              decoration: const InputDecoration(
                                labelText: '姓名',
                                border: OutlineInputBorder(),
                              ),
                              validator: (value) {
                                // Optional validation: require both name and phone if one is filled
                                if ((value?.isNotEmpty ?? false) &&
                                    (_phoneControllers[index].text.isEmpty)) {
                                  return '请填写电话号码';
                                }
                                if ((value?.isEmpty ?? false) &&
                                    (_phoneControllers[index].text.isNotEmpty)) {
                                   return '请填写姓名';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 8.0),
                            TextFormField(
                              controller: _phoneControllers[index],
                              decoration: const InputDecoration(
                                labelText: '电话号码',
                                border: OutlineInputBorder(),
                              ),
                              keyboardType: TextInputType.phone,
                              validator: (value) {
                                // Optional validation: require both name and phone if one is filled
                                if ((value?.isNotEmpty ?? false) &&
                                    (_nameControllers[index].text.isEmpty)) {
                                  return '请填写姓名';
                                }
                                if ((value?.isEmpty ?? false) &&
                                    (_nameControllers[index].text.isNotEmpty)) {
                                   return '请填写电话号码';
                                }
                                return null;
                              },
                            ),
                          ],
                        ),
                      );
                    } else {
                      return ElevatedButton(
                        onPressed: _saveEmergencyContacts,
                        child: const Text('保存'),
                      );
                    }
                  },
                ),
              ),
            ),
    );
  }
}