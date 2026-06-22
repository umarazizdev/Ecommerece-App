import 'package:addproduct/main.dart';
import 'package:addproduct/screens/forgot_password_screen.dart';
import 'package:addproduct/services/auth_service.dart';
import 'package:addproduct/utils/navigation_helper.dart';
import 'package:addproduct/widgets/app_primary_button.dart';
import 'package:addproduct/widgets/app_text_field.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easyloading/flutter_easyloading.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _authService = AuthService();
  final _nameController = TextEditingController();
  bool _notificationsEnabled = true;

  @override
  void initState() {
    super.initState();
    _nameController.text = box.read('name')?.toString() ?? '';
    _notificationsEnabled =
        box.read('notifications') as bool? ?? true;
  }

  @override
  void dispose() {
    _nameController.dispose();
    super.dispose();
  }

  Future<void> _saveProfile() async {
    if (_nameController.text.trim().isEmpty) {
      EasyLoading.showToast('Please enter your name');
      return;
    }

    try {
      await _authService.runWithLoading(
        () => _authService.updateProfile(name: _nameController.text),
      );
      EasyLoading.showSuccess('Profile updated');
      if (mounted) setState(() {});
    } catch (_) {
      EasyLoading.showError('Failed to update profile');
    }
  }

  Future<void> _sendPasswordReset() async {
    final email =
        FirebaseAuth.instance.currentUser?.email ??
            box.read('email')?.toString() ??
            '';

    if (email.isEmpty) {
      EasyLoading.showToast('No email found for this account');
      return;
    }

    try {
      await _authService.runWithLoading(
        () => _authService.sendPasswordReset(email),
      );
      EasyLoading.showSuccess('Password reset email sent');
    } catch (_) {
      EasyLoading.showError('Failed to send reset email');
    }
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Logout'),
        content: const Text('Are you sure you want to logout?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel', style: TextStyle(color: Colors.grey)),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Logout', style: TextStyle(color: Colors.black)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    try {
      await _authService.runWithLoading(() => _authService.signOut());
      if (!mounted) return;
      EasyLoading.showSuccess('Logged out successfully');
      resetToAuthScreen();
    } catch (_) {
      EasyLoading.showError('Failed to logout. Please try again.');
    }
  }

  Widget _settingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    Widget? trailing,
    VoidCallback? onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        margin: const EdgeInsets.only(bottom: 12),
        padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
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
                    title,
                    style: const TextStyle(
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  if (subtitle != null) ...[
                    const SizedBox(height: 2),
                    Text(
                      subtitle,
                      style: const TextStyle(color: Colors.grey, fontSize: 13),
                    ),
                  ],
                ],
              ),
            ),
            if (trailing != null) trailing,
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        centerTitle: true,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Text(
          'Settings',
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(15.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Edit Profile',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              AppTextField(
                controller: _nameController,
                hintText: 'Enter Full Name',
              ),
              const SizedBox(height: 15),
              AppPrimaryButton(label: 'Save Changes', onPressed: _saveProfile),
              const SizedBox(height: 25),
              const Text(
                'Preferences',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _settingsTile(
                icon: Icons.notifications_outlined,
                title: 'Notifications',
                subtitle: 'Receive order and offer updates',
                trailing: Switch(
                  value: _notificationsEnabled,
                  activeThumbColor: Colors.white,
                  activeTrackColor: Colors.black,
                  onChanged: (value) async {
                    setState(() => _notificationsEnabled = value);
                    await box.write('notifications', value);
                  },
                ),
              ),
              _settingsTile(
                icon: Icons.lock_outline,
                title: 'Change Password',
                subtitle: 'Send password reset email',
                trailing: const Icon(Icons.chevron_right, color: Colors.black),
                onTap: _sendPasswordReset,
              ),
              _settingsTile(
                icon: Icons.help_outline,
                title: 'Forgot Password',
                subtitle: 'Reset via email link',
                trailing: const Icon(Icons.chevron_right, color: Colors.black),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ForgotPasswordScreen(),
                    ),
                  );
                },
              ),
              const SizedBox(height: 10),
              const Text(
                'Account',
                style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 15),
              _settingsTile(
                icon: Icons.info_outline,
                title: 'App Version',
                subtitle: '1.0.0',
              ),
              const SizedBox(height: 10),
              SizedBox(
                width: double.infinity,
                height: 50,
                child: MaterialButton(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(35),
                  ),
                  color: Colors.black,
                  onPressed: _logout,
                  child: const Text(
                    'Logout',
                    style: TextStyle(
                      fontSize: 15.5,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
