import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:trabalheja/core/constants/pagarme_config.dart';

/// Serviço para gerenciar pagamentos via API REST Node.js
/// Esta é uma alternativa mais simples usando o SDK oficial do Pagar.me
class PaymentServiceRest {
  final String apiBaseUrl;

  /// Construtor padrão
  /// [apiBaseUrl] - URL base da API Node.js (ex: https://sua-api.vercel.app)
  /// Se não fornecido, usa PagarmeConfig.restApiBaseUrl que detecta automaticamente a plataforma
  PaymentServiceRest({String? apiBaseUrl})
      : apiBaseUrl = apiBaseUrl ?? PagarmeConfig.restApiBaseUrl;

  /// Cria um pagamento usando a API REST Node.js com SDK Pagar.me
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
  /// Retorna os dados da resposta da API
  Future<Map<String, dynamic>> createPayment({
    required int amount,
    String? cardToken,
    String? cardId,
    required String customerName,
    required String customerEmail,
    required String customerDocument,
    String? proposalId,
  }) async {
    try {
      print('📡 Chamando API REST Node.js...');
      print('   🌐 Base URL: $apiBaseUrl');
      print('   📍 Endpoint: $apiBaseUrl/api/payments');
      print('   amount: $amount');
      print('   card_token: ${cardToken != null ? (cardToken.length > 10 ? '${cardToken.substring(0, 10)}...' : cardToken) : "null"}');
      print('   card_id: $cardId');
      print('   customer_name: $customerName');
      print('   customer_email: $customerEmail');
      if (proposalId != null) {
        print('   📋 proposal_id: $proposalId');
      }
      print('   💡 Retenção: 100% na plataforma (split será feito depois)');

      final Map<String, dynamic> body = {
        'amount': amount,
        'customer_name': customerName,
        'customer_email': customerEmail,
        'customer_document': customerDocument,
        if (proposalId != null) 'proposal_id': proposalId,
      };

      if (cardId != null) {
        body['card_id'] = cardId;
      } else if (cardToken != null) {
        body['card_token'] = cardToken;
      } else {
        throw Exception('É necessário fornecer cardToken ou cardId');
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/payments'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      print('📡 Resposta recebida da API');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      // Verificar se é um status de sucesso (200 OK ou 201 Created)
      final isSuccessStatus = response.statusCode >= 200 && response.statusCode < 300;

      if (!isSuccessStatus) {
        final error = responseData['error'] ?? 'Erro desconhecido';
        final details = responseData['details'];
        
        print('❌ Erro na resposta da API: $error');
        if (details != null) {
          print('   Detalhes: $details');
        }
        
        throw Exception('Erro ao processar pagamento: $error');
      }

      // Verificar se é sucesso
      if (responseData.containsKey('success') && responseData['success'] == true) {
        final paymentData = responseData['data'] as Map<String, dynamic>?;
        print('✅ Pagamento processado com sucesso!');
        print('   💳 Payment ID: ${paymentData?['payment_id']}');
        print('   🏦 Pagar.me Order ID: ${paymentData?['pagarme_order_id']}');
        print('   📊 Status: ${paymentData?['status']}');
        print('   💰 Valor: R\$ ${(paymentData?['amount'] ?? 0) / 100}');
        print('   📅 Parcelas: ${paymentData?['installments']}x');
        return responseData;
      }

      // Se não tem success:true, pode ser que a resposta tenha outro formato
      print('⚠️ Resposta sem campo "success", retornando dados brutos');
      return responseData;
      
    } on http.ClientException catch (e) {
      print('❌ Erro de conexão: $e');
      throw Exception('Erro de conexão com a API. Verifique se a API está rodando.');
    } catch (e) {
      print('❌ Erro ao criar pagamento: $e');
      throw Exception('Erro ao criar pagamento: ${e.toString()}');
    }
  }

  /// Cria um pagamento PIX usando a API REST Node.js
  ///
  /// [amount] - Valor em centavos (ex: 10000 = R$ 100,00)
  /// [customerName] - Nome do cliente
  /// [customerEmail] - Email do cliente
  /// [customerDocument] - CPF do cliente
  /// [customerPhone] - Telefone do cliente (DDD + número)
  /// [description] - Descrição do pagamento
  /// [proposalId] - ID da proposta aceita (opcional)
  ///
  /// Retorna os dados da resposta da API incluindo QR Code
  Future<Map<String, dynamic>> createPixPayment({
    required int amount,
    required String customerName,
    required String customerEmail,
    required String customerDocument,
    required Map<String, String> customerPhone,
    String? description,
    String? proposalId,
  }) async {
    try {
      print('📡 Criando pagamento PIX via API REST Node.js...');
      print('   🌐 Base URL: $apiBaseUrl');
      print('   📍 Endpoint: $apiBaseUrl/api/payments/pix');
      print('   💰 Valor: R\$ ${amount / 100}');
      print('   👤 Cliente: $customerName');
      print('   📧 Email: $customerEmail');
      print('   📱 Telefone: (${customerPhone['area_code']}) ${customerPhone['number']}');
      if (proposalId != null) {
        print('   📋 Proposal ID: $proposalId');
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/payments/pix'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_document': customerDocument,
          'customer_phone': customerPhone,
          'description': description ?? 'Pagamento via PIX',
          if (proposalId != null) 'proposal_id': proposalId,
        }),
      );

      print('📡 Resposta recebida da API PIX');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      // Verificar se é um status de sucesso (200 OK ou 201 Created)
      final isSuccessStatus = response.statusCode >= 200 && response.statusCode < 300;

      if (!isSuccessStatus) {
        final error = responseData['error'] ?? 'Erro desconhecido';
        final details = responseData['details'];
        
        print('❌ Erro na resposta da API PIX: $error');
        if (details != null) {
          print('   Detalhes: $details');
        }
        
        throw Exception('Erro ao processar pagamento PIX: $error');
      }

      // Verificar se é sucesso
      if (responseData.containsKey('success') && responseData['success'] == true) {
        final pixData = responseData['data'] as Map<String, dynamic>?;
        print('✅ Pagamento PIX criado com sucesso!');
        print('   💳 Payment ID: ${pixData?['payment_id']}');
        print('   🏦 Pagar.me Order ID: ${pixData?['pagarme_order_id']}');
        print('   📊 Status: ${pixData?['status']}');
        print('   💰 Valor: R\$ ${(pixData?['amount'] ?? 0) / 100}');
        print('   🔗 QR Code gerado: ${pixData?['qr_code'] != null ? 'Sim' : 'Não'}');
        return responseData;
      }

      // Se não tem success:true, pode ser que a resposta tenha outro formato
      print('⚠️ Resposta sem campo "success", retornando dados brutos');
      return responseData;
      
    } on http.ClientException catch (e) {
      print('❌ Erro de conexão: $e');
      throw Exception('Erro de conexão com a API. Verifique se a API está rodando.');
    } catch (e) {
      print('❌ Erro ao criar pagamento PIX: $e');
      throw Exception('Erro ao criar pagamento PIX: ${e.toString()}');
    }
  }

  /// Verifica o status de um pagamento PIX
  ///
  /// [orderId] - ID do pedido no Pagar.me
  ///
  /// Retorna os dados atualizados do pagamento
  Future<Map<String, dynamic>> checkPixPaymentStatus({
    required String orderId,
  }) async {
    try {
      print('🔍 Verificando status do pagamento PIX...');
      print('   Order ID: $orderId');

      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/payments/status/$orderId'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      final isSuccessStatus = response.statusCode >= 200 && response.statusCode < 300;

      if (!isSuccessStatus) {
        final error = responseData['error'] ?? 'Erro desconhecido';
        throw Exception('Erro ao verificar status: $error');
      }

      return responseData;
      
    } catch (e) {
      print('❌ Erro ao verificar status do pagamento: $e');
      throw Exception('Erro ao verificar status: ${e.toString()}');
    }
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
    try {
      print('📡 Criando customer na API REST...');
      print('   👤 Nome: $name');
      print('   📧 Email: $email');
      print('   📄 Documento: ${document.substring(0, 3)}***');
      
      final Map<String, dynamic> body = {
        'name': name,
        'email': email,
        'document': document,
        'type': type,
        'document_type': document.length > 11 ? 'CNPJ' : 'CPF',
      };

      if (code != null) body['code'] = code;
      if (gender != null) body['gender'] = gender;
      if (birthdate != null) body['birthdate'] = birthdate;
      
      if (address != null) {
        body['address'] = address;
      }

      if (mobilePhone != null) {
        body['phones'] = {
          'mobile_phone': mobilePhone,
        };
      }

      if (metadata != null) {
        body['metadata'] = metadata;
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/customers'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      // Verificar se é um status de sucesso (200 OK ou 201 Created)
      final isSuccessStatus = response.statusCode >= 200 && response.statusCode < 300;

      if (!isSuccessStatus) {
        final error = responseData['error'] ?? responseData['message'] ?? 'Erro desconhecido';
        print('❌ Erro ao criar customer: $error');
        throw Exception('Erro ao criar customer: $error');
      }

      print('✅ Customer criado com sucesso!');
      print('   🆔 ID: ${responseData['data']?['pagarme_customer_id'] ?? responseData['id']}');
      return responseData;
      
    } catch (e) {
      print('❌ Erro ao criar customer: $e');
      throw Exception('Erro ao criar customer: ${e.toString()}');
    }
  }

  /// Cria uma transferência para um recipient
  /// Usado quando o serviço é finalizado para liberar o pagamento ao freelancer
  /// 
  /// [recipientId] - ID do recipient no Pagar.me
  /// [amount] - Valor em centavos a ser transferido
  /// [orderId] - ID do pedido de origem
  Future<Map<String, dynamic>> createTransfer({
    required String recipientId,
    required int amount,
    required String orderId,
  }) async {
    try {
      print('📡 Criando transferência na API REST...');
      print('   🆔 Recipient ID: $recipientId');
      print('   💰 Valor: R\$ ${amount / 100}');
      print('   📦 Order ID: $orderId');
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/transfers'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'recipient_id': recipientId,
          'amount': amount,
          'order_id': orderId,
        }),
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      // Verificar se é um status de sucesso (200 OK ou 201 Created)
      final isSuccessStatus = response.statusCode >= 200 && response.statusCode < 300;

      if (!isSuccessStatus) {
        final error = responseData['error'] ?? responseData['message'] ?? 'Erro desconhecido';
        print('❌ Erro ao criar transferência: $error');
        throw Exception('Erro ao criar transferência: $error');
      }

      print('✅ Transferência criada com sucesso!');
      print('   🆔 Transfer ID: ${responseData['data']?['transfer_id'] ?? responseData['id']}');
      return responseData;
      
    } catch (e) {
      print('❌ Erro ao criar transferência: $e');
      throw Exception('Erro ao criar transferência: ${e.toString()}');
    }
  }
  /// Cria um cartão para um cliente usando a API REST Node.js
  ///
  /// [customerPagarmeId] - ID do cliente no Pagar.me
  /// [cardData] - Token (String) ou Map com dados brutos
  Future<Map<String, dynamic>> createCard({
    required String customerPagarmeId,
    required dynamic cardData,
  }) async {
    try {
      print('📡 Criando cartão na API REST...');
      print('   👤 Customer Pagar.me ID: $customerPagarmeId');
      
      final Map<String, dynamic> body = {
        'customer_id': customerPagarmeId,
      };

      if (cardData is String) {   
        print('   💳 Usando Card Token: ${cardData.substring(0, 10)}...');
        body['card_token'] = cardData;
      } else if (cardData is Map) {
        print('   💳 Usando Dados Brutos do Cartão');
        body.addAll(cardData as Map<String, dynamic>);
        print('   📦 Payload do cartão sendo enviado: ${json.encode(body)}');
      } else {
        throw Exception('Dados do cartão inválidos (esperado String ou Map)');
      }

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/cards'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode(body),
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      // Verificar se é um status de sucesso (200 OK ou 201 Created)
      final isSuccessStatus = response.statusCode >= 200 && response.statusCode < 300;

      if (!isSuccessStatus) {
        final error = responseData['error'] ?? responseData['message'] ?? 'Erro desconhecido';
        print('❌ Erro ao criar cartão: $error');
        throw Exception('Erro ao criar cartão: $error');
      }

      print('✅ Cartão criado com sucesso!');
      print('   🆔 Card ID: ${responseData['data']?['pagarme_card_id'] ?? responseData['id']}');
      return responseData;
      
    } catch (e) {
      print('❌ Erro ao criar cartão: $e');
      throw Exception('Erro ao criar cartão: ${e.toString()}');
    }
  }
  /// Lista os cartões salvos de um cliente
  ///
  /// [customerPagarmeId] - ID do cliente no Pagar.me
  ///
  /// Retorna uma lista de mapas com os dados dos cartões
  Future<List<Map<String, dynamic>>> listCards({
    required String customerPagarmeId,
  }) async {
    try {
      print('📡 Buscando cartões na API REST...');
      print('   👤 Customer ID: $customerPagarmeId');
      
      final response = await http.get(
        Uri.parse('$apiBaseUrl/api/customers/$customerPagarmeId/cards'),
        headers: {
          'Content-Type': 'application/json',
        },
      );

      print('📡 Resposta recebida da API (listCards)');
      print('   Status: ${response.statusCode}');

      final responseBody = json.decode(response.body);

      // Se a resposta for uma lista direta (arranjado pelo backend)
      if (responseBody is List) {
        return List<Map<String, dynamic>>.from(responseBody);
      }
      
      // Se a resposta for um objeto com campo 'data' (padrao API Pagar.me)
      if (responseBody is Map && responseBody.containsKey('data')) {
        final data = responseBody['data'];
        if (data is List) {
          return List<Map<String, dynamic>>.from(data);
        }
      }

      // Se der erro ou formato desconhecido
      if (response.statusCode >= 400) {
        final error = responseBody['error'] ?? responseBody['message'] ?? 'Erro desconhecido';
        print('❌ Erro ao listar cartões: $error');
        throw Exception('Erro ao listar cartões: $error');
      }

      print('⚠️ Formato de resposta inesperado ao listar cartões. Retornando lista vazia.');
      return [];

    } catch (e) {
      print('❌ Erro ao listar cartões: $e');
      throw Exception('Erro ao listar cartões: ${e.toString()}');
    }
  }
}

