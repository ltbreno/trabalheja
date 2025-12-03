import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/account/view/support_page.dart';
import 'package:trabalheja/core/auth/auth_state_notifier.dart';
import 'profile_data_page.dart'; // Importar a nova página
import 'security_password_page.dart'; // Importar a nova página
import 'faq_page.dart';
import 'addresses_page.dart';
import 'terms_of_service_page.dart';
import 'privacy_policy_page.dart';
import 'bank_account_page.dart'; // Dados bancários do freelancer

class AccountPage extends StatefulWidget {
  const AccountPage({super.key});

  @override
  State<AccountPage> createState() => _AccountPageState();
}

class _AccountPageState extends State<AccountPage> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _profileData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadProfileData();
  }

  Future<void> _loadProfileData() async {
    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        setState(() {
          _isLoading = false;
        });
        return;
      }

      final profile = await _supabase
          .from('profiles')
          .select('full_name, account_type, profile_picture_url, email')
          .eq('id', user.id)
          .maybeSingle();

      print('📋 [AccountPage] Dados do perfil carregados:');
      print('   - profile: $profile');
      print('   - full_name: ${profile?['full_name']}');
      print('   - account_type: ${profile?['account_type']}');

      setState(() {
        _profileData = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados do perfil: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  String _getInitials(String? fullName) {
    if (fullName == null || fullName.trim().isEmpty) return 'U';
    final parts = fullName.trim().split(' ');
    if (parts.length >= 2) {
      return '${parts[0][0]}${parts[parts.length - 1][0]}'.toUpperCase();
    }
    return fullName[0].toUpperCase();
  }

  String _getAccountTypeLabel(String? accountType) {
    if (accountType == null) return 'Usuário';
    return accountType == 'client' ? 'Cliente' : 'Freelancer';
  }

  @override
  Widget build(BuildContext context) {
    // Esta tela não tem AppBar própria, pois faz parte do MainAppShell
    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadProfileData,
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
      ),
    );
  }

  Widget _buildProfileHeader() {
    final fullName = _profileData?['full_name'] as String?;
    final accountType = _profileData?['account_type'] as String?;
    final profilePictureUrl = _profileData?['profile_picture_url'] as String?;
    
    // Usar o nome completo se disponível, caso contrário usar primeiro nome ou fallback
    String displayName;
    if (fullName != null && fullName.trim().isNotEmpty) {
      // Mostrar nome completo, ou pelo menos o primeiro nome se for muito longo
      final trimmedName = fullName.trim();
      displayName = trimmedName.length > 20 
          ? trimmedName.split(' ').first 
          : trimmedName;
    } else {
      displayName = 'Usuário';
    }
    
    final initials = _getInitials(fullName);
    final accountTypeLabel = _getAccountTypeLabel(accountType);

    return Row(
      children: [
        // Avatar
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColorsPrimary.primary900,
          backgroundImage: profilePictureUrl != null
              ? NetworkImage(profilePictureUrl)
              : null,
          child: profilePictureUrl == null
              ? Text(
                  initials,
                  style: AppTypography.heading4.copyWith(color: AppColorsNeutral.neutral0),
                )
              : null,
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
                displayName,
                style: AppTypography.highlightBold.copyWith(color: AppColorsNeutral.neutral900),
              ),
            ],
          ),
        ),
        // Tag Tipo de Conta
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
            accountTypeLabel,
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
            // Dados bancários - apenas para freelancers
            if (_profileData?['account_type'] == 'freelancer')
              _buildListTile(
                context: context,
                iconPath: 'assets/icons/credit_card.svg',
                title: 'Dados Bancários',
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => const BankAccountPage()),
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
              iconPath: 'assets/icons/location_pin.svg',
              title: 'Endereços',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const AddressesPage()),
                );
              },
            ),
            _buildListTile(
              context: context,
              iconPath: 'assets/icons/document.svg',
              title: 'Termos de uso',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const TermsOfServicePage()),
                );
              },
            ),
            _buildListTile(
              context: context,
              iconPath: 'assets/icons/policy.svg',
              title: 'Política de privacidade',
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const PrivacyPolicyPage()),
                );
              },
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
      onTap: () async {
        // Mostrar diálogo de confirmação
        final shouldLogout = await showDialog<bool>(
          context: context,
          builder: (context) => AlertDialog(
            title: Text(
              'Sair da conta',
              style: AppTypography.highlightBold.copyWith(
                color: AppColorsNeutral.neutral900,
              ),
            ),
            content: Text(
              'Tem certeza que deseja sair da sua conta?',
              style: AppTypography.contentRegular.copyWith(
                color: AppColorsNeutral.neutral700,
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: Text(
                  'Cancelar',
                  style: AppTypography.contentMedium.copyWith(
                    color: AppColorsNeutral.neutral600,
                  ),
                ),
              ),
              TextButton(
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(
                  'Sair',
                  style: AppTypography.contentMedium.copyWith(
                    color: AppColorsError.error600,
                  ),
                ),
              ),
            ],
          ),
        );

        if (shouldLogout != true) return;

        try {
          // Limpar dados da sessão e fazer logout
          await _supabase.auth.signOut();
          
          // Notificar mudança de autenticação para forçar atualização
          final authNotifier = AuthStateNotifier();
          authNotifier.notifyAuthChange();
          
          // O AuthWrapper detectará automaticamente a mudança de estado
          // e redirecionará para LoginPage
        } catch (e) {
          if (context.mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Erro ao sair: ${e.toString()}'),
                backgroundColor: AppColorsError.error600,
              ),
            );
          }
        }
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