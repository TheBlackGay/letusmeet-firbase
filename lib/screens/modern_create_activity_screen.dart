import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class ModernCreateActivityScreen extends StatefulWidget {
  const ModernCreateActivityScreen({super.key});

  @override
  _ModernCreateActivityScreenState createState() => _ModernCreateActivityScreenState();
}

class _ModernCreateActivityScreenState extends State<ModernCreateActivityScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _locationController = TextEditingController();
  final TextEditingController _maxParticipantsController = TextEditingController();
  final TextEditingController _costController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  
  DateTime? _selectedDate;
  TimeOfDay? _selectedTime;
  String? _selectedActivityType;
  bool _isLoading = false;
  int _currentStep = 0;

  final List<String> _activityTypes = [
    'Outdoor Sports',
    'Dining & Social',
    'Arts & Culture',
    'Learning & Study',
    'Travel & Adventure',
    'Other',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Theme.of(context).colorScheme.primaryContainer.withOpacity(0.1),
              Theme.of(context).colorScheme.surface,
            ],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // Custom App Bar
              _buildCustomAppBar().animate().slideY(begin: -0.5, delay: 200.ms),
              
              // Progress Indicator
              _buildProgressIndicator().animate().fadeIn(delay: 400.ms),
              
              // Form Content
              Expanded(
                child: _buildStepContent().animate().fadeIn(delay: 600.ms),
              ),
              
              // Navigation Buttons
              _buildNavigationButtons().animate().slideY(begin: 0.5, delay: 800.ms),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomAppBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Theme.of(context).colorScheme.surface,
              elevation: 2,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Create Activity',
                  style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ),
                Text(
                  'Step ${_currentStep + 1} of 3',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressIndicator() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 24),
      child: Row(
        children: List.generate(3, (index) {
          final isActive = index <= _currentStep;
          final isCompleted = index < _currentStep;
          
          return Expanded(
            child: Container(
              margin: EdgeInsets.only(right: index < 2 ? 8 : 0),
              height: 4,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(2),
                color: isActive 
                    ? Theme.of(context).colorScheme.primary
                    : Theme.of(context).colorScheme.outline.withOpacity(0.3),
              ),
            ).animate(target: isActive ? 1 : 0)
             .scaleX(duration: 300.ms),
          );
        }),
      ),
    );
  }

  Widget _buildStepContent() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Form(
        key: _formKey,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (_currentStep == 0) _buildBasicInfoStep(),
            if (_currentStep == 1) _buildDetailsStep(),
            if (_currentStep == 2) _buildReviewStep(),
          ],
        ),
      ),
    );
  }

  Widget _buildBasicInfoStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Basic Information',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 100.ms),
        
        const SizedBox(height: 24),
        
        // Activity Title
        TextFormField(
          controller: _titleController,
          decoration: InputDecoration(
            labelText: 'Activity Title',
            prefixIcon: const Icon(Icons.title),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Please enter a title' : null,
        ).animate().slideX(delay: 200.ms, begin: -0.3),
        
        const SizedBox(height: 20),
        
        // Activity Type
        DropdownButtonFormField<String>(
          value: _selectedActivityType,
          decoration: InputDecoration(
            labelText: 'Activity Type',
            prefixIcon: const Icon(Icons.category),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
          ),
          items: _activityTypes.map((type) => DropdownMenuItem(
            value: type,
            child: Text(type),
          )).toList(),
          onChanged: (value) => setState(() => _selectedActivityType = value),
          validator: (value) => value == null ? 'Please select a type' : null,
        ).animate().slideX(delay: 300.ms, begin: 0.3),
        
        const SizedBox(height: 20),
        
        // Location
        TextFormField(
          controller: _locationController,
          decoration: InputDecoration(
            labelText: 'Location',
            prefixIcon: const Icon(Icons.location_on),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
          ),
          validator: (value) => value?.isEmpty ?? true ? 'Please enter a location' : null,
        ).animate().slideX(delay: 400.ms, begin: -0.3),
      ],
    );
  }

  Widget _buildDetailsStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Activity Details',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 100.ms),
        
        const SizedBox(height: 24),
        
        // Date and Time
        Row(
          children: [
            Expanded(
              child: InkWell(
                onTap: () => _selectDate(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Date',
                    prefixIcon: const Icon(Icons.calendar_today),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                  ),
                  child: Text(
                    _selectedDate != null
                        ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}'
                        : 'Select Date',
                  ),
                ),
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: InkWell(
                onTap: () => _selectTime(context),
                child: InputDecorator(
                  decoration: InputDecoration(
                    labelText: 'Time',
                    prefixIcon: const Icon(Icons.access_time),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                    filled: true,
                  ),
                  child: Text(
                    _selectedTime != null
                        ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}'
                        : 'Select Time',
                  ),
                ),
              ),
            ),
          ],
        ).animate().slideY(delay: 200.ms, begin: 0.3),
        
        const SizedBox(height: 20),
        
        // Max Participants and Cost
        Row(
          children: [
            Expanded(
              child: TextFormField(
                controller: _maxParticipantsController,
                decoration: InputDecoration(
                  labelText: 'Max Participants',
                  prefixIcon: const Icon(Icons.people),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                ),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value?.isEmpty ?? true) return 'Required';
                  if (int.tryParse(value!) == null) return 'Invalid number';
                  return null;
                },
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: TextFormField(
                controller: _costController,
                decoration: InputDecoration(
                  labelText: 'Cost (\$)',
                  prefixIcon: const Icon(Icons.attach_money),
                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
                  filled: true,
                ),
                keyboardType: TextInputType.number,
              ),
            ),
          ],
        ).animate().slideY(delay: 300.ms, begin: 0.3),
        
        const SizedBox(height: 20),
        
        // Description
        TextFormField(
          controller: _descriptionController,
          decoration: InputDecoration(
            labelText: 'Description',
            prefixIcon: const Icon(Icons.description),
            border: OutlineInputBorder(borderRadius: BorderRadius.circular(16)),
            filled: true,
          ),
          maxLines: 4,
          validator: (value) => value?.isEmpty ?? true ? 'Please enter a description' : null,
        ).animate().fadeIn(delay: 400.ms),
      ],
    );
  }

  Widget _buildReviewStep() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Review & Publish',
          style: Theme.of(context).textTheme.titleLarge?.copyWith(
            fontWeight: FontWeight.bold,
          ),
        ).animate().fadeIn(delay: 100.ms),
        
        const SizedBox(height: 24),
        
        Card(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildReviewItem('Title', _titleController.text),
                _buildReviewItem('Type', _selectedActivityType ?? ''),
                _buildReviewItem('Location', _locationController.text),
                _buildReviewItem('Date', _selectedDate != null 
                    ? '${_selectedDate!.day}/${_selectedDate!.month}/${_selectedDate!.year}' : ''),
                _buildReviewItem('Time', _selectedTime != null 
                    ? '${_selectedTime!.hour}:${_selectedTime!.minute.toString().padLeft(2, '0')}' : ''),
                _buildReviewItem('Max Participants', _maxParticipantsController.text),
                _buildReviewItem('Cost', _costController.text.isEmpty ? 'Free' : '\$${_costController.text}'),
                _buildReviewItem('Description', _descriptionController.text),
              ],
            ),
          ),
        ).animate().scale(delay: 200.ms),
      ],
    );
  }

  Widget _buildReviewItem(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 120,
            child: Text(
              label,
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w600,
                color: Theme.of(context).colorScheme.primary,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value.isEmpty ? 'Not specified' : value,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNavigationButtons() {
    return Container(
      padding: const EdgeInsets.all(24),
      child: Row(
        children: [
          if (_currentStep > 0)
            Expanded(
              child: OutlinedButton(
                onPressed: () => setState(() => _currentStep--),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Back'),
              ),
            ),
          if (_currentStep > 0) const SizedBox(width: 16),
          Expanded(
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleNext,
              style: ElevatedButton.styleFrom(
                padding: const EdgeInsets.symmetric(vertical: 16),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                backgroundColor: Theme.of(context).colorScheme.primary,
              ),
              child: _isLoading
                  ? const SizedBox(
                      height: 20,
                      width: 20,
                      child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white),
                    )
                  : Text(_currentStep == 2 ? 'Publish Activity' : 'Next'),
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDate ?? DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _selectedDate = picked);
  }

  Future<void> _selectTime(BuildContext context) async {
    final picked = await showTimePicker(
      context: context,
      initialTime: _selectedTime ?? TimeOfDay.now(),
    );
    if (picked != null) setState(() => _selectedTime = picked);
  }

  void _handleNext() {
    if (_currentStep < 2) {
      if (_validateCurrentStep()) {
        setState(() => _currentStep++);
      }
    } else {
      _publishActivity();
    }
  }

  bool _validateCurrentStep() {
    switch (_currentStep) {
      case 0:
        return _titleController.text.isNotEmpty &&
               _selectedActivityType != null &&
               _locationController.text.isNotEmpty;
      case 1:
        return _selectedDate != null &&
               _selectedTime != null &&
               _maxParticipantsController.text.isNotEmpty &&
               _descriptionController.text.isNotEmpty;
      default:
        return true;
    }
  }

  Future<void> _publishActivity() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isLoading = true);

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user == null) throw Exception('Please login first');

      final startDateTime = DateTime(
        _selectedDate!.year,
        _selectedDate!.month,
        _selectedDate!.day,
        _selectedTime!.hour,
        _selectedTime!.minute,
      );

      await FirebaseFirestore.instance.collection('activities').add({
        'title': _titleController.text.trim(),
        'description': _descriptionController.text.trim(),
        'location': _locationController.text.trim(),
        'activityType': _selectedActivityType,
        'maxParticipants': int.parse(_maxParticipantsController.text),
        'cost': double.tryParse(_costController.text) ?? 0.0,
        'startTime': Timestamp.fromDate(startDateTime),
        'organizerId': user.uid,
        'currentParticipantsCount': 0,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'active',
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(Icons.check_circle, color: Colors.white),
                const SizedBox(width: 8),
                const Text('Activity published successfully!'),
              ],
            ),
            backgroundColor: Colors.green,
            behavior: SnackBarBehavior.floating,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to publish: $e'),
            backgroundColor: Theme.of(context).colorScheme.error,
          ),
        );
      }
    } finally {
      setState(() => _isLoading = false);
    }
  }

  @override
  void dispose() {
    _titleController.dispose();
    _locationController.dispose();
    _maxParticipantsController.dispose();
    _costController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }
}