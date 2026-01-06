// lib/features/auth/view/freelancer_services_page.dart
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/auth/view/freelancer_portfolio_page.dart';

class FreelancerServicesPage extends StatefulWidget {
  final String email;
  final String phone;

  const FreelancerServicesPage({
    super.key,
    required this.email,
    required this.phone,
  });

  @override
  State<FreelancerServicesPage> createState() => _FreelancerServicesPageState();
}

class _FreelancerServicesPageState extends State<FreelancerServicesPage> {
  final _nameController = TextEditingController();
  final _servicesController = TextEditingController(); // Controller para serviços
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _errorMessage; // Variável para a mensagem de erro centralizada

  @override
  void dispose() {
    _nameController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  void _showError(String message) {
    setState(() {
      _errorMessage = message;
    });
  }

  void _clearError() {
    setState(() {
      _errorMessage = null;
    });
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
                // Mensagem de erro centralizada
                if (_errorMessage != null) ...[
                  Text(
                    _errorMessage!,
                    textAlign: TextAlign.center,
                    style: AppTypography.contentMedium.copyWith(
                      color: AppColorsError.error500, // Cor de erro
                    ),
                  ),
                  const SizedBox(height: AppSpacing.spacing16), // Espaçamento após a mensagem de erro
                ],
                // Campo Nome Completo
                AppTextField(
                  label: 'Nome completo',
                  hintText: 'Informe seu nome completo',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe seu nome completo';
                    }
                    if (value.trim().split(' ').length < 2) {
                      return 'Por favor, informe nome e sobrenome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing24),

                // Campo Pitch / Apresentação
                AppTextField(
                  label: 'Fale sobre você e o seu trabalho/serviços',
                  hintText: 'Fale sobre você e o seu trabalho/serviços',
                  controller: _servicesController,
                  keyboardType: TextInputType.multiline, // Permite múltiplas linhas
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, fale sobre você e o seu trabalho/serviços';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.spacing32), // Espaço antes do botão

                // Botão Continuar
                _isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : AppButton(
                        type: AppButtonType.primary, 
                        text: 'Continuar',
                        onPressed: () async {
                          _clearError(); // Limpa erros anteriores
                          if (!(_formKey.currentState?.validate() ?? false)) {
                            _showError('Por favor, preencha todos os campos obrigatórios.');
                            return;
                          }

                          setState(() => _isLoading = true);

                          try {
                            final user = _supabase.auth.currentUser;
                            if (user == null) {
                              throw Exception('Usuário não autenticado');
                            }

                            // Salvar nome e pitch no perfil (campo "services")
                            // Criar perfil parcialmente se não existir
                            
                            // Verificar se o perfil já existe
                            final existingProfile = await _supabase
                                .from('profiles')
                                .select('id')
                                .eq('id', user.id)
                                .maybeSingle();

                            if (existingProfile != null) {
                              // Perfil existe, fazer UPDATE
                              print('📝 [FreelancerServicesPage] Atualizando perfil existente...');
                              await _supabase.from('profiles').update({
                                'full_name': _nameController.text.trim(),
                                'services': _servicesController.text.trim(),
                              }).eq('id', user.id);
                              print('✅ [FreelancerServicesPage] Nome e serviços salvos!');
                            } else {
                              // Perfil não existe, criar parcialmente
                              // IMPORTANTE: Freelancers precisam de coordenadas (constraint do banco)
                              // Usar coordenadas padrão que serão atualizadas na página de raio
                              print('📝 [FreelancerServicesPage] Criando perfil parcial...');
                              final profileData = <String, dynamic>{
                                'id': user.id,
                                'account_type': 'freelancer',
                                'email': widget.email,
                                'phone': widget.phone,
                                'full_name': _nameController.text.trim(),
                                'services': _servicesController.text.trim(),
                                // Coordenadas padrão (serão atualizadas na página de raio)
                                'service_latitude': -23.5505, // São Paulo
                                'service_longitude': -46.6333, // São Paulo
                                'service_radius': '5km', // Raio padrão
                              };
                              
                              try {
                                await _supabase.from('profiles').insert(profileData);
                                print('✅ [FreelancerServicesPage] Perfil parcial criado!');
                              } catch (insertError) {
                                // Se o perfil foi criado entre a verificação e o insert, fazer update
                                if (insertError.toString().contains('duplicate') || 
                                    insertError.toString().contains('unique')) {
                                  print('⚠️ [FreelancerServicesPage] Perfil foi criado, fazendo UPDATE...');
                                  await _supabase.from('profiles').update({
                                    'full_name': _nameController.text.trim(),
                                    'services': _servicesController.text.trim(),
                                  }).eq('id', user.id);
                                  print('✅ [FreelancerServicesPage] Dados atualizados!');
                                } else {
                                  rethrow;
                                }
                              }
                            }

                            if (!mounted) return;

                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const FreelancerPortfolioPage(),
                              ),
                            );
                          } catch (e) {
                            if (!mounted) return;
                            _showError('Erro ao salvar dados: ${e.toString()}');
                          } finally {
                            if (mounted) {
                              setState(() => _isLoading = false);
                            }
                          }
                        },
                        minWidth: double.infinity,
                        isLoading: _isLoading,
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