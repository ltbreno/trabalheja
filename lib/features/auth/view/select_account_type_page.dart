// lib/features/auth/view/select_account_type_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';

// Enum para representar os tipos de conta
enum AccountType { none, client, freelancer }

class SelectAccountTypePage extends StatefulWidget {
  // Receber dados das telas anteriores, se necessário
  // final String email;
  // final String phone;
  // final String password;

  const SelectAccountTypePage({
    super.key,
    // required this.email,
    // required this.phone,
    // required this.password,
  });

  @override
  State<SelectAccountTypePage> createState() => _SelectAccountTypePageState();
}

class _SelectAccountTypePageState extends State<SelectAccountTypePage> {
  AccountType _selectedAccountType = AccountType.none; // Estado para seleção

  void _createAccount() {
    if (_selectedAccountType == AccountType.none) {
      // Mostrar mensagem pedindo para selecionar um tipo
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione um tipo de conta.')),
      );
      return;
    }

    print('Tipo de conta selecionado: $_selectedAccountType');
    // print('Email: ${widget.email}'); // Exemplo se receber dados
    // TODO: Chamar a função final de cadastro no Supabase, passando todos os dados
    // incluindo o tipo de conta (talvez como metadata ou em 'profiles')
    // Ex: _performFinalSignUp(widget.email, widget.password, widget.phone, _selectedAccountType);
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
              const SizedBox(height: AppSpacing.spacing32),

              // Card Cliente
              _buildAccountTypeCard(
                iconPath: 'assets/icons/person_outline.png', // Use o nome correto do seu ícone
                title: 'Cliente',
                description: 'Sua conta poderá ver freelancers próximos para contratar.',
                type: AccountType.client,
                isSelected: _selectedAccountType == AccountType.client,
                onTap: () => setState(() => _selectedAccountType = AccountType.client),
              ),

              const SizedBox(height: AppSpacing.spacing16),

              // Card Freelancer
              _buildAccountTypeCard(
                iconPath: 'assets/icons/briefcase.png',
                title: 'Freelancer',
                description: 'Sua conta poderá ver trabalhos próximos a sua região.',
                type: AccountType.freelancer,
                isSelected: _selectedAccountType == AccountType.freelancer,
                onTap: () => setState(() => _selectedAccountType = AccountType.freelancer),
              ),

              const Spacer(), // Empurra o botão para baixo

              // Botão Criar minha conta
              AppButton.primary(
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