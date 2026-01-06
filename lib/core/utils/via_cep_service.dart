import 'dart:convert';

import 'package:http/http.dart' as http;

class ViaCepAddress {
  final String cep;
  final String logradouro;
  final String bairro;
  final String localidade;
  final String uf;

  const ViaCepAddress({
    required this.cep,
    required this.logradouro,
    required this.bairro,
    required this.localidade,
    required this.uf,
  });

  factory ViaCepAddress.fromJson(Map<String, dynamic> json) {
    return ViaCepAddress(
      cep: (json['cep'] ?? '').toString(),
      logradouro: (json['logradouro'] ?? '').toString(),
      bairro: (json['bairro'] ?? '').toString(),
      localidade: (json['localidade'] ?? '').toString(),
      uf: (json['uf'] ?? '').toString(),
    );
  }
}

class ViaCepService {
  ViaCepService._();

  /// Busca endereço no ViaCEP.
  ///
  /// Retorna `null` quando:
  /// - CEP é inválido (não tem 8 dígitos)
  /// - ViaCEP responde com `{"erro": true}`
  static Future<ViaCepAddress?> fetchAddress(String cepDigits) async {
    final normalized = cepDigits.replaceAll(RegExp(r'[^0-9]'), '');
    if (normalized.length != 8) return null;

    final uri = Uri.parse('https://viacep.com.br/ws/$normalized/json/');
    final response = await http.get(uri, headers: {
      'Accept': 'application/json',
    });

    if (response.statusCode < 200 || response.statusCode >= 300) {
      throw Exception('ViaCEP retornou status ${response.statusCode}');
    }

    final decoded = json.decode(response.body);
    if (decoded is! Map<String, dynamic>) {
      throw Exception('Resposta inválida do ViaCEP');
    }

    if (decoded['erro'] == true) return null;
    return ViaCepAddress.fromJson(decoded);
  }
}


