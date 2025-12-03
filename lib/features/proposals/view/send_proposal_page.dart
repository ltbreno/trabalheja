// lib/features/proposals/view/send_proposal_page.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/core/utils/distance_calculator.dart' as distance_util;
import 'package:trabalheja/core/widgets/error_modal.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_dropdown_field.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/proposals/view/proposal_sent_success_page.dart';

class SendProposalPage extends StatefulWidget {
  final Map<String, dynamic> serviceRequest;

  const SendProposalPage({
    super.key,
    required this.serviceRequest,
  });

  @override
  State<SendProposalPage> createState() => _SendProposalPageState();
}

class _SendProposalPageState extends State<SendProposalPage> {
  final _priceController = TextEditingController(text: 'R\$ 0,00');
  final _availabilityValueController = TextEditingController();
  final _messageController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  
  bool _isLoading = false;
  String? _selectedAvailabilityUnit = 'Horas';
  
  final List<DropdownItem<String>> _availabilityUnits = [
    DropdownItem(value: 'Horas', label: 'Horas'),
    DropdownItem(value: 'Dias', label: 'Dias'),
    DropdownItem(value: 'Semanas', label: 'Semanas'),
    DropdownItem(value: 'Meses', label: 'Meses'),
  ];

  @override
  void initState() {
    super.initState();
    _priceController.addListener(_onPriceChanged);
  }

  void _onPriceChanged() {
    // Remove formatação para manter apenas números
    final text = _priceController.text
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '')
        .replaceAll(' ', '')
        .trim();
    
