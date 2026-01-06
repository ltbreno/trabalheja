import 'dart:convert';
import 'dart:typed_data';
import 'package:http/http.dart' as http;
import 'package:pointycastle/export.dart';
import 'package:basic_utils/basic_utils.dart';
import 'package:trabalheja/core/constants/pagarme_config.dart';

/// Modelo para resposta da API de card-hash-key
class CardHashKeyResponse {
  final bool success;
  final CardHashKey? cardHashKey;

  CardHashKeyResponse({
    required this.success,
    this.cardHashKey,
  });

  factory CardHashKeyResponse.fromJson(Map<String, dynamic> json) {
    return CardHashKeyResponse(
      success: json['success'] ?? false,
      cardHashKey: json['card_hash_key'] != null
          ? CardHashKey.fromJson(json['card_hash_key'] as Map<String, dynamic>)
          : null,
    );
  }
}

/// Modelo para os dados da chave de card-hash
class CardHashKey {
  final String id;
  final String publicKey;
  final String? createdAt;
  final String? expiresAt;

  CardHashKey({
    required this.id,
    required this.publicKey,
    this.createdAt,
    this.expiresAt,
  });

  factory CardHashKey.fromJson(Map<String, dynamic> json) {
    return CardHashKey(
      id: json['id'] as String,
      publicKey: json['public_key'] as String,
      createdAt: json['created_at'] as String?,
      expiresAt: json['expires_at'] as String?,
    );
  }
}

/// Serviço para gerar card_hash do Pagar.me
class PagarmeService {
  final String encryptionKey;
  final String secretKey;
  final String? backendApiBaseUrl;

  /// Construtor padrão usando as chaves da configuração
  /// [encryptionKey] - Chave de encriptação do Pagar.me (public key para card_hash)
  /// [secretKey] - Chave secreta do Pagar.me (para chamadas de API)
  /// [backendApiBaseUrl] - URL base da API Node.js (usa PagarmeConfig.restApiBaseUrl se não fornecido)
  PagarmeService({
    String? encryptionKey,
    String? secretKey,
    String? backendApiBaseUrl,
  })  : encryptionKey = encryptionKey ?? PagarmeConfig.encryptionKey,
        secretKey = secretKey ?? PagarmeConfig.secretKey,
        backendApiBaseUrl = backendApiBaseUrl ?? PagarmeConfig.restApiBaseUrl;

