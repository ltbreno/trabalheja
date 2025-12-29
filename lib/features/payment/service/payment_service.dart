import 'dart:convert';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/pagarme_config.dart';
import 'package:trabalheja/features/payment/service/payment_service_rest.dart';

/// Serviço para gerenciar pagamentos
/// Suporta tanto Edge Functions do Supabase quanto API REST Node.js
class PaymentService {
  final SupabaseClient _supabase = Supabase.instance.client;
  final PaymentServiceRest? _restService;
  
  PaymentService()
      : _restService = PagarmeConfig.useRestApi
            ? PaymentServiceRest() // Usa PagarmeConfig.restApiBaseUrl automaticamente
            : null;

  /// Cria um pagamento
  ///
  /// PASSO 1: Cliente paga → Plataforma retém 100% do valor
  ///
  /// [amount] - Valor em centavos (ex: 10000 = R$ 100,00)
  /// [cardToken] - Token do cartão gerado pelo Pagar.me
  /// [customerName] - Nome do cliente
  /// [customerEmail] - Email do cliente
  /// [customerDocument] - CPF do cliente
  /// [proposalId] - ID da proposta aceita (opcional)
  ///
  /// Retorna os dados da resposta
  ///
  /// Usa API REST Node.js se `PagarmeConfig.useRestApi = true`
  /// Caso contrário, usa Edge Functions do Supabase
  Future<Map<String, dynamic>> createPayment({
    required int amount,
    String? cardToken,
    String? cardId,
    required String customerName,
    required String customerEmail,
    required String customerDocument,
    String? proposalId,
  }) async {
    // Se usar API REST Node.js (recomendado)
    if (PagarmeConfig.useRestApi) {
      if (_restService == null) {
        throw Exception('API REST não configurada. Verifique PagarmeConfig.restApiBaseUrl');
      }
      print('📡 Usando API REST Node.js (SDK Pagar.me)...');
      return await _restService.createPayment(
        amount: amount,
        cardToken: cardToken,
        cardId: cardId,
        customerName: customerName,
        customerEmail: customerEmail,
        customerDocument: customerDocument,
        proposalId: proposalId,
      );
    }

    // Caso contrário, usar Edge Function do Supabase (legado)
    try {
      print('📡 Chamando Edge Function create-payment...');
      print('   amount: $amount');
      print('   card_token: ${cardToken != null ? (cardToken.length > 10 ? '${cardToken.substring(0, 10)}...' : cardToken) : "null"}');
      print('   customer_name: $customerName');
      print('   customer_email: $customerEmail');
      print('   💡 Retenção: 100% na plataforma (split será feito depois)');
      print('   ⚠️ Para usar API REST Node.js, configure PagarmeConfig.useRestApi = true');

      final response = await _supabase.functions.invoke(
        'create-payment',
        body: {
          'amount': amount,
          'card_token': cardToken,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_document': customerDocument,
          // Não precisa mais enviar recipient_id - Edge Function usa o da plataforma
        },
      );

      print('📡 Resposta recebida da Edge Function');
      print('   Tipo de response.data: ${response.data.runtimeType}');
      print('   response.data: ${response.data}');

      // Retorna os dados da resposta
      if (response.data != null) {
        Map<String, dynamic> responseMap;
        
        // Se response.data já é um Map, usar diretamente
        if (response.data is Map<String, dynamic>) {
          responseMap = response.data as Map<String, dynamic>;
        }
        // Se response.data é uma String, fazer parse JSON
        else if (response.data is String) {
          try {
            final decoded = json.decode(response.data as String);
            if (decoded is Map<String, dynamic>) {
              responseMap = decoded;
            } else {
              throw Exception('Resposta JSON não é um Map: ${decoded.runtimeType}');
            }
          } catch (e) {
            throw Exception('Erro ao fazer parse JSON da resposta: $e');
          }
        } else {
          throw Exception(
            'Tipo de resposta não suportado: ${response.data.runtimeType}. '
            'Esperado: Map<String, dynamic> ou String (JSON)'
          );
        }
        
        // Verificar se a resposta contém erros
        if (responseMap.containsKey('message') && 
            responseMap['message'] != null &&
            responseMap['message'].toString().toLowerCase().contains('error')) {
          final errorMessage = responseMap['message'] as String;
          print('❌ Erro na resposta da Edge Function: $errorMessage');
          throw Exception('Erro ao processar pagamento: $errorMessage');
        }
        
        // Verificar outros campos que podem indicar erro
        if (responseMap.containsKey('error')) {
          final error = responseMap['error'];
          print('❌ Erro na resposta da Edge Function: $error');
          throw Exception('Erro ao processar pagamento: ${error.toString()}');
        }
        
        if (responseMap.containsKey('errors')) {
          final errors = responseMap['errors'];
          print('❌ Erros na resposta da Edge Function: $errors');
          
          // Verificar se é erro de card_hash inválido (chave expirada)
          if (errors is List) {
            for (final error in errors) {
              if (error is Map && error['parameter_name'] == 'card_hash') {
                final message = error['message']?.toString() ?? '';
                final messageLower = message.toLowerCase();
                if (messageLower.contains('chave') || messageLower.contains('encriptado') || messageLower.contains('inválido')) {
                  print('🚫 Erro de card_hash inválido/expirado');
                  throw Exception('Card hash inválido ou expirado: $message. Gere um novo hash imediatamente antes do pagamento.');
                }
              }
            }
          }
          
          throw Exception('Erro ao processar pagamento: ${errors.toString()}');
        }
        
        // Verificar se há mensagem de autorização negada especificamente
        if (responseMap.containsKey('message') && 
            responseMap['message'] != null) {
          final message = responseMap['message'] as String;
          if (message.toLowerCase().contains('authorization') || 
              message.toLowerCase().contains('denied') ||
              message.toLowerCase().contains('unauthorized')) {
            print('❌ Erro de autorização na resposta: $message');
            throw Exception('Erro de autorização: $message. Verifique as credenciais do Pagar.me na Edge Function.');
          }
        }
        
        // Se chegou aqui, a resposta parece válida
        print('✅ Resposta válida da Edge Function');
        return responseMap;
      } else {
        throw Exception('Resposta vazia da função de pagamento');
      }
    } on FunctionException catch (e) {
      // Erro específico da Edge Function
      throw Exception('Erro na função de pagamento: ${e.toString()}');
    } catch (e) {
      // Outros erros
      throw Exception('Erro ao criar pagamento: ${e.toString()}');
    }
  }

