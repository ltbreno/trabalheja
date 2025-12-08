// lib/core/widgets/auth_wrapper.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trabalheja/core/widgets/MainAppShell.dart';
import 'package:trabalheja/features/auth/view/login_page.dart';
import 'package:trabalheja/features/onboarding/view/onboarding_improved_page.dart';

class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Session? _currentSession;
  late final StreamSubscription<AuthState> _authSubscription;
  bool _isFirstTime = true;
  bool _isCheckingFirstTime = true; 

  @override
  void initState() {
    super.initState();
    final supabase = Supabase.instance.client;
    
    _currentSession = supabase.auth.currentSession;
    
    _checkFirstTime();
    
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _currentSession = data.session;
        });
      }
    });
  }

  Future<void> _checkFirstTime() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final hasSeenOnboarding = prefs.getBool('has_seen_onboarding') ?? false;
      
      if (mounted) {
        setState(() {
          _isFirstTime = !hasSeenOnboarding;
          _isCheckingFirstTime = false;
        });
      }
    } catch (e) {
      print('Erro ao verificar primeira vez: $e');
      if (mounted) {
        setState(() {
          _isFirstTime = false; 
          _isCheckingFirstTime = false;
        });
      }
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingFirstTime) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    final isAuthenticated = _currentSession != null;
    final authKey = ValueKey('auth-$isAuthenticated');

    if (isAuthenticated) {
      return MainAppShell(key: authKey);
    } else if (_isFirstTime) {
      return OnboardingImprovedPage(key: authKey);
    } else {
      return LoginPage(key: authKey);
    }
  }
}