    if (text.isNotEmpty) {
      final value = int.tryParse(text) ?? 0;
      final formatted = (value / 100).toStringAsFixed(2);
      final parts = formatted.split('.');
      
      // Formata com pontos de milhar
      String integerPart = parts[0];
      String formattedInteger = '';
      for (int i = integerPart.length - 1; i >= 0; i--) {
        formattedInteger = integerPart[i] + formattedInteger;
        if ((integerPart.length - i) % 3 == 0 && i > 0) {
          formattedInteger = '.$formattedInteger';
        }
      }
      
      final newValue = 'R\$ $formattedInteger,${parts[1]}';
      if (_priceController.text != newValue) {
        final cursorPosition = _priceController.selection.baseOffset;
        _priceController.value = TextEditingValue(
          text: newValue,
          selection: TextSelection.collapsed(
            offset: cursorPosition > newValue.length ? newValue.length : cursorPosition,
          ),
        );
      }
    } else if (_priceController.text != 'R\$ 0,00') {
      _priceController.value = const TextEditingValue(
        text: 'R\$ 0,00',
        selection: TextSelection.collapsed(offset: 6),
      );
    }
  }

  @override
  void dispose() {
    _priceController.removeListener(_onPriceChanged);
    _priceController.dispose();
    _availabilityValueController.dispose();
    _messageController.dispose();
    super.dispose();
  }

  String _formatCurrency(double value) {
    final formatted = value.toStringAsFixed(2);
    final parts = formatted.split('.');
    final integerPart = parts[0];
    final decimalPart = parts[1];
    
    String formattedInteger = '';
    for (int i = integerPart.length - 1; i >= 0; i--) {
      formattedInteger = integerPart[i] + formattedInteger;
      if ((integerPart.length - i) % 3 == 0 && i > 0) {
        formattedInteger = '.$formattedInteger';
      }
    }
    
    return 'R\$ $formattedInteger,$decimalPart';
  }

  bool _containsContactInfo(String text) {
    // Padrões para detectar informações de contato
    final emailPattern = RegExp(r'\b[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Z|a-z]{2,}\b');
    final phonePattern = RegExp(r'(\+?\d{1,3}[\s-]?)?\(?\d{2,3}\)?[\s-]?\d{4,5}[\s-]?\d{4}');
    final whatsappPattern = RegExp(r'(whatsapp|wpp|zap)', caseSensitive: false);
    final instagramPattern = RegExp(r'(@[\w]+|instagram)', caseSensitive: false);
    final facebookPattern = RegExp(r'facebook', caseSensitive: false);
    
    final lowerText = text.toLowerCase();
    
    return emailPattern.hasMatch(text) ||
           phonePattern.hasMatch(text) ||
           whatsappPattern.hasMatch(lowerText) ||
           instagramPattern.hasMatch(lowerText) ||
           facebookPattern.hasMatch(lowerText);
  }

  double _parsePrice(String priceText) {
    // Remove formatação e converte para double
    final cleanText = priceText
        .replaceAll('R\$', '')
        .replaceAll('.', '')
        .replaceAll(',', '.')
        .trim();
    return double.tryParse(cleanText) ?? 0.0;
  }

  Future<void> _sendProposal() async {
    if (!(_formKey.currentState?.validate() ?? false)) {
      return;
    }

    // Validar se mensagem contém dados de contato
    final messageText = _messageController.text.trim();
    if (messageText.isNotEmpty && _containsContactInfo(messageText)) {
      ErrorModal.show(
        context,
        title: 'Dados de contato não permitidos',
        message: 'Não inclua seus dados pessoais ou de contato na mensagem. Toda negociação deve ser feita pelo aplicativo.',
      );
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Verificar se já existe proposta para este serviço
      final existingProposal = await _supabase
          .from('proposals')
          .select('id')
          .eq('service_request_id', widget.serviceRequest['id'])
          .eq('freelancer_id', user.id)
          .maybeSingle();

      if (existingProposal != null) {
        throw Exception('Você já enviou uma proposta para este serviço.');
      }

      // Converter valor
      final price = _parsePrice(_priceController.text);
      if (price <= 0) {
        throw Exception('Valor inválido');
      }

      // Converter disponibilidade
      final availabilityValue = int.tryParse(_availabilityValueController.text);
      if (availabilityValue == null || availabilityValue <= 0) {
        throw Exception('Valor de disponibilidade inválido');
      }

      // Criar proposta
      await _supabase.from('proposals').insert({
        'service_request_id': widget.serviceRequest['id'],
        'freelancer_id': user.id,
        'proposed_price': price,
        'availability_value': availabilityValue,
        'availability_unit': _selectedAvailabilityUnit,
        'message': messageText.isEmpty ? null : messageText,
        'status': 'pending',
      });

      if (!mounted) return;

      // Navegar para tela de sucesso
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => const ProposalSentSuccessPage(),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      
      String errorMessage = 'Erro ao enviar proposta. Tente novamente.';
      
      if (e.toString().contains('unique_freelancer_service_request')) {
        errorMessage = 'Você já enviou uma proposta para este serviço.';
      } else if (e.toString().contains('network') || e.toString().contains('connection')) {
        errorMessage = 'Erro de conexão. Verifique sua internet e tente novamente.';
      } else if (e.toString().isNotEmpty && !e.toString().contains('Exception')) {
        errorMessage = e.toString();
      }
      
      ErrorModal.show(
        context,
        title: 'Erro ao enviar proposta',
        message: errorMessage,
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final client = widget.serviceRequest['profiles'] as Map<String, dynamic>?;
    final clientName = client?['full_name'] as String? ?? 'Cliente';
    final budget = widget.serviceRequest['budget'] as num? ?? 0;
    final deadlineHours = widget.serviceRequest['deadline_hours'] as int? ?? 0;
    final distance = widget.serviceRequest['distance'] as double? ?? 0.0;

    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      appBar: AppBar(
        backgroundColor: AppColorsNeutral.neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorsNeutral.neutral900),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
          'Voltar',
          style: AppTypography.contentMedium.copyWith(
            color: AppColorsNeutral.neutral900,
          ),
        ),
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.all(AppSpacing.spacing24),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Título
                      Text(
                        'Enviar proposta',
                        style: AppTypography.heading1.copyWith(
                          color: AppColorsPrimary.primary700,
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.spacing32),
                      
                      // Informações do serviço
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.spacing16),
                        decoration: BoxDecoration(
                          color: AppColorsPrimary.primary50,
                          borderRadius: AppRadius.radius12,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Informações do serviço',
                              style: AppTypography.highlightBold.copyWith(
                                color: AppColorsPrimary.primary700,
                              ),
                            ),
                            const SizedBox(height: AppSpacing.spacing12),
                            _buildServiceInfoRow(
                              Icons.person,
                              clientName,
                            ),
                            const SizedBox(height: AppSpacing.spacing8),
                            _buildServiceInfoRow(
                              Icons.location_on,
                              'Em ${distance_util.AppDistanceCalculator.formatDistance(distance)}',
                            ),
                            const SizedBox(height: AppSpacing.spacing8),
                            _buildServiceInfoRow(
                              Icons.attach_money,
                              _formatCurrency(budget.toDouble()),
                            ),
                            const SizedBox(height: AppSpacing.spacing8),
                            _buildServiceInfoRow(
                              Icons.calendar_today,
                              'Em até $deadlineHours horas',
                            ),
                          ],
                        ),
                      ),
                      
                      const SizedBox(height: AppSpacing.spacing24),
                      
                      // Valor para realizar o serviço
                      Text(
                        'Valor para realizar o serviço',
                        style: AppTypography.highlightBold.copyWith(
                          color: AppColorsNeutral.neutral900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing8),
                      AppTextField(
                        label: '',
                        hintText: 'R\$ 0,00',
                        controller: _priceController,
                        keyboardType: TextInputType.number,
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[0-9]')),
                        ],
                        validator: (value) {
                          if (value == null || value.isEmpty || value.trim() == 'R\$ 0,00') {
                            return 'Informe o valor da proposta';
                          }
                          final price = _parsePrice(value);
                          if (price <= 0) {
                            return 'Valor deve ser maior que zero';
                          }
                          return null;
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.spacing24),
                      
                      // Disponibilidade
                      Text(
                        'Disponibilidade para realizar o serviço',
                        style: AppTypography.highlightBold.copyWith(
                          color: AppColorsNeutral.neutral900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing8),
                      Row(
                        children: [
                          Expanded(
                            flex: 2,
                            child: AppTextField(
                              label: '',
                              hintText: '0',
                              controller: _availabilityValueController,
                              keyboardType: TextInputType.number,
                              inputFormatters: [
                                FilteringTextInputFormatter.digitsOnly,
                              ],
                              validator: (value) {
                                if (value == null || value.isEmpty || value == '0') {
                                  return 'Obrigatório';
                                }
                                final numValue = int.tryParse(value);
                                if (numValue == null || numValue <= 0) {
                                  return 'Valor inválido';
                                }
                                return null;
                              },
                            ),
                          ),
                          const SizedBox(width: AppSpacing.spacing12),
                          Expanded(
                            flex: 3,
                            child: AppDropdownField<String>(
                              label: '',
                              items: _availabilityUnits,
                              selectedValue: _selectedAvailabilityUnit,
                              onChanged: (value) {
                                setState(() {
                                  _selectedAvailabilityUnit = value;
                                });
                              },
                            ),
                          ),
                        ],
                      ),
                      
                      const SizedBox(height: AppSpacing.spacing24),
                      
                      // Mensagem
                      Text(
                        'Mensagem',
                        style: AppTypography.highlightBold.copyWith(
                          color: AppColorsNeutral.neutral900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing8),
                      AppTextField(
                        label: '',
                        hintText: 'Envie uma mensagem personalizada para o cliente em sua proposta.',
                        controller: _messageController,
                        maxLines: 5,
                        keyboardType: TextInputType.multiline,
                      ),
                      
                      const SizedBox(height: AppSpacing.spacing16),
                      
                      // Aviso
                      Container(
                        padding: const EdgeInsets.all(AppSpacing.spacing12),
                        decoration: BoxDecoration(
                          color: AppColorsPrimary.primary50,
                          borderRadius: AppRadius.radius8,
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 20,
                              color: AppColorsPrimary.primary700,
                            ),
                            const SizedBox(width: AppSpacing.spacing8),
                            Expanded(
                              child: Text(
                                'Não inclua seus dados pessoais ou de contato na mensagem. Toda negociação deve ser feito pelo aplicativo.',
                                style: AppTypography.captionRegular.copyWith(
                                  color: AppColorsNeutral.neutral700,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Botão de enviar
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacing24),
              decoration: BoxDecoration(
                color: AppColorsNeutral.neutral0,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SizedBox(
                height: 48,
                child: _isLoading
                    ? const Center(
                        child: CircularProgressIndicator(
                          color: AppColorsPrimary.primary700,
                        ),
                      )
                    : AppButton.primary(
                        text: 'Enviar proposta',
                        onPressed: _sendProposal,
                        minWidth: double.infinity,
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildServiceInfoRow(IconData icon, String text) {
    return Row(
      children: [
        Icon(
          icon,
          size: 20,
          color: AppColorsPrimary.primary700,
        ),
        const SizedBox(width: AppSpacing.spacing8),
        Expanded(
          child: Text(
            text,
            style: AppTypography.contentRegular.copyWith(
              color: AppColorsNeutral.neutral900,
            ),
          ),
        ),
      ],
    );
  }
}

