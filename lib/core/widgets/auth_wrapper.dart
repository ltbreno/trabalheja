// lib/core/widgets/auth_wrapper.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:trabalheja/core/widgets/MainAppShell.dart';
import 'package:trabalheja/core/auth/auth_state_notifier.dart';
import 'package:trabalheja/features/auth/view/login_page.dart';
import 'package:trabalheja/features/onboarding/view/onboarding_improved_page.dart';

/// Widget que gerencia a navegação baseada no estado de autenticação
/// 
/// Usa verificação direta de currentSession no build combinado com
/// listeners para garantir detecção imediata de mudanças
class AuthWrapper extends StatefulWidget {
  const AuthWrapper({super.key});

  @override
  State<AuthWrapper> createState() => _AuthWrapperState();
}

class _AuthWrapperState extends State<AuthWrapper> {
  Session? _lastKnownSession;
  late final StreamSubscription<AuthState> _authSubscription;
  late final AuthStateNotifier _authNotifier;
  Timer? _checkTimer;
  bool _isFirstTime = true; // Assumir primeira vez inicialmente
  bool _isCheckingFirstTime = true; // Flag para saber se ainda está verificando

  @override
  void initState() {
    super.initState();
    final supabase = Supabase.instance.client;
    
    // Verificar sessão inicial
    _lastKnownSession = supabase.auth.currentSession;
    
    // Verificar se é a primeira vez do usuário
    _checkFirstTime();
    
    // Inicializar o notificador
    _authNotifier = AuthStateNotifier();
    _authNotifier.initialize();
    
    // Escutar mudanças de autenticação via stream oficial
    _authSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (mounted) {
        setState(() {
          _lastKnownSession = data.session;
        });
      }
    });
    
    // Escutar notificações do AuthStateNotifier
    _authNotifier.addListener(_onAuthNotified);
    
    // Verificar currentSession periodicamente para detectar mudanças imediatas
    _checkTimer = Timer.periodic(const Duration(milliseconds: 50), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      _checkAndUpdateSession();
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
          _isFirstTime = false; // Em caso de erro, não mostrar onboarding
          _isCheckingFirstTime = false;
        });
      }
    }
  }

  void _onAuthNotified() {
    if (!mounted) return;
    _checkAndUpdateSession();
  }

  void _checkAndUpdateSession() {
    final supabase = Supabase.instance.client;
    final currentSession = supabase.auth.currentSession;
    if (currentSession != _lastKnownSession) {
      if (mounted) {
        setState(() {
          _lastKnownSession = currentSession;
        });
      }
    }
  }

  @override
  void dispose() {
    _authSubscription.cancel();
    _checkTimer?.cancel();
    _authNotifier.removeListener(_onAuthNotified);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supabase = Supabase.instance.client;
    
    // SEMPRE verificar currentSession diretamente no build (fonte da verdade)
    final currentSession = supabase.auth.currentSession;
    
    // Se detectou mudança, atualizar estado e forçar rebuild
    if (currentSession != _lastKnownSession) {
      // Atualizar o estado primeiro
      _lastKnownSession = currentSession;
      
      // Forçar rebuild usando múltiplos métodos
      // 1. scheduleMicrotask (mais rápido)
      scheduleMicrotask(() {
        if (mounted) {
          setState(() {});
        }
      });
      
      // 2. addPostFrameCallback (backup)
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (mounted && supabase.auth.currentSession != _lastKnownSession) {
          setState(() {
            _lastKnownSession = supabase.auth.currentSession;
          });
        }
      });
    }
    
    // Mostrar loading enquanto verifica se é primeira vez
    if (_isCheckingFirstTime) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
    
    // Usar currentSession diretamente (sempre o mais atualizado)
    final isAuthenticated = currentSession != null;
    
    // Criar uma Key baseada na sessão para forçar rebuild quando mudar
    final sessionId = currentSession?.accessToken ?? 'no-session';
    final authKey = ValueKey('auth-$sessionId');

    // Fluxo de navegação:
    // 1. Se autenticado: MainAppShell
    // 2. Se não autenticado e primeira vez: OnboardingImprovedPage
    // 3. Se não autenticado e não é primeira vez: LoginPage
    if (isAuthenticated) {
      return MainAppShell(key: authKey);
    } else if (_isFirstTime) {
      return OnboardingImprovedPage(key: authKey);
    } else {
      return LoginPage(key: authKey);
    }
  }
}

