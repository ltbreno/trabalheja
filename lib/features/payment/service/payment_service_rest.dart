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
  /// [cardHash] - Hash do cartão gerado pelo SDK do Pagar.me
  /// 
  /// Retorna os dados da resposta da API
  Future<Map<String, dynamic>> createPayment({
    required int amount,
    required String cardHash,
  }) async {
    try {
      print('📡 Chamando API REST Node.js...');
      print('   🌐 Base URL: $apiBaseUrl');
      print('   📍 Endpoint: $apiBaseUrl/api/payments');
      print('   amount: $amount');
      print('   card_hash: ${cardHash.length > 20 ? '${cardHash.substring(0, 20)}...' : cardHash}');
      print('   💡 Retenção: 100% na plataforma (split será feito depois)');
      
      final response = await http.post(
        Uri.parse('$apiBaseUrl/api/payments'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: json.encode({
          'amount': amount,
          'card_hash': cardHash,
        }),
      );

      print('📡 Resposta recebida da API');
      print('   Status: ${response.statusCode}');
      print('   Body: ${response.body}');

      final responseData = json.decode(response.body) as Map<String, dynamic>;

      // Verificar se há erro
      if (response.statusCode != 200) {
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
        print('✅ Pagamento processado com sucesso');
        print('   Transaction ID: ${responseData['transaction']?['id']}');
        return responseData;
      }

      // Se não tem success:true, pode ser que a resposta tenha outro formato
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

      if (response.statusCode != 200) {
        final error = responseData['error'] ?? 'Erro desconhecido';
        throw Exception('Erro ao criar recipient: $error');
      }

      return responseData;
      
    } catch (e) {
      throw Exception('Erro ao criar recipient: ${e.toString()}');
    }
  }
}

