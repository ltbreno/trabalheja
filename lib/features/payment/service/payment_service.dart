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
  ///
  /// Retorna os dados da resposta
  ///
  /// Usa API REST Node.js se `PagarmeConfig.useRestApi = true`
  /// Caso contrário, usa Edge Functions do Supabase
  Future<Map<String, dynamic>> createPayment({
    required int amount,
    required String cardToken,
    required String customerName,
    required String customerEmail,
    required String customerDocument,
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
        customerName: customerName,
        customerEmail: customerEmail,
        customerDocument: customerDocument,
      );
    }

    // Caso contrário, usar Edge Function do Supabase (legado)
    try {
      print('📡 Chamando Edge Function create-payment...');
      print('   amount: $amount');
      print('   card_token: ${cardToken.length > 10 ? '${cardToken.substring(0, 10)}...' : cardToken}');
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
}

