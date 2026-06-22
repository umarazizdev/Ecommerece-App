import 'package:addproduct/constants/firebase_paths.dart';
import 'package:addproduct/main.dart';
import 'package:addproduct/screens/settings_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final User? _user = FirebaseAuth.instance.currentUser;

  String _displayName() {
    final cachedName = box.read('name')?.toString();
    if (cachedName != null && cachedName.isNotEmpty) {
      return cachedName;
    }
    return _user?.email?.split('@').first ?? 'User';
  }

  String _initial() {
    final name = _displayName();
    return name.isNotEmpty ? name[0].toUpperCase() : 'U';
  }

  Widget _infoTile({
    required IconData icon,
    required String label,
    required String value,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Row(
        children: [
          Container(
            height: 40,
            width: 40,
            decoration: BoxDecoration(
              color: Colors.black,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: Colors.white, size: 20),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  label,
                  style: const TextStyle(
                    color: Colors.grey,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  value,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProfileBody({
    required String name,
    required String email,
    required String joinedDate,
    required String uid,
  }) {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: SingleChildScrollView(
        child: Column(
          children: [
            const SizedBox(height: 10),
            CircleAvatar(
              radius: 50,
              backgroundColor: Colors.black,
              child: Text(
                name.isNotEmpty ? name[0].toUpperCase() : _initial(),
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 36,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            Text(
              name,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 5),
            Text(
              email,
              style: const TextStyle(
                color: Colors.grey,
                fontSize: 15,
              ),
            ),
            const SizedBox(height: 25),
            _infoTile(
              icon: Icons.person_outline,
              label: 'Full Name',
              value: name,
            ),
            const SizedBox(height: 15),
            _infoTile(
              icon: Icons.email_outlined,
              label: 'Email Address',
              value: email,
            ),
            const SizedBox(height: 15),
            _infoTile(
              icon: Icons.calendar_today_outlined,
              label: 'Member Since',
              value: joinedDate,
            ),
            const SizedBox(height: 15),
            _infoTile(
              icon: Icons.fingerprint,
              label: 'User ID',
              value: uid,
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: MaterialButton(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(35),
                  side: const BorderSide(color: Colors.black),
                ),
                color: Colors.white,
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const SettingsScreen(),
                    ),
                  ).then((_) => setState(() {}));
                },
                child: const Text(
                  'Go to Settings',
                  style: TextStyle(
                    fontSize: 15.5,
                    color: Colors.black,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final uid = _user?.uid ?? box.read('uid')?.toString() ?? '';
    final cachedEmail =
        box.read('email')?.toString() ?? _user?.email ?? 'Not set';

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        title: const Text(
          'Profile',
          style: TextStyle(color: Colors.black),
        ),
        elevation: 0,
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SettingsScreen(),
                ),
              ).then((_) => setState(() {}));
            },
            icon: const Icon(Icons.settings_outlined, color: Colors.black),
          ),
        ],
      ),
      body: uid.isEmpty
          ? const Center(
              child: Text(
                'Please login to view your profile',
                style: TextStyle(color: Colors.grey),
              ),
            )
          : StreamBuilder<DocumentSnapshot>(
              stream: FirebasePaths.userDoc(uid).snapshots(),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting &&
                    !snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(
                      color: Colors.black,
                      strokeWidth: 1,
                    ),
                  );
                }

                if (snapshot.hasError) {
                  return _buildProfileBody(
                    name: _displayName(),
                    email: cachedEmail,
                    joinedDate: 'Recently joined',
                    uid: uid,
                  );
                }

                final data =
                    snapshot.data?.data() as Map<String, dynamic>? ?? {};
                final name = data['name']?.toString() ?? _displayName();
                final email = data['email']?.toString() ?? cachedEmail;
                final createdAt = data['createdAt'] as Timestamp?;
                final joinedDate = createdAt != null
                    ? '${createdAt.toDate().day}/${createdAt.toDate().month}/${createdAt.toDate().year}'
                    : 'Recently joined';

                return _buildProfileBody(
                  name: name,
                  email: email,
                  joinedDate: joinedDate,
                  uid: uid,
                );
              },
            ),
    );
  }
}
