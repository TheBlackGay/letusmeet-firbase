import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

import 'package:firebase_auth/firebase_auth.dart';
class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  _CreateActivityScreenState createState() => _CreateActivityScreenState();
}


class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _maxParticipantsController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  DateTime? _selectedEndDate;
  TimeOfDay? _selectedEndTime;

  String? _selectedActivityType;
  bool _isLoading = false;

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _descriptionController.dispose();
    _maxParticipantsController.dispose();
    _costController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2101),
    );
    if (picked != null && picked != _selectedDate) {
      setState(() {
        _selectedDate = picked;
      });
    }
  }

  Future<void> _selectTime(BuildContext context) async {
    final TimeOfDay? picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null && picked != _selectedTime) {
      setState(() {
        _selectedTime = picked;
      });
    }
  }

  Future<void> _publishActivity() async {
    if (!_formKey.currentState!.validate()) {
      return;
    }
     if (_selectedDate == null || _selectedTime == null || _selectedEndDate == null || _selectedEndTime == null) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择活动日期和时间 범위')),
      );
    }
     if (_selectedDate == null || _selectedTime == null) {

       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('请选择活动日期和时间')),
      );
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
       final currentUser = FirebaseAuth.instance.currentUser;
        if (currentUser == null) {
          // Handle case where user is not logged in
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('用户未登录，无法发布活动')),
          );
          return;
        }
      await FirebaseFirestore.instance.collection('activities').add({
        'title': _titleController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'type': _selectedActivityType,
        'maxParticipants': int.tryParse(_maxParticipantsController.text) ?? 0,
        'cost': double.tryParse(_costController.text) ?? 0.0,
         'startTime': DateTime(
          _selectedDate!.year,
          _selectedDate!.month,
          _selectedDate!.day,
          _selectedTime!.hour,
          _selectedTime!.minute,
        ),
 'endTime': DateTime(
 _selectedEndDate!.year,
 _selectedEndDate!.month,
 _selectedEndDate!.day,
 _selectedEndTime!.hour,
 _selectedEndTime!.minute,
 ),
        'organizerId': currentUser.uid,
        'currentParticipantsCount': 0,
        'status': 'upcoming',
        'coverImageUrl': '', // Placeholder for image URL
        'createdAt': Timestamp.now(),
        'updatedAt': Timestamp.now(),
      });
      ScaffoldMessenger.of(context).showSnackBar(
 const SnackBar(content: Text('活动发布成功！')),
 );
      Navigator.pop(context); // Navigate back after successful publishing
    } catch (e) {
      if (mounted) {
 ScaffoldMessenger.of(context).showSnackBar(
 SnackBar(content: Text('发布活动失败：${e.toString()}')),
 );
      }
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('发布新活动'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                controller: _titleController,
                decoration: const InputDecoration(
                  labelText: '活动标题',
                  hintText: '请输入活动标题',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '活动标题不能为空';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(
                  labelText: '活动类型',
                  border: OutlineInputBorder(),
                ),
                initialValue: _selectedActivityType,
                hint: const Text('请选择活动类型'),
                items: ['聚餐', '运动', '桌游', '其他']
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedActivityType = value;
                  });
                },
                // validator is handled before calling _publishActivity
              ),
              const SizedBox(height: 16.0),
              // Date Picker
              ListTile(
                leading: const Icon(Icons.calendar_today),
                title: Text(_selectedDate == null
                    ? '选择活动日期'
                    : '活动日期: ${_selectedDate!.toLocal().toString().split(' ')[0]}'),
                onTap: () => _selectDate(context),
                shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              const SizedBox(height: 16.0),
              // Time Picker
              ListTile(
                leading: const Icon(Icons.access_time),
                title: Text(_selectedTime == null
                    ? '选择活动时间'
                    : '活动时间: ${_selectedTime!.format(context)}'),
                onTap: () => _selectTime(context),
                 shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
                  borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              const SizedBox(height: 16.0),
              // End Date Picker
              ListTile(
 leading: const Icon(Icons.calendar_today),
 title: Text(_selectedEndDate == null
 ? '选择活动结束日期'
 : '活动结束日期: ${_selectedEndDate!.toLocal().toString().split(' ')[0]}'),
 onTap: () => _selectEndDate(context),
 shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
 borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              const SizedBox(height: 16.0),
              // End Time Picker
              ListTile(
 leading: const Icon(Icons.access_time),
 title: Text(_selectedEndTime == null
 ? '选择活动结束时间'
 : '活动结束时间: ${_selectedEndTime!.format(context)}'),
 onTap: () => _selectEndTime(context),
 shape: RoundedRectangleBorder(
                  side: BorderSide(color: Colors.grey.shade400),
 borderRadius: BorderRadius.circular(4.0),
                ),
              ),
              const SizedBox(height: 16.0),
              TextFormField(
                controller: _locationController,
                decoration: const InputDecoration(
                  labelText: '活动地点',
                  hintText: '请输入活动地点',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '活动地点不能为空';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
               TextFormField(
                controller: _maxParticipantsController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: '参与人数上限',
                  hintText: '请输入参与人数上限',
                  border: OutlineInputBorder(),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '参与人数上限不能为空';
                  }
                  if (int.tryParse(value) == null || int.parse(value) <= 0) {
                    return '请输入有效的参与人数上限';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),
               TextFormField(
                controller: _costController,
                keyboardType: TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(
                  labelText: '费用',
                  hintText: '请输入活动费用 (可选)',
                  border: OutlineInputBorder(),
                ),
                 validator: (value) {
                  if (value != null && value.isNotEmpty && double.tryParse(value) == null) {
                    return '请输入有效的费用';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16.0),


              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(
                  labelText: '活动描述',
                  hintText: '请输入活动描述',
                  border: OutlineInputBorder(),
                ),
                maxLines: 5,
                 validator: (value) {
                  if (value == null || value.isEmpty) {
                    return '活动描述不能为空';
                  }
                  return null;
                },
              ),
               const SizedBox(height: 16.0),
               // Placeholder for Image Upload
              Container(
                 padding: const EdgeInsets.symmetric(vertical: 40.0, horizontal: 12.0),
                 decoration: BoxDecoration(
                  border: Border.all(color: Colors.grey),
                  borderRadius: BorderRadius.circular(4.0),
                  ),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.camera_alt_outlined, size: 40.0, color: Colors.grey[600]),
                      const SizedBox(height: 8.0),
                      Text('添加活动图片 (可选)', style: TextStyle(color: Colors.grey[600])),
                    ],
                  ),
              ),
              const SizedBox(height: 24.0),
              ElevatedButton(
                onPressed: _isLoading ? null : _publishActivity,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16.0),
                ),
                child: _isLoading
                    ? const SizedBox(
                        width: 20,
                        height: 20,
                        child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                      )
                    : const Text('发布活动'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

                children: [
                  Text('活动日期'),
                  Icon(Icons.calendar_today),
                ],
              ),
            ),
            SizedBox(height = 16.0),
            // Placeholder for Time Picker
            Container(
               padding = const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              decoration = BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child = Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('活动时间'),
                  const Icon(Icons.access_time),
                ],
              ),
            ),
            SizedBox(height = 16.0),
            TextField(
              controller = _locationController,
              decoration = const InputDecoration(
                labelText: '活动地点',
                hintText: '请输入活动地点',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height = 16.0),
             TextField(
              controller = _maxParticipantsController,
              keyboardType = TextInputType.number,
              decoration = const InputDecoration(
                labelText: '参与人数上限',
                hintText: '请输入参与人数上限',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height = 16.0),
             TextField(
              controller = _costController,
              keyboardType = TextInputType.numberWithOptions(decimal: true),
              decoration = const InputDecoration(
                labelText: '费用',
                hintText: '请输入活动费用 (可选)',
                border: OutlineInputBorder(),
              ),
            ),
            SizedBox(height = 16.0),


            TextField(
              controller = _descriptionController,
              decoration = const InputDecoration(
                labelText: '活动描述',
                hintText: '请输入活动描述',
                border: OutlineInputBorder(),
              ),
              maxLines = 5,
            ),
             SizedBox(height = 16.0),
             // Placeholder for Image Upload
            Container(
               padding = const EdgeInsets.symmetric(vertical: 40.0, horizontal: 12.0),
               decoration = BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
                ),
                child = Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(Icons.camera_alt_outlined, size: 40.0, color: Colors.grey[600]),
                    const SizedBox(height: 8.0),
                    Text('添加活动图片 (可选)', style: TextStyle(color: Colors.grey[600])),
                  ],
                ),
            ),
            SizedBox(height = 24.0),
            ElevatedButton(
              onPressed = _isLoading ? null : _publishActivity,
              style = ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16.0),
              ),
              child = _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                    )
                  : const Text('发布活动'),
            ),
          ],
        ),
      ),
    );
  }
}