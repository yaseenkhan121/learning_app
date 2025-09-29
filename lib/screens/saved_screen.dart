import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class SavedScreen extends StatefulWidget {
  const SavedScreen({super.key});

  @override
  State<SavedScreen> createState() => _SavedScreenState();
}

class _SavedScreenState extends State<SavedScreen> {
  late DatabaseReference _savedRef;
  final _auth = FirebaseAuth.instance;
  List<Map<dynamic, dynamic>> _savedLessons = [];
  bool _loading = true;

  @override
  void initState() {
    super.initState();
    _setupFirebase();
  }

  void _setupFirebase() {
    final user = _auth.currentUser;
    if (user != null) {
      _savedRef = FirebaseDatabase.instance.ref("users/${user.uid}/saved_lessons");

      // Listen for realtime updates
      _savedRef.onValue.listen((event) {
        final data = event.snapshot.value as Map<dynamic, dynamic>?;

        setState(() {
          _savedLessons = data != null
              ? data.entries.map((e) {
            final map = Map<String, dynamic>.from(e.value);
            map['key'] = e.key; // Store the key for deletion
            return map;
          }).toList()
              : [];
          _loading = false;
        });
      });
    } else {
      setState(() => _loading = false);
    }
  }

  void _deleteLesson(String key) async {
    await _savedRef.child(key).remove();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Lesson removed from saved list')),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      appBar: AppBar(
        title: const Text(
          'Saved Lessons',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 2,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : _savedLessons.isEmpty
          ? _buildEmptyState()
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: _savedLessons.length,
        itemBuilder: (context, index) {
          final lesson = _savedLessons[index];
          return Dismissible(
            key: Key(lesson['key']),
            direction: DismissDirection.endToStart,
            background: Container(
              alignment: Alignment.centerRight,
              padding: const EdgeInsets.only(right: 20),
              decoration: BoxDecoration(
                color: Colors.redAccent,
                borderRadius: BorderRadius.circular(16),
              ),
              child: const Icon(Icons.delete, color: Colors.white),
            ),
            onDismissed: (_) {
              _deleteLesson(lesson['key']);
            },
            child: Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [Colors.white, Color(0xFFF0F9FF)],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: Row(
                children: [
                  Container(
                    width: 44,
                    height: 44,
                    decoration: const BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: [Color(0xFF3B82F6), Color(0xFF1E3A8A)],
                      ),
                    ),
                    child: const Icon(Icons.bookmark, color: Colors.white, size: 24),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Text(
                      lesson['title'] ?? 'Untitled Lesson',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete, color: Colors.redAccent),
                    onPressed: () {
                      if (lesson['key'] != null) {
                        _deleteLesson(lesson['key']);
                      }
                    },
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(Icons.bookmark_outline, size: 100, color: Colors.blueGrey[400]),
          const SizedBox(height: 20),
          Text(
            'No saved lessons yet',
            style: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w600,
              color: Colors.blueGrey[600],
            ),
          ),
          const SizedBox(height: 10),
          Text(
            'Tap the bookmark icon on a lesson to save it.',
            style: TextStyle(
              fontSize: 15,
              color: Colors.blueGrey[400],
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
