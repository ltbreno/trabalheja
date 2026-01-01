import 'package:flutter_test/flutter_test.dart';
import 'package:trabalheja/core/utils/br_validators.dart';

void main() {
  group('BrValidators.isValidCpf', () {
    test('retorna false para vazio/curto', () {
      expect(BrValidators.isValidCpf(''), isFalse);
      expect(BrValidators.isValidCpf('123'), isFalse);
    });

    test('retorna false para sequência de dígitos iguais', () {
      expect(BrValidators.isValidCpf('000.000.000-00'), isFalse);
      expect(BrValidators.isValidCpf('11111111111'), isFalse);
    });

    test('retorna true para CPF válido (com e sem máscara)', () {
      // Exemplo válido amplamente usado em testes.
      expect(BrValidators.isValidCpf('529.982.247-25'), isTrue);
      expect(BrValidators.isValidCpf('52998224725'), isTrue);
    });

    test('retorna false para CPF com DV incorreto', () {
      expect(BrValidators.isValidCpf('529.982.247-24'), isFalse);
      expect(BrValidators.isValidCpf('52998224724'), isFalse);
    });
  });
}


