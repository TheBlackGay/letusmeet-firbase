import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class CreateActivityScreen extends StatefulWidget {
  const CreateActivityScreen({super.key});

  @override
  _CreateActivityScreenState createState() => _CreateActivityScreenState();
}

class _CreateActivityScreenState extends State<CreateActivityScreen> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _maxParticipantsController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();

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

  Future<void> _publishActivity() async {
    setState(() {
      _isLoading = true;
    });

    try {
      await FirebaseFirestore.instance.collection('activities').add({
        'title': _titleController.text,
        'location': _locationController.text,
        'description': _descriptionController.text,
        'type': _selectedActivityType,
        'maxParticipants': int.tryParse(_maxParticipantsController.text) ?? 0,
        'cost': double.tryParse(_costController.text) ?? 0.0,
        'date': 'TODO: Implement date picker', // Placeholder
        'time': 'TODO: Implement time picker', // Placeholder
        'createdAt': Timestamp.now(),
        // Add other fields as needed (e.g., organizer, participants, type, etc.)
      });

      Navigator.pop(context); // Navigate back after successful submission

    } catch (e) {
      print('Error publishing activity: $e');
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
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            TextField(
              controller: _titleController,
              decoration: const InputDecoration(
                labelText: '活动标题',
                hintText: '请输入活动标题',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(
                labelText: '活动类型',
                border: OutlineInputBorder(),
              ),
              value: _selectedActivityType,
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
            ),
            // Placeholder for Date Picker
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('活动日期'),
                  const Icon(Icons.calendar_today),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            // Placeholder for Time Picker
            Container(
               padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 12.0),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.grey),
                borderRadius: BorderRadius.circular(4.0),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('活动时间'),
                  const Icon(Icons.access_time),
                ],
              ),
            ),
            const SizedBox(height: 16.0),
            TextField(
              controller: _locationController,
              decoration: const InputDecoration(
                labelText: '活动地点',
                hintText: '请输入活动地点',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
             TextField(
              controller: _maxParticipantsController,
              keyboardType: TextInputType.number,
              decoration: const InputDecoration(
                labelText: '参与人数上限',
                hintText: '请输入参与人数上限',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),
             TextField(
              controller: _costController,
              keyboardType: TextInputType.numberWithOptions(decimal: true),
              decoration: const InputDecoration(
                labelText: '费用',
                hintText: '请输入活动费用 (可选)',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16.0),


            TextField(
              controller: _descriptionController,
              decoration: const InputDecoration(
                labelText: '活动描述',
                hintText: '请输入活动描述',
                border: OutlineInputBorder(),
              ),
              maxLines: 5,
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
    );
  }
}