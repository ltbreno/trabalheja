import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/account/view/support_page.dart';
import 'profile_data_page.dart'; // Importar a nova página
import 'security_password_page.dart'; // Importar a nova página
import 'faq_page.dart';

class AccountPage extends StatelessWidget {
  const AccountPage({super.key});

  @override
  Widget build(BuildContext context) {
    // Esta tela não tem AppBar própria, pois faz parte do MainAppShell
    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      body: SafeArea(
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.spacing24),
              // --- Cabeçalho do Perfil ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
                child: _buildProfileHeader(),
              ),
              const SizedBox(height: AppSpacing.spacing32),

              // --- Opções de Navegação ---
              _buildNavigationList(context),

              const SizedBox(height: AppSpacing.spacing24),

              // --- Botão Sair ---
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
                child: _buildLogoutButton(context),
              ),

              const SizedBox(height: AppSpacing.spacing32),

              // --- Links de Suporte ---
              _buildSupportLinks(context),

              const SizedBox(height: AppSpacing.spacing24), // Espaço inferior
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColorsPrimary.primary900,
          child: Text(
            'JC',
            style: AppTypography.heading4.copyWith(color: AppColorsNeutral.neutral0),
          ),
        ),
        const SizedBox(width: AppSpacing.spacing12),
        // Nome e Tipo
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Bem-vindo de volta',
                style: AppTypography.captionRegular.copyWith(color: AppColorsNeutral.neutral600),
              ),
              Text(
                'José Carlos', // TODO: Puxar nome do usuário
                style: AppTypography.highlightBold.copyWith(color: AppColorsNeutral.neutral900),
              ),
            ],
          ),
        ),
        // Tag Cliente
        Container(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing12,
            vertical: AppSpacing.spacing4,
          ),
          decoration: BoxDecoration(
            color: AppColorsPrimary.primary100.withOpacity(0.5),
            borderRadius: AppRadius.radius6,
          ),
          child: Text(
            'Cliente', // TODO: Puxar tipo de conta
            style: AppTypography.captionBold.copyWith(color: AppColorsPrimary.primary700),
          ),
        ),
      ],
    );
  }

  Widget _buildNavigationList(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing24),
      child: Container(
        decoration: BoxDecoration(
          color: AppColorsNeutral.neutral0,
        ),
        child: Column(
          children: [
            _buildListTile(
              context: context,
              iconPath: 'assets/icons/person.svg', // Adapte o ícone
              title: 'Meus dados',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const ProfileDataPage()),
                );
              },
            ),
            _buildListTile(
              context: context,
              iconPath: 'assets/icons/lock.svg',
              title: 'Segurança e senha',
               onTap: () {
                 Navigator.push(
                   context,
                   MaterialPageRoute(builder: (context) => const SecurityPasswordPage()),
                 );
               },
            ),
            _buildListTile( 
              context: context,
              iconPath: 'assets/icons/credit_card.svg', // Use o ícone correto
              title: 'Formas de pagamento',
              onTap: () { /* TODO: Navegar */ },
            ),
            _buildListTile(
              context: context,
              iconPath: 'assets/icons/location_pin.svg', // Use o ícone correto
              title: 'Endereços',
              onTap: () { /* TODO: Navegar */ },
            ),
            _buildListTile(
              context: context,
              iconPath: 'assets/icons/document.svg', // Use o ícone correto
              title: 'Termos de uso',
              onTap: () { /* TODO: Navegar */ },
            ),
            _buildListTile(
              context: context,
              iconPath: 'assets/icons/policy.svg', // Use o ícone correto
              title: 'Política de privacidade',
              onTap: () { /* TODO: Navegar */ },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildListTile({
    required BuildContext context,
    required String iconPath,
    required String title,
    required VoidCallback onTap,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: AppSpacing.spacing8),
      decoration: BoxDecoration(
        color: AppColorsPrimary.primary100,
        borderRadius: AppRadius.radius12,
      ),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radius12),
        leading: SvgPicture.asset(
          iconPath,
          height: 22,
          width: 22,
          colorFilter: ColorFilter.mode(AppColorsPrimary.primary800, BlendMode.srcIn),
        ),
        title: Text(
          title,
          style: AppTypography.contentMedium.copyWith(color: AppColorsPrimary.primary950),
        ),
        trailing: SvgPicture.asset(
          'assets/icons/arrow_forward.svg', // Ícone de seta
          height: 20,
          colorFilter: ColorFilter.mode(AppColorsNeutral.neutral500, BlendMode.srcIn),
        ),
        onTap: onTap,
      ),
    );
  }

  

 Widget _buildLogoutButton(BuildContext context) {
    return InkWell(
      onTap: () {
        // TODO: Implementar lógica de Logout (ex: supabase.auth.signOut())
        print('Sair da conta');
      },
      borderRadius: AppRadius.radius12,
      child: Container(
         padding: const EdgeInsets.all(AppSpacing.spacing16),
         decoration: BoxDecoration(
           color: AppColorsError.error50.withOpacity(0.6), // Fundo vermelho claro
           borderRadius: AppRadius.radius12,
         ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Sair da conta',
              style: AppTypography.contentMedium.copyWith(color: AppColorsError.error700),
            ),
            SvgPicture.asset(
              'assets/icons/exit.svg',
              height: 22,
            ),
          ],
        ),
      ),
    );
 }

  Widget _buildSupportLinks(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
      children: [
        TextButton.icon(
          icon: SvgPicture.asset(
            'assets/icons/chat.svg', // Ícone de chat à esquerda
            height: 18,
            colorFilter: ColorFilter.mode(AppColorsPrimary.primary800, BlendMode.srcIn),
          ),
          label: Text(
            'Falar com suporte',
            style: AppTypography.captionMedium.copyWith(color: AppColorsPrimary.primary950),
          ),
          onPressed:
          () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const SupportPage()));
          }
        ),
        TextButton.icon(
          icon: SvgPicture.asset(
            'assets/icons/chat.svg', // Ícone de chat à esquerda
            height: 18,
            colorFilter: ColorFilter.mode(AppColorsPrimary.primary800, BlendMode.srcIn),
          ),
          label: Text(
            'Dúvidas frequentes',
            style: AppTypography.captionMedium.copyWith(color: AppColorsPrimary.primary950),
          ),
          onPressed: () {
            Navigator.push(context, MaterialPageRoute(builder: (context) => const FaqPage()));
          }
        ),
      ],
    );
  }
}