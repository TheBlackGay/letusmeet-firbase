import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:math';

class AnimatedActivityDetailScreen extends StatefulWidget {
  final String activityId;

  const AnimatedActivityDetailScreen({super.key, required this.activityId});

  @override
  _AnimatedActivityDetailScreenState createState() => _AnimatedActivityDetailScreenState();
}

class _AnimatedActivityDetailScreenState extends State<AnimatedActivityDetailScreen> {
  late final String activityId;
  late Future<Map<String, dynamic>?> _activityDetails;
  bool _isApplied = false;
  String? _dynamicSafetyCode;

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  @override
  void initState() {
    super.initState();
    activityId = widget.activityId;
    _activityDetails = _fetchActivityDetails();
    _checkIfApplied();
  }

  String _generateSafetyCode() {
    const chars = 'ABCDEFGHIJKLMNOPQRSTUVWXYZ1234567890';
    Random rnd = Random();
    return String.fromCharCodes(Iterable.generate(6, (_) => chars.codeUnitAt(rnd.nextInt(chars.length))));
  }

  String _formatTimestamp(Timestamp? timestamp) {
    if (timestamp == null) return 'Time TBD';
    final date = timestamp.toDate();
    return '${date.year}-${date.month.toString().padLeft(2, '0')}-${date.day.toString().padLeft(2, '0')} ${date.hour.toString().padLeft(2, '0')}:${date.minute.toString().padLeft(2, '0')}';
  }

  Future<Map<String, dynamic>?> _fetchActivityDetails() async {
    try {
      final doc = await _firestore.collection('activities').doc(activityId).get();
      if (doc.exists) {
        return doc.data();
      }
      return null;
    } catch (e) {
      print('Error fetching activity details: $e');
      return null;
    }
  }

  Future<void> _checkIfApplied() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final doc = await _firestore
            .collection('activities')
            .doc(activityId)
            .collection('participants')
            .doc(user.uid)
            .get();
        
