import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';

/// Página para freelancer cadastrar dados bancários
class BankAccountPage extends StatefulWidget {
  const BankAccountPage({super.key});

  @override
  State<BankAccountPage> createState() => _BankAccountPageState();
}

class _BankAccountPageState extends State<BankAccountPage> {
  final _supabase = Supabase.instance.client;
  final _formKey = GlobalKey<FormState>();
  
  // Controllers
  final _accountHolderController = TextEditingController();
  final _documentController = TextEditingController();
  final _bankCodeController = TextEditingController();
  final _branchNumberController = TextEditingController();
  final _branchCheckDigitController = TextEditingController();
  final _accountNumberController = TextEditingController();
  final _accountCheckDigitController = TextEditingController();
  
  bool _isLoading = false;
  bool _isSaving = false;
  String _accountType = 'checking'; // checking ou savings
  String _holderType = 'individual'; // individual ou company
  
  // Bancos mais comuns no Brasil
  final List<Map<String, String>> _popularBanks = [
    {'code': '001', 'name': 'Banco do Brasil'},
    {'code': '033', 'name': 'Santander'},
    {'code': '104', 'name': 'Caixa Econômica'},
    {'code': '237', 'name': 'Bradesco'},
    {'code': '341', 'name': 'Itaú'},
    {'code': '077', 'name': 'Banco Inter'},
    {'code': '260', 'name': 'Nubank'},
    {'code': '290', 'name': 'PagSeguro'},
    {'code': '323', 'name': 'Mercado Pago'},
    {'code': '380', 'name': 'PicPay'},
  ];

  @override
  void initState() {
    super.initState();
    _loadBankAccount();
  }

  @override
  void dispose() {
    _accountHolderController.dispose();
    _documentController.dispose();
    _bankCodeController.dispose();
    _branchNumberController.dispose();
    _branchCheckDigitController.dispose();
    _accountNumberController.dispose();
    _accountCheckDigitController.dispose();
    super.dispose();
  }

  Future<void> _loadBankAccount() async {
    setState(() => _isLoading = true);
    
    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) return;

      // Buscar dados bancários do usuário
      final profile = await _supabase
          .from('profiles')
          .select('full_name, cpf')
          .eq('id', userId)
          .single();

      // Preencher nome e CPF automaticamente
      if (profile['full_name'] != null) {
        _accountHolderController.text = profile['full_name'] as String;
      }
      
      if (profile['cpf'] != null) {
        _documentController.text = profile['cpf'] as String;
      }

      // Buscar dados bancários salvos (se existir)
      final bankData = await _supabase
          .from('bank_accounts')
          .select()
          .eq('user_id', userId)
          .maybeSingle();

