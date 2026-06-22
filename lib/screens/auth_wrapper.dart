import 'package:addproduct/screens/login_screen.dart';
import 'package:addproduct/screens/screenlayout.dart';
import 'package:addproduct/services/auth_service.dart';
import 'package:addproduct/utils/navigation_helper.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  final _authService = AuthService();

  Widget _loadingScreen() {
    return const Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: CircularProgressIndicator(
          color: Colors.black,
          strokeWidth: 1,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return _loadingScreen();
        }

        if (snapshot.hasData) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            popToRootIfPossible();
          });

          return FutureBuilder<void>(
            future: _authService.loadUserFromFirestore(snapshot.data!.uid),
            builder: (context, syncSnapshot) {
              if (syncSnapshot.connectionState == ConnectionState.waiting) {
                return _loadingScreen();
              }
              return const MyHomePage();
            },
          );
        }

        return const LoginScreen();
      },
    );
  }
}
