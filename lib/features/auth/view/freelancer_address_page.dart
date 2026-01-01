// lib/features/auth/view/freelancer_address_page.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mask_text_input_formatter/mask_text_input_formatter.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/core/utils/br_validators.dart';
import 'package:trabalheja/core/utils/via_cep_service.dart';
import 'package:trabalheja/features/auth/view/freelancer_radius_page.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';

class FreelancerAddressPage extends StatefulWidget {
  // Receber dados das telas anteriores (nome, email, tipo de conta, etc.)
  // final String fullName;
  // final AccountType accountType;

  const FreelancerAddressPage({
    super.key,
    // required this.fullName,
    // required this.accountType,
  });

  @override
  State<FreelancerAddressPage> createState() => _FreelancerAddressPageState();
}

class _FreelancerAddressPageState extends State<FreelancerAddressPage> {
  final _cepController = TextEditingController();
  final _bairroController = TextEditingController();
  final _ruaController = TextEditingController();
  final _numeroController = TextEditingController();
  final _complementoController = TextEditingController();
  final _cidadeController = TextEditingController(text: 'São Paulo, SP'); // Pré-preenchido
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  bool _isCepLoading = false;
  Timer? _cepDebounce;
  String? _lastCepLookupDigits;
  String? _feedbackMessage; // Variável para a mensagem de feedback centralizada
  bool _isFeedbackError = false; // Se a mensagem é de erro ou sucesso

  // Máscara para CEP
  final _cepMaskFormatter = MaskTextInputFormatter(
    mask: '#####-###',
    filter: {"#": RegExp(r'[0-9]')},
  );

  @override
  void initState() {
    super.initState();
    _cepController.addListener(_onCepChanged);
    _loadAddressFromProfile();
  }

  void _onCepChanged() {
    _cepDebounce?.cancel();
    _cepDebounce = Timer(const Duration(milliseconds: 350), () async {
      final cepDigits = BrValidators.onlyDigits(_cepController.text);
      if (cepDigits.length != 8) return;
      if (_isCepLoading) return;
      if (_lastCepLookupDigits == cepDigits) return;
      await _lookupCepAndAutofill(cepDigits);
    });
  }

