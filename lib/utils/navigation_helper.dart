import 'package:addproduct/main.dart';
import 'package:addproduct/screens/auth_wrapper.dart';
import 'package:flutter/material.dart';

void resetToAuthScreen() {
  navigatorKey.currentState?.pushAndRemoveUntil(
    MaterialPageRoute(builder: (_) => const AuthWrapper()),
    (route) => false,
  );
}

void popToRootIfPossible() {
  final navigator = navigatorKey.currentState;
  if (navigator != null && navigator.canPop()) {
    navigator.popUntil((route) => route.isFirst);
  }
}
