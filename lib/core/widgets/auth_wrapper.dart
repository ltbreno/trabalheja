// lib/core/widgets/auth_wrapper.dart
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/widgets/MainAppShell.dart';
import 'package:trabalheja/core/auth/auth_state_notifier.dart';
import 'package:trabalheja/features/auth/view/login_page.dart';

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

  @override
  void initState() {
    super.initState();
    final supabase = Supabase.instance.client;
    
    // Verificar sessão inicial
    _lastKnownSession = supabase.auth.currentSession;
    
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
    
    // Usar currentSession diretamente (sempre o mais atualizado)
    // Usar _lastKnownSession apenas para a Key, mas currentSession para a decisão
    final isAuthenticated = currentSession != null;
    
    // Criar uma Key baseada na sessão para forçar rebuild quando mudar
    // Usar currentSession para garantir que a Key mude quando a sessão mudar
    final sessionId = currentSession?.accessToken ?? 'no-session';
    final authKey = ValueKey('auth-$sessionId');

    // Se autenticado, mostrar MainAppShell
    // Se não autenticado, mostrar LoginPage
    // IMPORTANTE: Usar currentSession para a decisão, não _lastKnownSession
    if (isAuthenticated) {
      return MainAppShell(key: authKey);
    } else {
      return LoginPage(key: authKey);
    }
  }
}

