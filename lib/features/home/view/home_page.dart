import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/proposals/view/proposals_page.dart';
import 'package:trabalheja/features/review/view/review_service_page.dart';
import 'package:trabalheja/features/service_request/view/request_service_page.dart';
import 'package:trabalheja/features/home/view/freelancer_dashboard_page.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
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
          .select('full_name, account_type, profile_picture_url, service_latitude, service_longitude, service_radius')
          .eq('id', user.id)
          .maybeSingle();

      print('📋 [HomePage] Dados do perfil carregados:');
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

  @override
  Widget build(BuildContext context) {
    final accountType = _profileData?['account_type'] as String?;
    
    // Se for freelancer, mostrar dashboard do freelancer
    if (accountType == 'freelancer') {
      return const FreelancerDashboardPage();
    }
    
    // Dashboard padrão para clientes
    return Scaffold(
      backgroundColor: AppColorsPrimary.primary50,
      body: SafeArea(
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadProfileData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.spacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: AppSpacing.spacing16),
                      _buildProfileHeader(),
                      const SizedBox(height: AppSpacing.spacing32),
                      
                      _buildDashboardItem(
                        context: context,
                        iconPath: 'assets/icons/freelancer.svg', // Crie este ícone
                        title: 'Solicitar freelancer',
                        subtitle: 'Precisa de um serviço? Solicite um freelancer agora e receba propostas',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RequestServicePage()),
                          );
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.spacing16),
                      _buildDashboardItem(
                        context: context,
                        iconPath: 'assets/icons/document.svg', // Reutilizar ícone
                        title: 'Propostas recebidas',
                        subtitle: 'Acompanhe as propostas enviadas pelos freelancers',
                        onTap: () {
                          // TODO: Navegar para a tela de Propostas Recebidas
                          // Se ProposalsPage estiver no MainAppShell, talvez mudar o índice
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ProposalsPage()), // Assumindo que ProposalsPage lida com a lógica de Cliente
                          );
                        },
                      ),
                      
                      const SizedBox(height: AppSpacing.spacing16),
                      _buildDashboardItem(
                        context: context,
                        iconPath: 'assets/icons/star.svg', // Crie este ícone
                        title: 'Avaliar serviços',
                        subtitle: 'Avalie serviços realizados pelos freelancers',
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const ReviewServicePage()), // Navega para a tela de avaliação
                          );
                        },
                      ),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildProfileHeader() {
    final fullName = _profileData?['full_name'] as String?;
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

    return Row(
      children: [
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
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Bem-vindo,',
              style: AppTypography.captionRegular.copyWith(color: AppColorsNeutral.neutral600),
            ),
            Text(
              displayName,
              style: AppTypography.highlightBold.copyWith(color: AppColorsNeutral.neutral900),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildDashboardItem({
    required BuildContext context,
    required String iconPath,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: AppRadius.radius12,
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.spacing16),
        decoration: BoxDecoration(
          color: AppColorsNeutral.neutral0,
          borderRadius: AppRadius.radius12,
          border: Border.all(color: AppColorsNeutral.neutral100),
          boxShadow: [
            BoxShadow(
              color: AppColorsNeutral.neutral100.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ],
        ),
        child: Row(
          children: [
            SvgPicture.asset(
              iconPath,
              height: 24,
              width: 24,
              colorFilter: ColorFilter.mode(AppColorsPrimary.primary900, BlendMode.srcIn),
            ),
            const SizedBox(width: AppSpacing.spacing12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: AppTypography.highlightBold.copyWith(color: AppColorsNeutral.neutral900),
                  ),
                  const SizedBox(height: AppSpacing.spacing4),
                  Text(
                    subtitle,
                    style: AppTypography.captionRegular.copyWith(color: AppColorsNeutral.neutral600),
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
