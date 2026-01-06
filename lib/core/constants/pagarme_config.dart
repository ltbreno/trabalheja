import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

/// Configurações do Pagar.me
/// 
/// ✅ SEGURO: Todas as credenciais são carregadas do arquivo .env
/// Nunca exponha secret keys diretamente no código!
class PagarmeConfig {
  /// ID da conta Pagar.me
  static String get accountId {
    final value = dotenv.env['PAGARME_ACCOUNT_ID'];
    if (value == null || value.isEmpty) {
      throw Exception(
        'PAGARME_ACCOUNT_ID não encontrada no .env. '
        'Configure o arquivo .env baseado no .env.example',
      );
    }
    return value;
  }

  /// Chave pública do Pagar.me
  /// Esta é a chave usada para gerar o card_hash no cliente
  static String get publicKey {
    final value = dotenv.env['PAGARME_PUBLIC_KEY'];
    if (value == null || value.isEmpty) {
      throw Exception(
        'PAGARME_PUBLIC_KEY não encontrada no .env. '
        'Configure o arquivo .env baseado no .env.example',
      );
    }
    return value;
  }

  /// Encryption Key / Public Key do Pagar.me
  /// Esta chave é usada no frontend para gerar card_hash (criptografia RSA)
  static String get encryptionKey {
    final value = dotenv.env['PAGARME_ENCRYPTION_KEY'];
    if (value == null || value.isEmpty) {
      // Fallback para publicKey se não estiver definida
      return publicKey;
    }
    return value;
  }

  /// Secret Key / API Key do Pagar.me para chamadas de API
  /// ⚠️ CRÍTICO: Esta chave NUNCA deve ser exposta no frontend!
  /// ⚠️ Use apenas no backend (Node.js)
  /// 
  /// No frontend Flutter, esta chave é incluída apenas para compatibilidade
  /// com código legado, mas DEVE SER REMOVIDA em produção!
  @Deprecated('Não use secret key no frontend! Mova para o backend.')
  static String get secretKey {
    final value = dotenv.env['PAGARME_SECRET_KEY'];
    if (value == null || value.isEmpty) {
      if (kDebugMode) {
        print('⚠️ PAGARME_SECRET_KEY não encontrada no .env');
      }
      return '';
    }
    return value;
  }

  /// Ambiente (test ou live)
  static String get environment {
    final value = dotenv.env['PAGARME_ENVIRONMENT'];
    if (value == null || value.isEmpty) {
      return 'test'; // Default para teste
    }
    return value;
  }

  /// Base URL da API do Pagar.me
  static String get apiBaseUrl {
    return environment == 'live'
        ? 'https://api.pagar.me/1'
        : 'https://api.pagar.me/1';
  }

  /// URL base padrão para desenvolvimento local
  /// Em produção, use a URL completa da sua API (ex: https://sua-api.vercel.app)
  static const String _defaultLocalUrl = 'http://localhost:3000';

  /// URL base da API REST Node.js (usando SDK Pagar.me)
  /// 
  /// Prioridade de configuração:
  /// 1. Variável REST_API_BASE_URL do .env
  /// 2. Override manual via setRestApiBaseUrl()
  /// 3. Detecção automática baseada na plataforma
  /// 
  /// Para produção, configure REST_API_BASE_URL no .env:
  /// - Vercel: https://sua-api.vercel.app
  /// - Railway: https://sua-api.railway.app
  /// - Render: https://sua-api.onrender.com
  static String get restApiBaseUrl {
    // 1. Tentar carregar do .env primeiro
    final envUrl = dotenv.env['REST_API_BASE_URL'];
    if (envUrl != null && envUrl.isNotEmpty) {
      return envUrl;
    }

    // 2. Se há override manual, usar ele
    if (_restApiBaseUrlOverride != null && _restApiBaseUrlOverride!.isNotEmpty) {
      return _restApiBaseUrlOverride!;
    }

    // 3. Detecção automática baseada na plataforma (fallback)
    if (kIsWeb) {
      return _defaultLocalUrl;
    }

    try {
      if (Platform.isAndroid) {
        // Android Emulator usa 10.0.2.2 para acessar localhost da máquina host
        return 'http://10.0.2.2:3000';
      } else if (Platform.isIOS) {
        // iOS Simulator pode usar localhost
        return _defaultLocalUrl;
      }
    } catch (e) {
      if (kDebugMode) {
        print('⚠️ Não foi possível detectar a plataforma: $e');
      }
      return _defaultLocalUrl;
    }

    return _defaultLocalUrl;
  }

  /// Override da URL base (para produção ou configuração manual)
  /// Configure este valor se quiser usar uma URL específica
  /// Ex: 'https://sua-api.vercel.app'
  /// 
  /// ⚠️ Preferível: Configure REST_API_BASE_URL no .env ao invés de usar este método
  static String? _restApiBaseUrlOverride;

  /// Configura a URL base da API REST manualmente
  /// Use este método para definir a URL de produção ou um IP específico
  /// Exemplo para dispositivo físico Android:
  ///   PagarmeConfig.setRestApiBaseUrl('http://192.168.1.100:3000');
  /// 
  /// ⚠️ Preferível: Configure REST_API_BASE_URL no .env ao invés de usar este método
  static void setRestApiBaseUrl(String url) {
    _restApiBaseUrlOverride = url;
  }
  
  /// Se deve usar API REST Node.js (true) ou Edge Functions Supabase (false)
  /// Pode ser configurado via .env (USE_REST_API=true/false)
  static bool get useRestApi {
    final value = dotenv.env['USE_REST_API'];
    if (value == null || value.isEmpty) {
      return true; // Default: usar REST API
    }
    return value.toLowerCase() == 'true';
  }
}

