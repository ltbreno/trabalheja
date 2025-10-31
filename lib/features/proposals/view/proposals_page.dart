import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/proposals/widgets/received_proposal_card.dart';
import 'package:trabalheja/features/proposals/widgets/sent_proposal_card.dart';

// Enum para simular o tipo de conta do usuário
enum AccountType { client, freelancer }

class ProposalsPage extends StatefulWidget {
  const ProposalsPage({super.key});

  @override
  State<ProposalsPage> createState() => _ProposalsPageState();
}

class _ProposalsPageState extends State<ProposalsPage> {
  // --- LÓGICA DE TRANSIÇÃO (Conforme solicitado) ---
  //
  // TODO: Obter o tipo de conta (AccountType) do usuário logado (ex: Supabase, Provider).
  // Esta variável controlará qual tela será exibida.
  //
  // Exemplo:
  // final userProfile = Provider.of<UserProfile>(context);
  // final _currentAccountType = userProfile.isFreelancer ? AccountType.freelancer : AccountType.client;
  //
  // Para fins de layout, vamos definir um valor fixo:
  final AccountType _currentAccountType = AccountType.client; // Mude para .client para ver a outra tela

  // Estado para os filtros da tela de "Enviadas"
  List<bool> _selectedFilters = [true, false]; // [Aceitas, Rejeitadas]

  @override
  Widget build(BuildContext context) {
    // O Scaffold não tem BottomNavigationBar porque já está dentro do MainAppShell
    return Scaffold(
      backgroundColor: AppColorsPrimary.primary50,
      appBar: AppBar(
        // Usamos um PreferredSize para criar um "AppBar" customizado sem sombra
        elevation: 0,
        toolbarHeight: 120, // Altura para o título e subtítulo
        backgroundColor: Colors.transparent, // Fundo transparente
        flexibleSpace: Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.spacing24,
            right: AppSpacing.spacing24,
            top: 60, // Espaço para a status bar
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                // O título muda com base no tipo de conta
                _currentAccountType == AccountType.client
                    ? 'Propostas enviadas'
                    : 'Propostas recebidas',
                style: AppTypography.heading1.copyWith(
                  color: AppColorsPrimary.primary800, // Título Roxo
                ),
              ),
              const SizedBox(height: AppSpacing.spacing4),
              Text(
                // O subtítulo também muda
                _currentAccountType == AccountType.client
                    ? '00.000 propostas enviadas' // TODO: Puxar dados reais
                    : '00.000 propostas recebidas', // TODO: Puxar dados reais
                style: AppTypography.contentRegular.copyWith(
                  color: AppColorsNeutral.neutral500,
                ),
              ),
            ],
          ),
        ),
      ),
      body: _currentAccountType == AccountType.client
          ? _buildSentProposals(context) // Tela Cliente
          : _buildReceivedProposals(context), // Tela Freelancer
    );
  }

  // Constrói a UI para "Propostas Enviadas" (Cliente)
  Widget _buildSentProposals(BuildContext context) {
    return Column(
      children: [
        // Filtros "Aceitas" / "Rejeitadas"
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppSpacing.spacing24,
            vertical: AppSpacing.spacing16,
          ),
          child: Row(
            children: [
              Expanded(
                child: _buildFilterChip(
                  context,
                  text: 'Aceitas',
                  iconPath: 'assets/icons/checkmark.svg', // Crie este ícone
                  isSelected: _selectedFilters[0],
                  onTap: () => setState(() {
                    _selectedFilters = [true, false];
                    // TODO: Recarregar lista com filtro "Aceitas"
                  }),
                ),
              ),
              const SizedBox(width: AppSpacing.spacing16),
              Expanded(
                child: _buildFilterChip(
                  context,
                  text: 'Rejeitadas',
                  iconPath: 'assets/icons/close.svg', // Crie este ícone
                  isSelected: _selectedFilters[1],
                  onTap: () => setState(() {
                    _selectedFilters = [false, true];
                    // TODO: Recarregar lista com filtro "Rejeitadas"
                  }),
                ),
              ),
            ],
          ),
        ),

        // Lista de Propostas Enviadas
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.spacing24, 0,
              AppSpacing.spacing24, AppSpacing.spacing24,
            ),
            itemCount: 4, // TODO: Usar dados reais
            separatorBuilder: (context, index) =>
                const SizedBox(height: AppSpacing.spacing16),
            itemBuilder: (context, index) {
              // Exemplo de lógica de status
              final status = (index % 2 == 0)
                  ? ProposalStatus.rejected
                  : ProposalStatus.accepted;
              return SentProposalCard(  
                name: 'José Carlos Pereira da Silva Oliveira',
                location: 'Em 0.0km',
                price: 'R\$ 0.000,00',
                timeframe: 'Em até 00 horas',
                status: status,
              );
            },
          ),
        ),
      ],
    );
  }

  // Constrói a UI para "Propostas Recebidas" (Freelancer)
  Widget _buildReceivedProposals(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(AppSpacing.spacing24),
      itemCount: 3, // TODO: Usar dados reais
      separatorBuilder: (context, index) =>
          const SizedBox(height: AppSpacing.spacing16),
      itemBuilder: (context, index) {
        return ReceivedProposalCard(
          name: 'José Carlos Pereira da Silva Oliveira',
          location: 'Em 0.0km',
          price: 'R\$ 0.000,00',
          timeframe: 'Em até 00 horas',
          onAccept: () {
            // TODO: Lógica para aceitar proposta
            print('Proposta $index aceita');
          },
          onReject: () {
            // TODO: Lógica para rejeitar proposta
            print('Proposta $index rejeitada');
          },
        );
      },
    );
  }

  // Widget auxiliar para os botões de filtro
  Widget _buildFilterChip(
    BuildContext context, {
    required String text,
    required String iconPath,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return OutlinedButton.icon(
      onPressed: onTap,
      icon: SvgPicture.asset(
        iconPath,
        height: 16,
        colorFilter: ColorFilter.mode(
          isSelected
              ? (text == 'Aceitas' ? AppColorsSuccess.success600 : AppColorsError.error600)
              : AppColorsNeutral.neutral500,
          BlendMode.srcIn,
        ),
      ),
      label: Text(text),
      style: OutlinedButton.styleFrom(
        backgroundColor: isSelected
            ? (text == 'Aceitas' ? AppColorsSuccess.success50 : AppColorsError.error50)
            : AppColorsNeutral.neutral0,
        foregroundColor: isSelected
            ? (text == 'Aceitas' ? AppColorsSuccess.success700 : AppColorsError.error700)
            : AppColorsNeutral.neutral600,
        side: BorderSide(
          color: isSelected
              ? (text == 'Aceitas' ? AppColorsSuccess.success200 : AppColorsError.error200)
              : AppColorsNeutral.neutral200,
        ),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.radius8),
      ),
    );
  }
}