  Future<void> _lookupCepAndAutofill(String cepDigits) async {
    setState(() {
      _isCepLoading = true;
      _lastCepLookupDigits = cepDigits;
    });

    try {
      final address = await ViaCepService.fetchAddress(cepDigits);
      if (!mounted) return;

      if (address == null) {
        _showFeedback('CEP não encontrado. Você pode preencher o endereço manualmente.', isError: true);
        return;
      }

      _bairroController.text = address.bairro;
      _ruaController.text = address.logradouro;

      final city = address.localidade.trim();
      final uf = address.uf.trim().toUpperCase();
      if (city.isNotEmpty && uf.length == 2) {
        _cidadeController.text = '$city, $uf';
      } else if (city.isNotEmpty) {
        _cidadeController.text = city;
      }

      _clearFeedback();
    } catch (_) {
      if (!mounted) return;
      _showFeedback('Não foi possível buscar o CEP agora. Preencha o endereço manualmente.', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isCepLoading = false);
      }
    }
  }

  Future<void> _loadAddressFromProfile() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) return;
      final profile = await _supabase
          .from('profiles')
          .select('address_cep, address_bairro, address_rua, address_numero, address_complemento, address_cidade')
          .eq('id', user.id)
          .maybeSingle();
      if (profile == null) return;
      setState(() {
        _cepController.text = (profile['address_cep'] ?? '').toString();
        _bairroController.text = (profile['address_bairro'] ?? '').toString();
        _ruaController.text = (profile['address_rua'] ?? '').toString();
        _numeroController.text = (profile['address_numero'] ?? '').toString();
        _complementoController.text = (profile['address_complemento'] ?? '').toString();
        _cidadeController.text = (profile['address_cidade'] ?? _cidadeController.text).toString();
      });
    } catch (_) {
      // silencioso
    }
  }

  @override
  void dispose() {
    _cepDebounce?.cancel();
    _cepController.removeListener(_onCepChanged);
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

      // Salvar endereço no perfil
      // Criar perfil parcialmente se não existir
      
      // Buscar email e phone do usuário
      final userEmail = user.email ?? user.userMetadata?['email'] as String?;
      final userPhone = user.userMetadata?['phone'] as String?;
      
      if (userEmail == null || userPhone == null) {
        throw Exception('Email ou telefone do usuário não encontrado');
      }

      // Verificar se o perfil já existe
      final existingProfile = await _supabase
          .from('profiles')
          .select('id')
          .eq('id', user.id)
          .maybeSingle();

      if (existingProfile != null) {
        // Perfil existe, fazer UPDATE
        print('📝 [FreelancerAddressPage] Atualizando perfil existente com endereço...');
        await _supabase.from('profiles').update({
          'address_cep': _cepController.text.trim(),
          'address_bairro': _bairroController.text.trim(),
          'address_rua': _ruaController.text.trim(),
          'address_numero': _numeroController.text.trim(),
          'address_complemento': _complementoController.text.trim().isEmpty 
              ? null 
              : _complementoController.text.trim(),
          'address_cidade': _cidadeController.text.trim(),
        }).eq('id', user.id);
        print('✅ [FreelancerAddressPage] Endereço salvo com sucesso!');
      } else {
        // Perfil não existe, criar parcialmente
        // IMPORTANTE: Freelancers precisam de coordenadas (constraint do banco)
        // Usar coordenadas padrão que serão atualizadas na página de raio
        print('📝 [FreelancerAddressPage] Criando perfil parcial com endereço...');
        final profileData = <String, dynamic>{
          'id': user.id,
          'account_type': 'freelancer',
          'email': userEmail,
          'phone': userPhone,
          'address_cep': _cepController.text.trim(),
          'address_bairro': _bairroController.text.trim(),
          'address_rua': _ruaController.text.trim(),
          'address_numero': _numeroController.text.trim(),
          'address_complemento': _complementoController.text.trim().isEmpty 
              ? null 
              : _complementoController.text.trim(),
          'address_cidade': _cidadeController.text.trim(),
          // Coordenadas padrão (serão atualizadas na página de raio)
          'service_latitude': -23.5505, // São Paulo
          'service_longitude': -46.6333, // São Paulo
          'service_radius': '5km', // Raio padrão
        };
        
        try {
          await _supabase.from('profiles').insert(profileData);
          print('✅ [FreelancerAddressPage] Perfil parcial criado com endereço!');
        } catch (insertError) {
          // Se o perfil foi criado entre a verificação e o insert, fazer update
          if (insertError.toString().contains('duplicate') || 
              insertError.toString().contains('unique')) {
            print('⚠️ [FreelancerAddressPage] Perfil foi criado, fazendo UPDATE...');
            await _supabase.from('profiles').update({
              'address_cep': _cepController.text.trim(),
              'address_bairro': _bairroController.text.trim(),
              'address_rua': _ruaController.text.trim(),
              'address_numero': _numeroController.text.trim(),
              'address_complemento': _complementoController.text.trim().isEmpty 
                  ? null 
                  : _complementoController.text.trim(),
              'address_cidade': _cidadeController.text.trim(),
            }).eq('id', user.id);
            print('✅ [FreelancerAddressPage] Endereço atualizado!');
          } else {
            rethrow;
          }
        }
      }

      if (!mounted) return;
      
      // Navegar para a página de raio de atuação do freelancer
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FreelancerRadiusPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      _showFeedback('Erro ao salvar endereço: ${e.toString()}', isError: true);
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
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
                if (_isCepLoading) ...[
                  const SizedBox(height: 8),
                  const LinearProgressIndicator(minHeight: 2),
                ],
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