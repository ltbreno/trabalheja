import 'dart:io';
import 'package:flutter/foundation.dart';

/// Configurações do Pagar.me
/// 
/// ATENÇÃO: Em produção, considere usar variáveis de ambiente
/// ou um arquivo de configuração externo para maior segurança.
class PagarmeConfig {
  /// ID da conta Pagar.me
  /// Usado como recipient_id nas transações
  static const String accountId = 'acc_BlZedrRszpsM5g4W';

  /// Chave pública do Pagar.me (teste)
  /// Esta é a chave usada para gerar o card_hash no cliente
  static const String publicKey = 'pk_test_4Rqd0p3Fp6Ca71D8';

  /// Encryption Key / Public Key do Pagar.me
  /// Esta chave é usada no frontend para gerar card_hash (criptografia RSA)
  static const String encryptionKey = 'pk_test_4Rqd0p3Fp6Ca71D8';

  /// Secret Key / API Key do Pagar.me para chamadas de API
  /// Esta chave é usada para criar tokens e processar pagamentos
  /// IMPORTANTE: Esta chave é secreta e deve ser mantida segura
  static const String secretKey = 'sk_test_3ac0b0a451164a0a99571febe37dc4f4';

  /// Ambiente (test ou live)
  static const String environment = 'test';

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
  /// Detecta automaticamente a plataforma e ajusta a URL:
  /// - Android Emulator: usa 10.0.2.2 (alias para localhost da máquina host)
  /// - iOS Simulator: usa localhost
  /// - Web: usa localhost
  /// - Dispositivos físicos: precisa configurar o IP manualmente
  /// 
  /// Para produção, configure uma URL completa:
  /// - Vercel: 'https://sua-api.vercel.app'
  /// - Railway: 'https://sua-api.railway.app'
  /// - Render: 'https://sua-api.onrender.com'
  static String get restApiBaseUrl {
    // Se já está configurada uma URL de produção, usar ela
    if (_restApiBaseUrlOverride != null && _restApiBaseUrlOverride!.isNotEmpty) {
      return _restApiBaseUrlOverride!;
    }

    // Em web, usar localhost
    if (kIsWeb) {
      return _defaultLocalUrl;
    }

    // Detectar plataforma nativa
    try {
      if (Platform.isAndroid) {
        // Android Emulator usa 10.0.2.2 para acessar localhost da máquina host
        // Para dispositivos físicos Android, você precisa descobrir o IP da sua máquina
        // Ex: se seu IP é 192.168.1.100, use: http://192.168.1.100:3000
        return 'http://10.0.2.2:3000';
      } else if (Platform.isIOS) {
        // iOS Simulator pode usar localhost
        // Para dispositivos físicos iOS, você precisa descobrir o IP da sua máquina
        return _defaultLocalUrl;
      }
    } catch (e) {
      // Se não conseguir detectar, usar localhost por padrão
      print('⚠️ Não foi possível detectar a plataforma: $e');
      return _defaultLocalUrl;
    }

    return _defaultLocalUrl;
  }

  /// Override da URL base (para produção ou configuração manual)
  /// Configure este valor se quiser usar uma URL específica
  /// Ex: 'https://sua-api.vercel.app'
  static String? _restApiBaseUrlOverride;

  /// Configura a URL base da API REST manualmente
  /// Use este método para definir a URL de produção ou um IP específico
  /// Exemplo para dispositivo físico Android:
  ///   PagarmeConfig.setRestApiBaseUrl('http://192.168.1.100:3000');
  static void setRestApiBaseUrl(String url) {
    _restApiBaseUrlOverride = url;
  }
  
  /// Se deve usar API REST Node.js (true) ou Edge Functions Supabase (false)
  static const bool useRestApi = true; // Mude para true após configurar a API Node.js
}

