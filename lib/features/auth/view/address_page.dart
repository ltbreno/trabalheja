// lib/features/auth/view/address_page.dart
import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/core/widgets/MainAppShell.dart';
import 'package:trabalheja/features/payment/service/payment_service.dart';

class AddressPage extends StatefulWidget {
  final String? fullName; // Nome completo vindo da página anterior
  final String? email;
  final String? phone;
  final String? cpf;
  final String? birthdate;

  const AddressPage({
    super.key,
    this.fullName,
    this.email,
    this.phone,
    this.cpf,
    this.birthdate,
  });

  @override
  State<AddressPage> createState() => _AddressPageState();
}

class _AddressPageState extends State<AddressPage> {
  final _cepController = TextEditingController();
  final _bairroController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _cidadeController = TextEditingController(text: 'São Paulo, SP'); // Pré-preenchido
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _feedbackMessage; // Nova variável para mensagem de feedback
  bool _isFeedbackError = false; // Se a mensagem é de erro ou sucesso

  // Máscara para CEP
  final _cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void dispose() {
    _cepController.dispose();
    _bairroController.dispose();
    _ruaController.dispose();
    _numeroController.dispose();
    _complementoController.dispose();
    _cidadeController.dispose();
    super.dispose();
  }

  void _showFeedback(String message, {bool isError = false}) {
    setState(() {
      _feedbackMessage = message;
      _isFeedbackError = isError;
    });
  }

  void _clearFeedback() {
    setState(() {
      _feedbackMessage = null;
      _isFeedbackError = false;
    });
  }

  Future<void> _continue() async {
    _clearFeedback(); // Limpa feedback anterior

    if (!(_formKey.currentState?.validate() ?? false)) {
      _showFeedback('Por favor, preencha todos os campos obrigatórios.', isError: true);
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Preparar dados para atualização - incluir nome e endereço juntos
      final updateData = <String, dynamic>{
        'address_cep': _cepController.text.trim(),
        'address_bairro': _bairroController.text.trim(),
        'address_rua': _ruaController.text.trim(),
        'address_numero': _numeroController.text.trim(),
        'address_complemento': _complementoController.text.trim().isEmpty 
            ? null 
            : _complementoController.text.trim(),
        'address_cidade': _cidadeController.text.trim(),
      };

      // Incluir o nome no update (se foi passado como parâmetro)
      // Caso contrário, buscar do perfil atual
      String? nameToSave = widget.fullName;
      
      if (nameToSave == null || nameToSave.trim().isEmpty) {
        // Se não foi passado, buscar do perfil atual
        final profile = await _supabase
            .from('profiles')
            .select('full_name')
            .eq('id', user.id)
            .maybeSingle();
        
        if (profile != null && profile['full_name'] != null) {
          nameToSave = profile['full_name'].toString();
        }
      }

      // Se temos um nome válido, incluir no update
      if (nameToSave != null && nameToSave.trim().isNotEmpty) {
        updateData['full_name'] = nameToSave.trim();
      }

      // Debug: mostrar o que será enviado
      print('📤 [AddressPage] Enviando UPDATE para Supabase:');
      print('   - address_cep: ${updateData['address_cep']}');
      print('   - address_bairro: ${updateData['address_bairro']}');
      print('   - address_rua: ${updateData['address_rua']}');
      print('   - address_numero: ${updateData['address_numero']}');
      print('   - address_complemento: ${updateData['address_complemento'] ?? 'null'}');
      print('   - address_cidade: ${updateData['address_cidade']}');
      print('   - full_name: ${updateData['full_name'] ?? 'não incluído'}');
      print('   - user.id: ${user.id}');

      // Atualizar perfil com endereço (UPDATE - o perfil já existe)
      await _supabase.from('profiles').update(updateData).eq('id', user.id);

      print('✅ [AddressPage] Dados atualizados com sucesso!');

      // Criar customer no Pagar.me se temos todos os dados necessários
      if (widget.cpf != null && widget.cpf!.isNotEmpty) {
        await _createPagarmeCustomer(user.id, nameToSave ?? '');
      }

      if (!mounted) return;

      // Navegar para a tela principal do app (MainAppShell)
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainAppShell()),
        (route) => false, // Remove todas as rotas anteriores
      );
      