  /// Cria um pagamento PIX
  ///
  /// [amount] - Valor em centavos (ex: 10000 = R$ 100,00)
  /// [customerName] - Nome do cliente
  /// [customerEmail] - Email do cliente
  /// [customerDocument] - CPF do cliente
  /// [customerPhone] - Telefone do cliente (DDD + número)
  /// [description] - Descrição do pagamento
  /// [proposalId] - ID da proposta aceita (opcional)
  ///
  /// Retorna os dados da resposta incluindo QR Code
  Future<Map<String, dynamic>> createPixPayment({
    required int amount,
    required String customerName,
    required String customerEmail,
    required String customerDocument,
    required Map<String, String> customerPhone,
    String? description,
    String? proposalId,
  }) async {
    if (PagarmeConfig.useRestApi) {
      if (_restService == null) {
        throw Exception('API REST não configurada. Verifique PagarmeConfig.restApiBaseUrl');
      }
      print('📡 Usando API REST Node.js para PIX...');
      return await _restService.createPixPayment(
        amount: amount,
        customerName: customerName,
        customerEmail: customerEmail,
        customerDocument: customerDocument,
        customerPhone: customerPhone,
        description: description,
        proposalId: proposalId,
      );
    }

    throw Exception('PIX só é suportado via API REST Node.js. Configure PagarmeConfig.useRestApi = true');
  }

  /// Verifica o status de um pagamento PIX
  ///
  /// [orderId] - ID do pedido no Pagar.me
  ///
  /// Retorna os dados atualizados do pagamento
  Future<Map<String, dynamic>> checkPixPaymentStatus({
    required String orderId,
  }) async {
    if (PagarmeConfig.useRestApi) {
      if (_restService == null) {
        throw Exception('API REST não configurada. Verifique PagarmeConfig.restApiBaseUrl');
      }
      return await _restService.checkPixPaymentStatus(orderId: orderId);
    }

    throw Exception('Verificação de status PIX só é suportada via API REST Node.js');
  }

