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
  ///
  /// Retorna os dados da resposta da API
  Future<Map<String, dynamic>> createPayment({
    required int amount,
    required String cardToken,
    required String customerName,
    required String customerEmail,
    required String customerDocument,
  }) async {
    try {
      print('📡 Chamando API REST Node.js...');
      print('   🌐 Base URL: $apiBaseUrl');
      print('   📍 Endpoint: $apiBaseUrl/api/payments');
      print('   amount: $amount');
      print('   card_token: ${cardToken.length > 10 ? '${cardToken.substring(0, 10)}...' : cardToken}');
      print('   customer_name: $customerName');
      print('   customer_email: $customerEmail');
      print('   💡 Retenção: 100% na plataforma (split será feito depois)');

      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/payments'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
          'card_token': cardToken,
          'customer_name': customerName,
          'customer_email': customerEmail,
          'customer_document': customerDocument,
        }),
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

  /// Cria um recipient (recebedor) no Pagar.me
  /// 
  /// [name] - Nome do recebedor
  /// [bankAccount] - Dados da conta bancária
  Future<Map<String, dynamic>> createRecipient({
    required String name,
    required Map<String, dynamic> bankAccount,
  }) async {
    try {
      print('📡 Criando recipient na API REST...');
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/recipients'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'name': name,
          'bank_account': bankAccount,
        }),
      );

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      // Verificar se é um status de sucesso (200 OK ou 201 Created)
      final isSuccessStatus = response.statusCode >= 200 && response.statusCode < 300;

      if (!isSuccessStatus) {
        final error = responseData['error'] ?? 'Erro desconhecido';
        throw Exception('Erro ao criar recipient: $error');
      }

      print('✅ Recipient criado com sucesso!');
      return responseData;
      
    } catch (e) {
      throw Exception('Erro ao criar recipient: ${e.toString()}');
    }
  }
}