        if (doc.exists) {
          final data = doc.data();
          setState(() {
            _isApplied = true;
            _dynamicSafetyCode = data?['dynamicSafetyCode'];
          });
        }
      }
    } catch (e) {
      print('Error checking application status: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>?>(
        future: _activityDetails,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return _buildLoadingState();
          }
          
          if (snapshot.hasError) {
            return _buildErrorState('Loading failed: ${snapshot.error}');
          }
          
          final activityData = snapshot.data;
          if (activityData == null) {
            return _buildErrorState('Activity not found');
          }
          
          return _buildActivityDetail(activityData);
        },
      ),
    );
  }

  Widget _buildLoadingState() {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(
                Theme.of(context).colorScheme.primary,
              ),
            ).animate().scale(duration: 1000.ms).then().shake(),
            const SizedBox(height: 24),
            Text(
              'Loading event details...',
              style: Theme.of(context).textTheme.bodyLarge,
            ).animate().fadeIn(delay: 500.ms),
          ],
        ),
      ),
    );
  }

  Widget _buildErrorState(String message) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Theme.of(context).colorScheme.error,
            ).animate().scale(delay: 200.ms),
            const SizedBox(height: 24),
            Text(
              message,
              style: Theme.of(context).textTheme.headlineSmall,
              textAlign: TextAlign.center,
            ).animate().fadeIn(delay: 400.ms),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Go Back'),
            ).animate().slideY(delay: 600.ms, begin: 0.3),
          ],
        ),
      ),
    );
  }

  Widget _buildActivityDetail(Map<String, dynamic> activityData) {
    return CustomScrollView(
      slivers: [
        // App Bar with Hero Image
        SliverAppBar(
          expandedHeight: 300,
          pinned: true,
          flexibleSpace: FlexibleSpaceBar(
            background: Container(
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Theme.of(context).colorScheme.primary.withOpacity(0.8),
                    Theme.of(context).colorScheme.secondary.withOpacity(0.6),
                  ],
                ),
              ),
              child: Stack(
                fit: StackFit.expand,
                children: [
                  // Background pattern or image
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Theme.of(context).colorScheme.primary.withOpacity(0.1),
                          Theme.of(context).colorScheme.secondary.withOpacity(0.1),
                        ],
                      ),
                    ),
                  ),
                  // Event icon
                  Center(
                    child: Icon(
                      Icons.event,
                      size: 80,
                      color: Colors.white.withOpacity(0.9),
                    ).animate().scale(delay: 300.ms, duration: 800.ms),
                  ),
                ],
              ),
            ),
          ),
          actions: [
            IconButton(
              icon: const Icon(Icons.share, color: Colors.white),
              onPressed: () => _shareActivity(),
            ).animate().scale(delay: 500.ms),
          ],
        ),
        
        // Content
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title
                Text(
                  activityData['title'] ?? 'No Title',
                  style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 400.ms).slideY(begin: 0.3),
                
                const SizedBox(height: 24),
                
                // Info Cards
                _buildInfoCard(
                  Icons.access_time,
                  'Time',
                  _formatTimestamp(activityData['startTime']),
                  0,
                ),
                
                _buildInfoCard(
                  Icons.location_on,
                  'Location',
                  activityData['location'] ?? 'Unknown Location',
                  1,
                ),
                
                _buildInfoCard(
                  Icons.people,
                  'Participants',
                  '${activityData['currentParticipantsCount'] ?? 0}/${activityData['maxParticipants'] ?? 0} people',
                  2,
                ),
                
                if (activityData['cost'] != null && activityData['cost'] > 0)
                  _buildInfoCard(
                    Icons.attach_money,
                    'Cost',
                    '\$${activityData['cost']}',
                    3,
                  ),
                
                const SizedBox(height: 32),
                
                // Description Section
                Text(
                  'About This Event',
                  style: Theme.of(context).textTheme.titleLarge?.copyWith(
                    fontWeight: FontWeight.bold,
                  ),
                ).animate().fadeIn(delay: 800.ms),
                
                const SizedBox(height: 16),
                
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surfaceVariant.withOpacity(0.3),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: Text(
                    activityData['description'] ?? 'No description available',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ).animate().fadeIn(delay: 900.ms).slideY(begin: 0.2),
                
                const SizedBox(height: 32),
                
                // Safety Code (if applied)
                if (_isApplied && _dynamicSafetyCode != null) ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          Colors.green.shade50,
                          Colors.green.shade100,
                        ],
                      ),
                      border: Border.all(color: Colors.green.shade300),
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Column(
                      children: [
                        Icon(
                          Icons.security,
                          size: 48,
                          color: Colors.green.shade700,
                        ).animate().scale(delay: 1000.ms),
                        const SizedBox(height: 16),
                        Text(
                          'Your Safety Code',
                          style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            fontWeight: FontWeight.bold,
                            color: Colors.green.shade700,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: Colors.green.shade300),
                          ),
                          child: Text(
                            _dynamicSafetyCode!,
                            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                              letterSpacing: 4,
                              color: Colors.green.shade700,
                            ),
                          ),
                        ).animate().scale(delay: 1100.ms),
                        const SizedBox(height: 12),
                        Text(
                          'Show this code at the event',
                          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: Colors.green.shade600,
                          ),
                        ),
                      ],
                    ),
                  ).animate().fadeIn(delay: 1000.ms).slideY(begin: 0.3),
                  const SizedBox(height: 32),
                ],
                
                // Join Button
                SizedBox(
                  width: double.infinity,
                  height: 56,
                  child: ElevatedButton(
                    onPressed: _isApplied ? null : () => _signUpForActivity(),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: _isApplied 
                          ? Theme.of(context).colorScheme.surfaceVariant
                          : Theme.of(context).colorScheme.primary,
                      foregroundColor: _isApplied 
                          ? Theme.of(context).colorScheme.onSurfaceVariant
                          : Theme.of(context).colorScheme.onPrimary,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                      elevation: _isApplied ? 0 : 3,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(_isApplied ? Icons.check_circle : Icons.event_available),
                        const SizedBox(width: 8),
                        Text(
                          _isApplied ? 'Already Joined' : 'Join Event',
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ],
                    ),
                  ),
                ).animate().fadeIn(delay: 1200.ms).scale(delay: 1200.ms),
                
                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildInfoCard(IconData icon, String title, String value, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).colorScheme.outline.withOpacity(0.2),
        ),
        boxShadow: [
          BoxShadow(
            color: Theme.of(context).colorScheme.shadow.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.primaryContainer,
              borderRadius: BorderRadius.circular(12),
            ),
            child: Icon(
              icon,
              color: Theme.of(context).colorScheme.onPrimaryContainer,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    ).animate().fadeIn(delay: Duration(milliseconds: 600 + index * 100))
     .slideX(begin: 0.3, delay: Duration(milliseconds: 600 + index * 100));
  }

  Future<void> _signUpForActivity() async {
    final user = _auth.currentUser;
    if (user == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.warning, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Please log in first'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
      return;
    }

    try {
      // Generate safety code
      final safetyCode = _generateSafetyCode();
      
      // Add user to participants
      await _firestore
          .collection('activities')
          .doc(activityId)
          .collection('participants')
          .doc(user.uid)
          .set({
        'userId': user.uid,
        'joinedAt': FieldValue.serverTimestamp(),
        'dynamicSafetyCode': safetyCode,
      });

      // Update participant count
      await _firestore.collection('activities').doc(activityId).update({
        'currentParticipantsCount': FieldValue.increment(1),
      });

      setState(() {
        _isApplied = true;
        _dynamicSafetyCode = safetyCode;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.check_circle, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Successfully joined the event!'),
            ],
          ),
          backgroundColor: Colors.green,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    } catch (e) {
      print('Error signing up: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Row(
            children: [
              Icon(Icons.error, color: Colors.white),
              const SizedBox(width: 8),
              const Text('Failed to join event. Please try again.'),
            ],
          ),
          backgroundColor: Theme.of(context).colorScheme.error,
          behavior: SnackBarBehavior.floating,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        ),
      );
    }
  }

  void _shareActivity() {
    Share.share('Check out this amazing event!');
  }
}