      _showFeedback('Cadastro concluído!', isError: false);
    } catch (e) {
      if (!mounted) return;
      _showFeedback('Erro ao salvar endereço: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  /// Cria um customer no Pagar.me para o cliente
  Future<void> _createPagarmeCustomer(String userId, String fullName) async {
    try {
      print('📡 [AddressPage] Criando customer no Pagar.me...');
      
      final paymentService = PaymentService();
      
      // Montar telefone no formato esperado
      final phone = widget.phone ?? '';
      final phoneDigits = phone.replaceAll(RegExp(r'[^0-9]'), '');
      Map<String, String>? mobilePhone;
      
      if (phoneDigits.length >= 10) {
        // Assumindo formato brasileiro DDD + 9 digitos (11 total) ou DDD + 8 digitos (10 total)
        final ddd = phoneDigits.substring(0, 2);
        final number = phoneDigits.substring(2);
        mobilePhone = {
          'country_code': '55',
          'area_code': ddd,
          'number': number,
        };
      }

      // Formatar data de nascimento: converter YYYY-MM-DD para MM/DD/AAAA (Formato Americano)
      String? birthdateForApi = widget.birthdate;
      
      if (birthdateForApi != null && birthdateForApi.contains('-')) {
         final parts = birthdateForApi.split('-');
         if (parts.length == 3) {
           // parts[0] = YYYY, parts[1] = MM, parts[2] = DD
           birthdateForApi = '${parts[1]}/${parts[2]}/${parts[0]}';
         }
      }

      // Tentar extrair cidade e estado do controller (formato esperado: "Cidade, UF" ou apenas "Cidade")
      String city = _cidadeController.text;
      String state = 'SP'; // Default fallback
      
      if (city.contains(',')) {
        final cityParts = city.split(',');
        city = cityParts[0].trim();
        if (cityParts.length > 1) {
          final possibleState = cityParts[1].trim();
          if (possibleState.length == 2) {
            state = possibleState.toUpperCase();
          }
        }
      }

      // Montar objeto de endereço
      final address = {
        'line_1': '${_ruaController.text}, ${_numeroController.text}',
        'line_2': _complementoController.text,
        'zip_code': _cepController.text.replaceAll(RegExp(r'[^0-9]'), ''),
        'city': city,
        'state': state,
        'country': 'BR',
      };

      final result = await paymentService.createCustomer(
        name: fullName,
        email: widget.email ?? '',
        document: widget.cpf ?? '',
        type: 'individual',
        code: userId,
        birthdate: birthdateForApi,
        mobilePhone: mobilePhone,
        address: address,
        metadata: {
           'source': 'app_trabalheja',
           'account_type': 'client',
        }
      );

      // Extrair o ID do customer criado
      final customerId = result['data']?['pagarme_customer_id'] ?? result['id'];
      
      if (customerId != null) {
        // Salvar o ID do customer no perfil
        await _supabase.from('profiles').update({
          'pagarme_customer_id': customerId,
        }).eq('id', userId);
        
        print('✅ [AddressPage] Customer Pagar.me criado e salvo: $customerId');
      } else {
        print('⚠️ [AddressPage] Customer criado mas ID não retornado');
      }
    } catch (e) {
      // Não bloquear o cadastro por erro no Pagar.me
      print('❌ [AddressPage] Erro ao criar customer no Pagar.me: $e');
      // O cadastro continua normalmente, o customer pode ser criado depois
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      appBar: AppBar(
        backgroundColor: AppColorsNeutral.neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorsNeutral.neutral900),
          onPressed: () {
            if (Navigator.canPop(context)) {
              Navigator.pop(context);
            }
          },
        ),
        title: Text(
          'Voltar',
          style: AppTypography.contentMedium.copyWith(
            color: AppColorsNeutral.neutral900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.spacing16),
                Text(
                  'Cadastro de endereço', // Título
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  'Para uma melhor experiência, precisamos do endereço. Você poderá cadastrar novos mais tarde.', // Subtítulo
                  style: AppTypography.contentRegular.copyWith(
                    color: AppColorsNeutral.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Mensagem de feedback centralizada
                if (_feedbackMessage != null) ...[
                  Text(
                    _feedbackMessage!,
                    textAlign: TextAlign.center,
                    style: AppTypography.contentMedium.copyWith(
                      color: _isFeedbackError ? AppColorsError.error500 : AppColorsPrimary.primary800,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing16),
                ],

                // Campo CEP
                AppTextField(
                  label: 'CEP',
                  hintText: '00000-000',
                  controller: _cepController,
                  keyboardType: TextInputType.number,
                  inputFormatters: [_cepMaskFormatter], // Aplica máscara
                  validator: (value) {
                    if (value == null || value.isEmpty) return 'Informe o CEP';
                    if (!_cepMaskFormatter.isFill()) return 'CEP incompleto';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Campo Bairro
                AppTextField(
                  label: 'Bairro',
                  hintText: 'Informe o bairro',
                  controller: _bairroController,
                   validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Informe o bairro';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Campo Rua
                AppTextField(
                  label: 'Rua, avenida, vila...',
                  hintText: 'Informe a rua',
                  controller: _ruaController,
                   validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Informe a rua';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Linha para Número e Complemento
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start, // Alinha labels no topo
                  children: [
                    Expanded(
                      child: AppTextField(
                        label: 'Número',
                        hintText: '000',
                        controller: _numeroController,
                        keyboardType: TextInputType.number,
                         validator: (value) {
                          if (value == null || value.trim().isEmpty) return 'Informe o número';
                          return null;
                         },
                      ),
                    ),
                    const SizedBox(width: AppSpacing.spacing16),
                    Expanded(
                      child: AppTextField(
                        label: 'Complemento',
                        hintText: '000',
                        controller: _complementoController,
                        // Complemento geralmente não é obrigatório
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Campo Cidade
                AppTextField(
                  label: 'Cidade',
                  hintText: 'Cidade, Estado',
                  controller: _cidadeController,
                  // Poderia ser um Dropdown ou Autocomplete no futuro
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return 'Informe a cidade';
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Botão Continuar
                 _isLoading
                   ? const Center(child: CircularProgressIndicator())
                   : AppButton.primary(
                      text: 'Continuar',
                      onPressed: _continue,
                      minWidth: double.infinity,
                    ),

                const SizedBox(height: AppSpacing.spacing16), // Espaço inferior
              ],
            ),
          ),
        ),
      ),
    );
  }
}