  /// Cria um customer (cliente) no Pagar.me
  ///
  /// [name] - Nome completo do cliente
  /// [email] - Email do cliente
  /// [document] - CPF/CNPJ do cliente
  /// [type] - Tipo: 'individual' ou 'company'
  /// [code] - ID do usuário no sistema (opcional)
  /// [gender] - Gênero (opcional)
  /// [birthdate] - Data de nascimento DD/MM/AAAA (opcional)
  /// [address] - Dados de endereço (opcional)
  /// [mobilePhone] - Telefone celular (DDD + número) (opcional)
  /// [metadata] - Metadados adicionais (opcional)
  Future<Map<String, dynamic>> createCustomer({
    required String name,
    required String email,
    required String document,
    String type = 'individual',
    String? code,
    String? gender,
    String? birthdate,
    Map<String, String>? address,
    Map<String, String>? mobilePhone,
    Map<String, dynamic>? metadata,
  }) async {
    if (PagarmeConfig.useRestApi) {
      if (_restService == null) {
        throw Exception('API REST não configurada. Verifique PagarmeConfig.restApiBaseUrl');
      }
      return await _restService.createCustomer(
        name: name,
        email: email,
        document: document,
        type: type,
        code: code,
        gender: gender,
        birthdate: birthdate,
        address: address,
        mobilePhone: mobilePhone,
        metadata: metadata,
      );
    }

    throw Exception('Criação de customer só é suportada via API REST Node.js');
  }

  /// Cria um recipient (recebedor) no Pagar.me
  ///
  /// [name] - Nome do recebedor
  /// [email] - Email do recebedor
  /// [document] - CPF/CNPJ do recebedor
  /// [bankAccount] - Dados da conta bancária
  ///
  /// Retorna os dados do recipient criado incluindo o ID
  Future<Map<String, dynamic>> createRecipient({
    required String name,
    required String email,
    required String document,
    required Map<String, dynamic> bankAccount,
  }) async {
    if (PagarmeConfig.useRestApi) {
      if (_restService == null) {
        throw Exception('API REST não configurada. Verifique PagarmeConfig.restApiBaseUrl');
      }
      return await _restService.createRecipient(
        name: name,
        email: email,
        document: document,
        bankAccount: bankAccount,
      );
    }

    throw Exception('Criação de recipient só é suportada via API REST Node.js');
  }

  /// Cria uma transferência para um recipient
  ///
  /// Usado quando o serviço é finalizado para liberar o pagamento ao freelancer
  ///
  /// [recipientId] - ID do recipient no Pagar.me
  /// [amount] - Valor em centavos a ser transferido
  /// [orderId] - ID do pedido de origem
  ///
  /// Retorna os dados da transferência criada
  Future<Map<String, dynamic>> createTransfer({
    required String recipientId,
    required int amount,
    required String orderId,
  }) async {
    if (PagarmeConfig.useRestApi) {
      if (_restService == null) {
        throw Exception('API REST não configurada. Verifique PagarmeConfig.restApiBaseUrl');
      }
      return await _restService.createTransfer(
        recipientId: recipientId,
        amount: amount,
        orderId: orderId,
      );
    }

    throw Exception('Criação de transferência só é suportada via API REST Node.js');
  }
  /// Cria um cartão para um cliente
  ///
  /// [customerPagarmeId] - ID do cliente no Pagar.me
  /// [cardData] - Pode ser o token (String) ou mapa com dados brutos do cartão
  /// [billingAddress] - Endereço de cobrança (opcional)
  ///
  /// Retorna os dados do cartão criado
  Future<Map<String, dynamic>> createCard({
    required String customerPagarmeId,
    required dynamic cardData,
  }) async {
    if (PagarmeConfig.useRestApi) {
      if (_restService == null) {
        throw Exception('API REST não configurada. Verifique PagarmeConfig.restApiBaseUrl');
      }
      return await _restService.createCard(
        customerPagarmeId: customerPagarmeId,
        cardData: cardData,
      );
    }

    throw Exception('Criação de cartão só é suportada via API REST Node.js');
  }
  /// Lista os cartões de um cliente
  ///
  /// [customerPagarmeId] - ID do cliente no Pagar.me
  ///
  /// Retorna lista de cartões
  Future<List<Map<String, dynamic>>> listCards({
    required String customerPagarmeId,
  }) async {
    if (PagarmeConfig.useRestApi) {
      if (_restService == null) {
        throw Exception('API REST não configurada. Verifique PagarmeConfig.restApiBaseUrl');
      }
      return await _restService.listCards(
        customerPagarmeId: customerPagarmeId,
      );
    }

    throw Exception('Listagem de cartões só é suportada via API REST Node.js');
  }
}

