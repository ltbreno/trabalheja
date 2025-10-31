import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';

class FaqPage extends StatefulWidget {
  const FaqPage({super.key});

  @override
  State<FaqPage> createState() => _FaqPageState();
}

class _FaqPageState extends State<FaqPage> {
  final _searchController = TextEditingController();
  late List<bool> _expanded;

  // Lista de perguntas de exemplo
  final List<String> _faqList = [
    'Qual o prazo para realização do serviço?',
    'Qual o prazo para realização do serviço?',
    'Como cancelar um serviço já agendado com um freelancer?',
    'Como cancelar um serviço já agendado com um freelancer?',
    'Como cancelar um serviço já agendado com um freelancer?',
    'Como cancelar um serviço já agendado com um freelancer?',
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _expanded = List<bool>.filled(_faqList.length, false);
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
            color: AppColorsPrimary.primary900,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.spacing16),
              // Ícone de check
              Center(
               child: Icon(
                    Icons.check_circle,
                    color: AppColorsSuccess.success500,
                    size: 60,
                  ),
              ),
              const SizedBox(height: AppSpacing.spacing16),
              // Título
              Text(
                'Dúvidas frequentes',
                textAlign: TextAlign.center,
                style: AppTypography.heading1.copyWith(
                  color: AppColorsPrimary.primary900, // Cor roxa
                ),
              ),
              const SizedBox(height: AppSpacing.spacing32),

              // Campo de Busca
              AppTextField(
                label: 'Qual sua dúvida ou problema?',
                hintText: 'Pesquisar',
                controller: _searchController,
                keyboardType: TextInputType.text,
                prefixIconPath: 'assets/icons/search.svg', // Ícone de busca
                textColor: AppColorsPrimary.primary900,
                iconColor: AppColorsPrimary.primary800,
                // validator: (value) { ... }, // Validação não usual para busca
                onChanged: (value) {
                  // TODO: Implementar lógica de filtro da lista
                  print('Buscando por: $value');
                },
              ),
              const SizedBox(height: AppSpacing.spacing24),

              // Lista de Perguntas
              ListView.separated(
                physics: const NeverScrollableScrollPhysics(), // Desabilita scroll da lista
                shrinkWrap: true, // Encolhe para caber na Column
                itemCount: _faqList.length,
                itemBuilder: (context, index) {
                  return _buildFaqItem(_faqList[index], index);
                },
                separatorBuilder: (context, index) =>
                    const SizedBox(height: AppSpacing.spacing12),
              ),

              const SizedBox(height: AppSpacing.spacing16),
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para cada item da lista de FAQ
  Widget _buildFaqItem(String title, int index) {
    final bool isExpanded = _expanded[index];
    return InkWell(
      onTap: () {
        setState(() {
          _expanded[index] = !isExpanded;
        });
      },
      borderRadius: AppRadius.radius12,
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.spacing16,
          vertical: AppSpacing.spacing16,
        ),
        decoration: BoxDecoration(
          color: AppColorsNeutral.neutral0,
          borderRadius: AppRadius.radius12,
          border: Border.all(color: AppColorsNeutral.neutral100, width: 1.0),
          boxShadow: [
             BoxShadow(
              color: AppColorsNeutral.neutral100.withOpacity(0.5),
              blurRadius: 4,
              offset: const Offset(0, 2),
            )
          ]
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: AppTypography.contentMedium.copyWith(color: AppColorsPrimary.primary900),
                  ),
                ),
                const SizedBox(width: AppSpacing.spacing16),
                AnimatedRotation(
                  turns: isExpanded ? 0.25 : 0.0, // 90 graus quando aberto
                  duration: const Duration(milliseconds: 180),
                  child: SvgPicture.asset(
                    'assets/icons/arrow_forward.svg',
                    height: 16,
                    colorFilter: ColorFilter.mode(AppColorsPrimary.primary800, BlendMode.srcIn),
                  ),
                ),
              ],
            ),
            if (isExpanded) ...[
              const SizedBox(height: AppSpacing.spacing12),
              Text(
                'Resposta da pergunta selecionada. Em breve, conteúdo real.',
                style: AppTypography.captionRegular.copyWith(color: AppColorsPrimary.primary900),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
