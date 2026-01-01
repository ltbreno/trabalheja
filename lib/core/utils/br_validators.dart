/// Validadores e normalizadores para dados brasileiros (CPF, etc.).
class BrValidators {
  BrValidators._();

  /// Retorna apenas dígitos (0-9) de uma string.
  static String onlyDigits(String input) {
    return input.replaceAll(RegExp(r'[^0-9]'), '');
  }

  /// Valida CPF pelo algoritmo oficial (dígitos verificadores).
  ///
  /// - Remove caracteres não numéricos automaticamente
  /// - Rejeita CPFs com todos os dígitos iguais (ex: 11111111111)
  static bool isValidCpf(String input) {
    final cpf = onlyDigits(input);
    if (cpf.length != 11) return false;

    // Rejeita sequência de dígitos iguais.
    final allEqual = cpf.split('').every((c) => c == cpf[0]);
    if (allEqual) return false;

    final digits = cpf.split('').map(int.parse).toList(growable: false);

    int calcDigit(List<int> base, int weightStart) {
      var sum = 0;
      var weight = weightStart;
      for (final d in base) {
        sum += d * weight;
        weight--;
      }
      final mod = sum % 11;
      final dv = (mod < 2) ? 0 : 11 - mod;
      return dv;
    }

    final dv1 = calcDigit(digits.sublist(0, 9), 10);
    if (dv1 != digits[9]) return false;

    final dv2 = calcDigit(digits.sublist(0, 10), 11);
    if (dv2 != digits[10]) return false;

    return true;
  }
}