      if (bankData != null) {
        setState(() {
          _accountHolderController.text = bankData['holder_name'] ?? '';
          _documentController.text = bankData['holder_document'] ?? '';
          _bankCodeController.text = bankData['bank_code'] ?? '';
          _branchNumberController.text = bankData['branch_number'] ?? '';
          _branchCheckDigitController.text = bankData['branch_check_digit'] ?? '';
          _accountNumberController.text = bankData['account_number'] ?? '';
          _accountCheckDigitController.text = bankData['account_check_digit'] ?? '';
          _accountType = bankData['account_type'] ?? 'checking';
          _holderType = bankData['holder_type'] ?? 'individual';
        });
      }
      
    } catch (e) {
      print('⚠️ Erro ao carregar dados bancários: $e');
    } finally {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _saveBankAccount() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);

    try {
      final userId = _supabase.auth.currentUser?.id;
      if (userId == null) {
        throw Exception('Usuário não autenticado');
      }

      print('💾 Salvando dados bancários...');

      // Salvar dados bancários no Supabase
      print('💾 Salvando no banco de dados...');
      
      final bankAccountData = {
        'user_id': userId,
        'holder_name': _accountHolderController.text.trim(),
        'holder_type': _holderType,
        'holder_document': _documentController.text.replaceAll(RegExp(r'[^\d]'), ''),
        'bank_code': _bankCodeController.text.trim(),
        'branch_number': _branchNumberController.text.trim(),
        'branch_check_digit': _branchCheckDigitController.text.trim(),
        'account_number': _accountNumberController.text.trim(),
        'account_check_digit': _accountCheckDigitController.text.trim(),
        'account_type': _accountType,
        'updated_at': DateTime.now().toIso8601String(),
      };

      // Verificar se já existe
      final existing = await _supabase
          .from('bank_accounts')
          .select('id')
          .eq('user_id', userId)
          .maybeSingle();

      if (existing != null) {
        // Atualizar
        await _supabase
            .from('bank_accounts')
            .update(bankAccountData)
            .eq('user_id', userId);
      } else {
        // Inserir
        await _supabase
            .from('bank_accounts')
            .insert(bankAccountData);
      }

      print('✅ Dados bancários salvos com sucesso!');

      if (!mounted) return;

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('✅ Dados bancários salvos com sucesso!'),
          backgroundColor: Colors.green,
        ),
      );

      Navigator.of(context).pop();
      
    } catch (e) {
      print('❌ Erro ao salvar dados bancários: $e');
      
      if (!mounted) return;
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('❌ Erro ao salvar: ${e.toString()}'),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isSaving = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dados Bancários'),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Info
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: Colors.blue.shade50,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue.shade700),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              'Cadastre sua conta bancária para receber pagamentos',
                              style: TextStyle(
                                color: Colors.blue.shade900,
                                fontSize: 14,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),

                    // Titular da conta
                    const Text(
                      'Titular da Conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      label: '',
                      controller: _accountHolderController,
                      hintText: 'Nome completo',
                      keyboardType: TextInputType.name,
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o nome do titular';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Tipo de titular
                    const Text(
                      'Tipo de Titular',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Pessoa Física'),
                            value: 'individual',
                            groupValue: _holderType,
                            onChanged: (value) {
                              setState(() => _holderType = value!);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Pessoa Jurídica'),
                            value: 'company',
                            groupValue: _holderType,
                            onChanged: (value) {
                              setState(() => _holderType = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // CPF/CNPJ
                    Text(
                      _holderType == 'individual' ? 'CPF' : 'CNPJ',
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    AppTextField(
                      label: '',
                      controller: _documentController,
                      hintText: _holderType == 'individual' ? '000.000.000-00' : '00.000.000/0000-00',
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _CpfCnpjInputFormatter(),
                      ],
                      validator: (value) {
                        if (value == null || value.trim().isEmpty) {
                          return 'Informe o ${_holderType == 'individual' ? 'CPF' : 'CNPJ'}';
                        }
                        final digits = value.replaceAll(RegExp(r'[^\d]'), '');
                        if (_holderType == 'individual' && digits.length != 11) {
                          return 'CPF deve ter 11 dígitos';
                        }
                        if (_holderType == 'company' && digits.length != 14) {
                          return 'CNPJ deve ter 14 dígitos';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 24),

                    // Dados bancários
                    const Text(
                      'Dados Bancários',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    
                    // Banco
                    DropdownButtonFormField<String>(
                      decoration: InputDecoration(
                        labelText: 'Banco',
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      value: _bankCodeController.text.isEmpty ? null : _bankCodeController.text,
                      items: _popularBanks.map((bank) {
                        return DropdownMenuItem(
                          value: bank['code'],
                          child: Text('${bank['code']} - ${bank['name']}'),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() => _bankCodeController.text = value ?? '');
                      },
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Selecione o banco';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Agência
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AppTextField(
                            label: '',
                            controller: _branchNumberController,
                            hintText: 'Agência',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(6),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe a agência';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: AppTextField(
                            label: '',
                            controller: _branchCheckDigitController,
                            hintText: 'DV',
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(2),
                            ],
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Tipo de conta
                    const Text(
                      'Tipo de Conta',
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Corrente'),
                            value: 'checking',
                            groupValue: _accountType,
                            onChanged: (value) {
                              setState(() => _accountType = value!);
                            },
                          ),
                        ),
                        Expanded(
                          child: RadioListTile<String>(
                            title: const Text('Poupança'),
                            value: 'savings',
                            groupValue: _accountType,
                            onChanged: (value) {
                              setState(() => _accountType = value!);
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),

                    // Conta
                    Row(
                      children: [
                        Expanded(
                          flex: 3,
                          child: AppTextField(
                            label: '',
                            controller: _accountNumberController,
                            hintText: 'Número da conta',
                            keyboardType: TextInputType.number,
                            inputFormatters: [
                              FilteringTextInputFormatter.digitsOnly,
                              LengthLimitingTextInputFormatter(13),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'Informe a conta';
                              }
                              return null;
                            },
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          flex: 1,
                          child: AppTextField(
                            label: '',
                            controller: _accountCheckDigitController,
                            hintText: 'DV',
                            keyboardType: TextInputType.text,
                            inputFormatters: [
                              LengthLimitingTextInputFormatter(2),
                            ],
                            validator: (value) {
                              if (value == null || value.trim().isEmpty) {
                                return 'DV';
                              }
                              return null;
                            },
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Botão Salvar
                    AppButton(
                      text: _isSaving ? 'Salvando...' : 'Salvar Dados Bancários',
                      onPressed: _isSaving ? null : _saveBankAccount,
                      isLoading: _isSaving,
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),
    );
  }
}

/// Formatter para CPF ou CNPJ
class _CpfCnpjInputFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final text = newValue.text.replaceAll(RegExp(r'[^\d]'), '');
    
    if (text.isEmpty) {
      return newValue.copyWith(text: '');
    }

    String formatted;
    
    if (text.length <= 11) {
      // CPF: 000.000.000-00
      formatted = text;
      if (text.length > 3) {
        formatted = '${text.substring(0, 3)}.${text.substring(3)}';
      }
      if (text.length > 6) {
        formatted = '${formatted.substring(0, 7)}.${text.substring(6)}';
      }
      if (text.length > 9) {
        formatted = '${formatted.substring(0, 11)}-${text.substring(9)}';
      }
    } else {
      // CNPJ: 00.000.000/0000-00
      formatted = text.substring(0, 14);
      if (formatted.length > 2) {
        formatted = '${formatted.substring(0, 2)}.${formatted.substring(2)}';
      }
      if (formatted.length > 6) {
        formatted = '${formatted.substring(0, 6)}.${formatted.substring(6)}';
      }
      if (formatted.length > 10) {
        formatted = '${formatted.substring(0, 10)}/${formatted.substring(10)}';
      }
      if (formatted.length > 15) {
        formatted = '${formatted.substring(0, 15)}-${formatted.substring(15)}';
      }
    }

    return newValue.copyWith(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}

