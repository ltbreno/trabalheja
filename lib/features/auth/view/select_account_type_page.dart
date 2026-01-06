// lib/features/auth/view/select_account_type_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/auth/view/complete_name_page.dart';
import 'package:trabalheja/features/auth/view/freelancer_services_page.dart';

// Enum para representar os tipos de conta
enum AccountType { none, client, freelancer }

class SelectAccountTypePage extends StatefulWidget {
  final String email;
  final String phone;

  const SelectAccountTypePage({
    super.key,
    required this.email,
    required this.phone,
  });

  @override
  State<SelectAccountTypePage> createState() => _SelectAccountTypePageState();
}

class _SelectAccountTypePageState extends State<SelectAccountTypePage> {
  AccountType _selectedAccountType = AccountType.none; // Estado para seleção
  final _supabase = Supabase.instance.client;
  bool _isLoading = false;
  String? _errorMessage; // Variável para a mensagem de erro centralizada

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

  Future<void> _createAccount() async {
    _clearError(); // Limpa erros anteriores

    if (_selectedAccountType == AccountType.none) {
      _showError('Por favor, selecione um tipo de conta.');
      return;
    }

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Validar dados
      if (widget.email.trim().isEmpty) {
        throw Exception('Email não pode estar vazio');
      }
      if (widget.phone.trim().isEmpty) {
        throw Exception('Telefone não pode estar vazio');
      }

      // Lógica diferente para cliente e freelancer:
      // - CLIENTE: Cria o perfil aqui (INSERT)
      // - FREELANCER: Não cria o perfil aqui, será criado no final do processo
      if (_selectedAccountType == AccountType.client) {
        // Criar perfil para CLIENTE
        final insertData = <String, dynamic>{
          'id': user.id,
          'account_type': 'client',
          'email': widget.email.trim(),
          'phone': widget.phone.trim(),
        };

        // Debug: mostrar o que será enviado
        print('📤 [SelectAccountTypePage] Criando perfil CLIENTE no Supabase:');
        print('   - id: ${insertData['id']}');
        print('   - account_type: ${insertData['account_type']}');
        print('   - email: ${insertData['email']}');
        print('   - phone: ${insertData['phone']}');

        // Criar o perfil pela primeira vez (INSERT)
        // Se já existir, fazer UPDATE (caso o usuário volte nessa tela)
        try {
          await _supabase.from('profiles').insert(insertData);
          print('✅ [SelectAccountTypePage] Perfil CLIENTE criado com sucesso!');
        } catch (insertError) {
          // Log detalhado do erro para debug
          print('❌ [SelectAccountTypePage] Erro ao criar perfil: $insertError');
          if (insertError is PostgrestException) {
            print('   - Message: ${insertError.message}');
            print('   - Details: ${insertError.details}');
            print('   - Hint: ${insertError.hint}');
            print('   - Code: ${insertError.code}');
          }
          
          // Se o perfil já existir, fazer UPDATE
          final errorStr = insertError.toString().toLowerCase();
          if (errorStr.contains('duplicate') || 
              errorStr.contains('unique') ||
              errorStr.contains('already exists') ||
              (insertError is PostgrestException && insertError.code == '23505')) {
            print('⚠️ [SelectAccountTypePage] Perfil já existe, fazendo UPDATE...');
            await _supabase.from('profiles').update({
              'account_type': insertData['account_type'],
              'email': insertData['email'],
              'phone': insertData['phone'],
            }).eq('id', user.id);
            print('✅ [SelectAccountTypePage] Perfil atualizado com sucesso!');
          } else {
            // Outro tipo de erro, re-lançar com mais informações
            print('❌ [SelectAccountTypePage] Erro não tratado, re-lançando...');
            rethrow;
          }
        }
      } else {
        // FREELANCER: Não cria o perfil aqui
        // O perfil será criado apenas no final do processo (FreelancerPicturePage)
        // após todas as informações serem coletadas (incluindo lat/lon)
        print('ℹ️ [SelectAccountTypePage] FREELANCER selecionado - perfil será criado no final do processo');
      }

      if (!mounted) return;

      // Redirecionar para a página apropriada baseado no tipo de conta
      if (_selectedAccountType == AccountType.client) {
      // Se for cliente, vai para a página de nome completo
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => CompleteNamePage(
            email: widget.email,
            phone: widget.phone,
          ),
        ),
      );
      } else if (_selectedAccountType == AccountType.freelancer) {
        // Se for freelancer, vai para a página de serviços
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => FreelancerServicesPage(
              email: widget.email,
              phone: widget.phone,
            ),
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      
      // Capturar mensagem de erro mais detalhada
      String errorMessage = 'Erro ao salvar tipo de conta.';
      if (e is PostgrestException) {
        errorMessage = e.message;
        if (e.details != null) {
          final detailsStr = e.details.toString();
          if (detailsStr.isNotEmpty) {
            errorMessage += '\nDetalhes: $detailsStr';
          }
        }
        if (e.hint != null) {
          final hintStr = e.hint.toString();
          if (hintStr.isNotEmpty) {
            errorMessage += '\nDica: $hintStr';
          }
        }
      } else {
        errorMessage = e.toString();
      }
      
      _showError(errorMessage);
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
        child: Padding(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
                              const SizedBox(height: AppSpacing.spacing16),
                              Text(
                                'Ótimo! Agora selecione\nseu tipo de conta', // Título
                                style: AppTypography.heading1.copyWith(
                                  color: AppColorsNeutral.neutral900,
                                ),
                              ),
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
                              const SizedBox(height: AppSpacing.spacing32),
              // Card Cliente
              _buildAccountTypeCard(
                iconPath: 'assets/icons/person_outline.png', // Use o nome correto do seu ícone
                title: 'Cliente',
                description: 'Você poderá solicitar serviços diversos na sua região.',
                type: AccountType.client,
                isSelected: _selectedAccountType == AccountType.client,
                onTap: () => setState(() => _selectedAccountType = AccountType.client),
              ),

              const SizedBox(height: AppSpacing.spacing16),

              // Card Freelancer
              _buildAccountTypeCard(
                iconPath: 'assets/icons/briefcase.png',
                title: 'Freelancer',
                description: 'Você poderá se candidatar a serviços solicitados em sua região.',
                type: AccountType.freelancer,
                isSelected: _selectedAccountType == AccountType.freelancer,
                onTap: () => setState(() => _selectedAccountType = AccountType.freelancer),
              ),

              const Spacer(), // Empurra o botão para baixo

              // Botão Criar minha conta
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton.primary(
                      text: 'Criar minha conta',
                      onPressed: _createAccount, // Chama a função de criação
                      minWidth: double.infinity,
                    ),
              const SizedBox(height: AppSpacing.spacing16), // Espaço inferior
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para criar os cards de seleção
  Widget _buildAccountTypeCard({
    required String iconPath,
    required String title,
    required String description,
    required AccountType type,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final Color bgColor = isSelected ? AppColorsPrimary.primary900 : AppColorsNeutral.neutral50;
    final Color titleColor = isSelected ? AppColorsNeutral.neutral0 : AppColorsNeutral.neutral900;
    final Color descriptionColor = isSelected ? AppColorsNeutral.neutral100 : AppColorsNeutral.neutral600;
    final Color iconBgColor = isSelected ? AppColorsPrimary.primary800 : AppColorsPrimary.primary100; // Fundo do ícone
    final Color iconColor = isSelected ? AppColorsNeutral.neutral0 : AppColorsPrimary.primary900;

    return InkWell( // Torna o card clicável
      onTap: onTap,
      borderRadius: AppRadius.radius12, // Raio para o efeito do InkWell
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spacing16),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: AppRadius.radius12, // Usar um raio apropriado
          border: Border.all( // Adiciona borda sutil se não estiver selecionado
            color: isSelected ? Colors.transparent : AppColorsNeutral.neutral200,
            width: 1.0,
          ),
        ),
        child: Row(
          children: [
            // Círculo com ícone
            Container(
              padding: const EdgeInsets.all(AppSpacing.spacing8),
              decoration: BoxDecoration(
                color: iconBgColor,
                shape: BoxShape.circle,
              ),
              child: SvgPicture.asset(
                iconPath,
                height: 24, // Tamanho do ícone (40x40 é o tamanho do box na imagem de referência)
                width: 24,
                colorFilter: ColorFilter.mode(iconColor, BlendMode.srcIn),
              ),
            ),
            const SizedBox(width: AppSpacing.spacing12),
            // Textos
            Expanded( // Para o texto quebrar linha se necessário
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.highlightBold.copyWith(color: titleColor), // Estilo do título
                  ),
                  const SizedBox(height: AppSpacing.spacing4),
                  Text(
                    description,
                    style: AppTypography.captionRegular.copyWith(color: descriptionColor), // Estilo da descrição
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}   