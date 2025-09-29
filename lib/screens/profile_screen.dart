import 'dart:io';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  final _nameController = TextEditingController();
  final _emailController = TextEditingController();

  bool _isEditingName = false;
  bool _isEditingEmail = false;
  bool _loading = true;

  String _avatarUrl =
      'https://tse2.mm.bing.net/th/id/OIP.5Bq6Zt9mJzLPh_4XJbLR0AHaHa?pid=Api&h=220&P=0';

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      final doc = await _firestore.collection('users').doc(user.uid).get();
      if (doc.exists) {
        final data = doc.data()!;
        _nameController.text = data['name'] ?? '';
        _emailController.text = user.email ?? '';
        _avatarUrl = data['avatar'] ?? _avatarUrl;
      }
    }
    setState(() => _loading = false);
  }

  Future<void> _updateName() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore
          .collection('users')
          .doc(user.uid)
          .set({'name': _nameController.text.trim()}, SetOptions(merge: true));
      setState(() => _isEditingName = false);
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Name updated successfully!')));
    }
  }

  Future<void> _updateEmail() async {
    final user = _auth.currentUser;
    if (user != null && _emailController.text.trim() != user.email) {
      try {
        await user.verifyBeforeUpdateEmail(_emailController.text.trim());
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content: Text('Verification email sent. Please verify to update your email.')));
        setState(() => _isEditingEmail = false);
      } catch (e) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
      }
    }
  }

  Future<void> _updateAvatar() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(
        source: ImageSource.gallery, imageQuality: 75);
    if (pickedFile != null) {
      final user = _auth.currentUser;
      if (user != null) {
        final file = File(pickedFile.path);
        final ref = _storage.ref().child('avatars/${user.uid}.jpg');
        await ref.putFile(file);
        final url = await ref.getDownloadURL();
        await _firestore
            .collection('users')
            .doc(user.uid)
            .set({'avatar': url}, SetOptions(merge: true));
        setState(() => _avatarUrl = url);
      }
    }
  }

  Future<void> _logout() async {
    await _auth.signOut();
    Navigator.popUntil(context, (route) => route.isFirst); // Navigate back safely
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator(color: Colors.blue)),
      );
    }

    return Scaffold(
      backgroundColor: const Color(0xFFF5F6FA),
      appBar: AppBar(
        title: const Text(
          'My Profile',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            color: Color(0xFF2563EB),
          ),
        ),
        backgroundColor: Colors.white,
        elevation: 1,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF2563EB)),
          onPressed: () => Navigator.pop(context), // normal back navigation
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            // Avatar with edit button
            Stack(
              children: [
                CircleAvatar(
                  radius: 55,
                  backgroundImage: NetworkImage(_avatarUrl),
                ),
                Positioned(
                  bottom: 0,
                  right: 4,
                  child: InkWell(
                    onTap: _updateAvatar,
                    child: Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.blue,
                        shape: BoxShape.circle,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.2),
                            blurRadius: 4,
                            offset: const Offset(0, 2),
                          )
                        ],
                      ),
                      child: const Icon(Icons.edit, color: Colors.white, size: 18),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Name field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _nameController,
                    enabled: _isEditingName,
                    decoration: const InputDecoration(
                      labelText: 'Full Name',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(_isEditingName ? Icons.check : Icons.edit,
                      color: Colors.blue),
                  onPressed: () {
                    if (_isEditingName) {
                      _updateName();
                    } else {
                      setState(() => _isEditingName = true);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 15),

            // Email field
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _emailController,
                    enabled: _isEditingEmail,
                    decoration: const InputDecoration(
                      labelText: 'Email',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                IconButton(
                  icon: Icon(_isEditingEmail ? Icons.check : Icons.edit,
                      color: Colors.blue),
                  onPressed: () {
                    if (_isEditingEmail) {
                      _updateEmail();
                    } else {
                      setState(() => _isEditingEmail = true);
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 30),

            // Options cards
            Container(
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: Column(
                children: [
                  ListTile(
                    leading: const Icon(Icons.settings, color: Color(0xFF2563EB)),
                    title: const Text("Settings"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading:
                    const Icon(Icons.help_outline, color: Color(0xFF2563EB)),
                    title: const Text("Help & Support"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: () {},
                  ),
                  const Divider(height: 1),
                  ListTile(
                    leading: const Icon(Icons.logout, color: Colors.red),
                    title: const Text("Logout"),
                    trailing: const Icon(Icons.arrow_forward_ios, size: 16),
                    onTap: _logout,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