  /// Obtém a chave pública RSA do backend Node.js
  /// 
  /// Faz uma requisição GET para /api/card-hash/key e retorna a chave pública
  /// 
  /// Retorna um CardHashKeyResponse com os dados da chave
  /// Lança exceção em caso de erro de conexão, timeout ou resposta inválida
  Future<CardHashKey> getCardHashKeyFromBackend() async {
    try {
      final baseUrl = backendApiBaseUrl ?? PagarmeConfig.restApiBaseUrl;
      final url = Uri.parse('$baseUrl/api/card-hash/key');

      print('🔑 Buscando chave pública RSA do backend...');
      print('   URL: $url');

      final response = await http.get(
        url,
        headers: {
          'Content-Type': 'application/json',
        },
      ).timeout(
        const Duration(seconds: 10),
        onTimeout: () {
          throw Exception('Timeout ao buscar chave pública do backend (10s)');
        },
      );

      print('📡 Resposta recebida do backend');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode != 200) {
        final errorBody = response.body.isNotEmpty
            ? json.decode(response.body)
            : {'error': 'Resposta vazia'};
        throw Exception(
          'Erro ao buscar chave pública: ${response.statusCode} - $errorBody'
        );
      }

      final responseData = json.decode(response.body) as Map<String, dynamic>;
      final cardHashKeyResponse = CardHashKeyResponse.fromJson(responseData);

      if (!cardHashKeyResponse.success) {
        throw Exception(
          'Backend retornou success=false ao buscar chave pública'
        );
      }

      if (cardHashKeyResponse.cardHashKey == null) {
        throw Exception(
          'Backend não retornou card_hash_key na resposta'
        );
      }

      final cardHashKey = cardHashKeyResponse.cardHashKey!;

      if (cardHashKey.publicKey.isEmpty) {
        throw Exception('Chave pública retornada está vazia');
      }

      print('✅ Chave pública obtida do backend com sucesso');
      print('   Key ID: ${cardHashKey.id}');
      print('   Public Key length: ${cardHashKey.publicKey.length} caracteres');

      return cardHashKey;
    } on http.ClientException catch (e) {
      print('❌ Erro de conexão ao buscar chave do backend: $e');
      throw Exception(
        'Erro de conexão com o backend. Verifique se a API Node.js está rodando em $backendApiBaseUrl'
      );
    } catch (e) {
      print('❌ Erro ao buscar chave do backend: $e');
      rethrow;
    }
  }

  /// Gera o card_hash a partir dos dados do cartão
  /// 
  /// [cardNumber] - Número do cartão (apenas dígitos)
  /// [cardHolderName] - Nome do portador do cartão
  /// [cardExpirationDate] - Data de expiração no formato MMYY (ex: "1225")
  /// [cardCvv] - Código de segurança (CVV)
  /// [useBackendKey] - Se true, busca a chave do backend Node.js primeiro (padrão: true)
  /// 
  /// Retorna o card_hash gerado
  /// 
  /// Se useBackendKey=true, busca a chave do backend primeiro.
  /// Se falhar ou useBackendKey=false, tenta obter diretamente do Pagar.me (fallback)
  Future<String> generateCardHash({
    required String cardNumber,
    required String cardHolderName,
    required String cardExpirationDate,
    required String cardCvv,
    bool useBackendKey = true,
  }) async {
    try {
      // Limpar formatação
      final cleanCardNumber = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
      final cleanExpiration = cardExpirationDate.replaceAll(RegExp(r'[^0-9]'), '');
      final cleanCvv = cardCvv.replaceAll(RegExp(r'[^0-9]'), '');

      // Passo 1: Obter a chave pública RSA
      late String publicKey;
      late String keyId;
      
      // Tentar obter do backend primeiro (recomendado)
      bool keyObtained = false;
      
      if (useBackendKey) {
        try {
          print('🔑 Tentando obter chave do backend Node.js...');
          final cardHashKey = await getCardHashKeyFromBackend();
          publicKey = cardHashKey.publicKey;
          keyId = cardHashKey.id;
          keyObtained = true;
          print('✅ Chave obtida do backend com sucesso');
        } catch (e) {
          print('⚠️ Falha ao obter chave do backend: $e');
          print('🔄 Tentando obter chave diretamente do Pagar.me (fallback)...');
          // Continuar para o fallback abaixo
        }
      }

      // Fallback: Obter diretamente do Pagar.me se não conseguiu do backend
      if (!keyObtained) {
        print('🔑 Obtendo chave pública RSA diretamente do Pagar.me...');
        print('🔑 Usando encryption_key: ${encryptionKey.substring(0, 10)}...');
        
        // Tentar múltiplas abordagens devido à inconsistência na documentação
        http.Response? keyResponse;
        bool success = false;
      
        
        // Abordagem 1: GET com api_key como query parameter
        print('📡 Tentativa 1: GET com api_key no query...');
        try {
          final getUri = Uri.parse('https://api.pagar.me/1/transactions/card_hash_key')
              .replace(queryParameters: {'api_key': encryptionKey});
          keyResponse = await http.get(getUri);
          
          if (keyResponse.statusCode == 200) {
            success = true;
            print('✅ Sucesso com GET + api_key no query');
          }
        } catch (e) {
          print('⚠️ GET com query falhou: $e');
        }
        
        // Abordagem 2: GET com encryption_key como query parameter
        if (!success) {
          print('📡 Tentativa 2: GET com encryption_key no query...');
          try {
            final getUri = Uri.parse('https://api.pagar.me/1/transactions/card_hash_key')
                .replace(queryParameters: {'encryption_key': encryptionKey});
            keyResponse = await http.get(getUri);
            
            if (keyResponse.statusCode == 200) {
              success = true;
              print('✅ Sucesso com GET + encryption_key no query');
            }
          } catch (e) {
            print('⚠️ GET com encryption_key falhou: $e');
          }
        }
        
        // Abordagem 3: POST com api_key no body
        if (!success) {
          print('📡 Tentativa 3: POST com api_key no body...');
          try {
            keyResponse = await http.post(
              Uri.parse('https://api.pagar.me/1/transactions/card_hash_key'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'api_key': encryptionKey,
              }),
            );
            
            if (keyResponse.statusCode == 200) {
              success = true;
              print('✅ Sucesso com POST + api_key no body');
            }
          } catch (e) {
            print('⚠️ POST com api_key falhou: $e');
          }
        }
        
        // Abordagem 4: POST com encryption_key no body (original)
        if (!success) {
          print('📡 Tentativa 4: POST com encryption_key no body...');
          try {
            keyResponse = await http.post(
              Uri.parse('https://api.pagar.me/1/transactions/card_hash_key'),
              headers: {
                'Content-Type': 'application/json',
              },
              body: json.encode({
                'encryption_key': encryptionKey,
              }),
            );
            
            if (keyResponse.statusCode == 200) {
              success = true;
              print('✅ Sucesso com POST + encryption_key no body');
            }
          } catch (e) {
            print('⚠️ POST com encryption_key falhou: $e');
          }
        }

        if (!success || keyResponse == null || keyResponse.statusCode != 200) {
          final errorBody = keyResponse?.body ?? 'Nenhuma resposta recebida';
          final statusCode = keyResponse?.statusCode ?? 0;
          print('❌ Erro ao obter chave de hash do Pagar.me: $statusCode');
          print('   Resposta completa: $errorBody');
          print('   ⚠️ Todas as abordagens falharam. Verifique:');
          print('      1. Se a chave está correta (api_key ou encryption_key)');
          print('      2. Se está usando a versão correta da API');
          print('      3. Se a conta está ativa no Pagar.me');
          throw Exception('Erro ao obter chave de hash: $statusCode - $errorBody');
        }

        print('📡 Status da resposta da chave: ${keyResponse.statusCode}');
        print('📄 Corpo da resposta da chave: ${keyResponse.body}');

        final keyData = json.decode(keyResponse.body);
        print('✅ Dados da chave recebidos: ${keyData.toString()}');
        
        // Extrair id e public_key da resposta
        final extractedKeyId = keyData['id']?.toString();
        final extractedPublicKey = keyData['public_key'] as String?;

        if (extractedKeyId == null || extractedKeyId.isEmpty) {
          print('❌ ID da chave não encontrado na resposta: $keyData');
          throw Exception('ID da chave não encontrado na resposta. Estrutura: $keyData');
        }

        if (extractedPublicKey == null || extractedPublicKey.isEmpty) {
          print('❌ Chave pública não encontrada na resposta: $keyData');
          throw Exception('Chave pública não encontrada na resposta. Estrutura: $keyData');
        }

        // Atribuir após validação
        keyId = extractedKeyId;
        publicKey = extractedPublicKey;
        
        print('✅ Key ID obtido: $keyId');
        print('✅ Public Key obtida (${publicKey.length} caracteres)');
        keyObtained = true;
      }

      // Garantir que obtivemos a chave de algum método
      if (!keyObtained) {
        throw Exception('Não foi possível obter a chave pública RSA nem do backend nem do Pagar.me');
      }

      // Passo 2: Criar QueryString URLEncoded com os dados do cartão
      // Formato: card_number={number}&card_holder_name={name}&card_expiration_date={date}&card_cvv={cvv}
      // Nota: A documentação mostra uso de '+' para espaços na URL encoding
      print('🔐 Criando QueryString com dados do cartão...');
      
      // Codificar o nome do portador (substituir espaços por + conforme documentação)
      final cardHolderNameEncoded = cardHolderName
          .trim()
          .replaceAll(' ', '+')
          .replaceAllMapped(
            RegExp(r'[^A-Za-z0-9+.-]'),
            (match) => Uri.encodeComponent(match.group(0)!),
          );
      
      final queryString = 'card_number=$cleanCardNumber&'
          'card_holder_name=$cardHolderNameEncoded&'
          'card_expiration_date=$cleanExpiration&'
          'card_cvv=$cleanCvv';
      
      print('📝 QueryString criada: $queryString');

      // Passo 3: Criptografar QueryString usando RSA com PKCS1Padding
      print('🔒 Criptografando QueryString com RSA...');
      
      final encryptedBytes = _encryptRSA(queryString, publicKey);
      
      // Passo 4: Converter para Base64
      final base64Encrypted = base64.encode(encryptedBytes);
      
      print('✅ Dados criptografados (${base64Encrypted.length} caracteres em Base64)');

      // Passo 5: Formatar card_hash como {id}_{base64_encrypted}
      final cardHash = '${keyId}_$base64Encrypted';
      
      print('✅ Card hash gerado com sucesso! (${cardHash.length} caracteres)');
      print('📋 Formato: {id}_{encrypted_base64}');
      print('📋 Key ID usado: $keyId');
      print('📋 Primeiros 50 caracteres do hash: ${cardHash.substring(0, cardHash.length > 50 ? 50 : cardHash.length)}');
      print('⚠️ IMPORTANTE: Use este card_hash imediatamente. Chaves RSA expiram rapidamente!');
      
      return cardHash;
    } catch (e) {
      throw Exception('Erro ao gerar card_hash: ${e.toString()}');
    }
  }

  /// Criptografa uma string usando RSA com PKCS1Padding (PKCS#1 v1.5)
  /// 
  /// [data] - String a ser criptografada
  /// [publicKeyPem] - Chave pública RSA no formato PEM
  /// 
  /// Retorna os bytes criptografados
  Uint8List _encryptRSA(String data, String publicKeyPem) {
    try {
      // Parse da chave pública PEM
      final publicKey = CryptoUtils.rsaPublicKeyFromPem(publicKeyPem);
      
      // Converter string para bytes (UTF-8)
      final dataBytes = utf8.encode(data);
      
      // Criar o cifrador RSA com PKCS1Padding (PKCS#1 v1.5)
      // PKCS1Padding adiciona 11 bytes de padding
      final cipher = PKCS1Encoding(RSAEngine())
        ..init(true, PublicKeyParameter<RSAPublicKey>(publicKey));
      
      // Tamanho máximo para PKCS1 v1.5: (key_size / 8) - 11
      // Para RSA 2048 bits (256 bytes): 256 - 11 = 245 bytes
      final keySizeBytes = (publicKey.n!.bitLength + 7) ~/ 8;
      final maxDataSize = keySizeBytes - 11;
      
      if (dataBytes.length > maxDataSize) {
        throw Exception(
          'Dados muito grandes para criptografia RSA. '
          'Tamanho: ${dataBytes.length} bytes, máximo: $maxDataSize bytes'
        );
      }
      
      // Criptografar os dados
      return cipher.process(dataBytes);
    } catch (e) {
      print('❌ Erro ao criptografar com RSA: $e');
      rethrow;
    }
  }

  /// Valida o número do cartão usando algoritmo de Luhn
  static bool isValidCardNumber(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');
    if (digits.length < 13 || digits.length > 19) return false;

    int sum = 0;
    bool alternate = false;

    for (int i = digits.length - 1; i >= 0; i--) {
      int n = int.parse(digits[i]);
      if (alternate) {
        n *= 2;
        if (n > 9) n -= 9;
      }
      sum += n;
      alternate = !alternate;
    }

    return sum % 10 == 0;
  }

  /// Cria um card_token enviando os dados do cartão para o backend local
  /// seguindo exatamente a estrutura da API do Pagar.me
  ///
  /// [cardNumber] - Número do cartão (apenas números)
  /// [cardHolderName] - Nome impresso no cartão
  /// [cardExpirationDate] - Data de validade (MMYY)
  /// [cardCvv] - Código de segurança
  /// [cardHolderDocument] - CPF do titular do cartão
  ///
  /// Retorna um CardTokenResponse com o token gerado
  Future<CardTokenResponse> createCardToken({
    required String cardNumber,
    required String cardHolderName,
    required String cardExpirationDate,
    required String cardCvv,
    String? cardHolderDocument,
  }) async {
    try {
      print('🔑 Criando card_token via backend local...');
      print('   Cartão: **** **** **** ${cardNumber.substring(cardNumber.length - 4)}');

      // Dividir data de expiração em mês e ano
      final expMonth = cardExpirationDate.substring(0, 2);
      final expYear = cardExpirationDate.substring(2, 4);

      // Identificar bandeira do cartão
      final cardBrand = getCardBrand(cardNumber) ?? 'Unknown';

      // Preparar payload no formato exato da API do Pagar.me
      final requestBody = {
        'card': {
          'number': cardNumber,
          'holder_name': cardHolderName,
          'holder_document': cardHolderDocument ?? '12578693455', // CPF padrão se não fornecido
          'exp_month': expMonth,
          'exp_year': expYear,
          'cvv': cardCvv,
          'label': cardBrand,
        },
        'type': 'card',
      };

      print('📤 Payload sendo enviado:');
      print('   ${json.encode(requestBody)}');

      final response = await http.post(
        Uri.parse('https://api.pagar.me/core/v5/tokens?appId=$encryptionKey'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: json.encode(requestBody),
      ).timeout(
        const Duration(seconds: 30),
        onTimeout: () {
          throw Exception('Timeout ao criar token do cartão (30s)');
        },
      );

      print('📡 Resposta do card_token');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      if (response.statusCode != 200) {
        try {
          final errorData = json.decode(response.body);
          final errorMessage = errorData['errors']?[0]?['message'] ??
                             errorData['error'] ??
                             'Erro desconhecido ao criar token';
          throw Exception('Erro ao criar token do cartão: $errorMessage');
        } catch (parseError) {
          // Se não conseguir fazer parse do JSON, usar resposta bruta
          throw Exception('Erro ao criar token do cartão: ${response.body}');
        }
      }

      final responseData = json.decode(response.body);

      if (responseData['id'] == null) {
        throw Exception('Token do cartão não foi gerado corretamente');
      }

      print('✅ Card token criado com sucesso!');
      print('   Token ID: ${responseData['id']}');

      return CardTokenResponse(
        success: true,
        cardToken: CardToken(
          id: responseData['id'],
          brand: responseData['brand'] ?? cardBrand,
          firstDigits: responseData['first_digits'],
          lastDigits: responseData['last_digits'],
          valid: responseData['valid'] ?? true,
        ),
      );

    } on http.ClientException catch (e) {
      print('❌ Erro de conexão ao criar token: $e');
      return CardTokenResponse(
        success: false,
        error: 'Erro de conexão com o backend. Verifique se o servidor está rodando em ${PagarmeConfig.restApiBaseUrl}',
      );
    } catch (e) {
      print('❌ Erro ao criar card_token: $e');
      return CardTokenResponse(
        success: false,
        error: e.toString(),
      );
    }
  }

  /// Identifica a bandeira do cartão pelo número
  static String? getCardBrand(String cardNumber) {
    final digits = cardNumber.replaceAll(RegExp(r'[^0-9]'), '');

    if (digits.startsWith('4')) return 'Visa';
    if (digits.startsWith('5') || digits.startsWith('2')) return 'Mastercard';
    if (digits.startsWith('3')) return 'American Express';
    if (digits.startsWith('6')) return 'Discover';
    if (digits.startsWith('50')) return 'Aura';
    if (digits.startsWith('60')) return 'Hipercard';
    if (digits.startsWith('35')) return 'Elo';

    return null;
  }
}

/// Modelo para resposta da criação de card_token
class CardTokenResponse {
  final bool success;
  final CardToken? cardToken;
  final String? error;

  CardTokenResponse({
    required this.success,
    this.cardToken,
    this.error,
  });
}

/// Modelo para dados do card_token
class CardToken {
  final String id;
  final String? brand;
  final String? firstDigits;
  final String? lastDigits;
  final bool valid;

  CardToken({
    required this.id,
    this.brand,
    this.firstDigits,
    this.lastDigits,
    required this.valid,
  });
}

