// lib/core/auth/auth_state_notifier.dart
import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Notificador global para mudanças de estado de autenticação
/// Usado para forçar atualização do AuthWrapper quando necessário
class AuthStateNotifier extends ValueNotifier<Session?> {
  static final AuthStateNotifier _instance = AuthStateNotifier._internal();
  factory AuthStateNotifier() => _instance;
  AuthStateNotifier._internal() : super(null);

  /// Força uma atualização do estado de autenticação
  /// Deve ser chamado após login/logout bem-sucedido
  void notifyAuthChange() {
    // Atualizar o valor com a sessão atual para forçar rebuild
    value = Supabase.instance.client.auth.currentSession;
  }
  
  /// Inicializa o notificador com a sessão atual
  void initialize() {
    value = Supabase.instance.client.auth.currentSession;
  }
}

