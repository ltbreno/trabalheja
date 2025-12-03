import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/review/view/review_service_success_page.dart';
import '../widgets/star_rating_widget.dart'; // Importar o widget de estrelas

class ReviewServicePage extends StatefulWidget {
  const ReviewServicePage({super.key});

  @override
  State<ReviewServicePage> createState() => _ReviewServicePageState();
}

class _ReviewServicePageState extends State<ReviewServicePage> {
  final _commentsController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;
  int _currentRating = 0; // Estado para guardar a nota

  @override
  void dispose() {
    _commentsController.dispose();
    super.dispose();
  }

  void _submitReview() {
     if (!(_formKey.currentState?.validate() ?? false)) return;
     if (_currentRating == 0) {
       ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, selecione uma nota de 1 a 5.')),
      );
       return;
     }

     setState(() => _isLoading = true);
     // TODO: Implementar lógica de envio da avaliação (Supabase)
     print('Enviando avaliação...');
     print('Nota: $_currentRating');
     print('Comentário: ${_commentsController.text}');

     Future.delayed(const Duration(seconds: 1), () {
        if (mounted) setState(() => _isLoading = false);
        Navigator.push(context, MaterialPageRoute(builder: (context) => ReviewServiceSuccessPage())); // Volta para a tela anterior
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
                Text(
                  'Avalie o serviço prestado',
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsPrimary.primary900, // Cor roxa
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing8),
                Text(
                  'Compartilhe conosco como foi sua experiência com o serviço prestado pelo freelancer',
                  style: AppTypography.contentRegular.copyWith(
                    color: AppColorsNeutral.neutral600,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Informações do Freelancer (Mockado)
                _buildFreelancerInfo(),

                const SizedBox(height: AppSpacing.spacing24),
                
                // Classificação por Estrelas
                Text(
                  'O que você achou do serviço?',
                  style: AppTypography.highlightBold.copyWith(color: AppColorsNeutral.neutral800),
                ),
                Text(
                  'Escolha de 1 a 5 estrelas para classificar',
                  style: AppTypography.captionRegular.copyWith(color: AppColorsNeutral.neutral600),
                ),
                const SizedBox(height: AppSpacing.spacing16),
                StarRatingWidget(
                  onRatingChanged: (rating) {
                    setState(() {
                      _currentRating = rating;
                    });
                  },
                ),
                const SizedBox(height: AppSpacing.spacing24),

                // Comentários Adicionais
                AppTextField(
                  label: 'Comentários adicionais',
                  hintText: 'Deixe uma mensagem extra sobre sua experiência com o freelancer',
                  controller: _commentsController,
                  keyboardType: TextInputType.multiline,
                  minLines: 4,
                  maxLines: 6,
                   // Validação opcional
                  // validator: (value) => (value == null || value.isEmpty) ? 'Campo obrigatório' : null,
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Botão Enviar
                _isLoading
                   ? const Center(child: CircularProgressIndicator())
                   : AppButton.primary(
                      text: 'Enviar avaliação',
                      onPressed: _submitReview,
                      minWidth: double.infinity,
                    ),
                const SizedBox(height: AppSpacing.spacing16),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para info do freelancer (mockado)
  Widget _buildFreelancerInfo() {
     return Column(
       crossAxisAlignment: CrossAxisAlignment.start,
       children: [
         Text(
           'Informações do freelancer',
           style: AppTypography.highlightBold.copyWith(color: AppColorsNeutral.neutral800),
         ),
         const SizedBox(height: AppSpacing.spacing8),
          // Usando o widget que criamos para Propostas
          // ProposalInfoTile(
          //   iconPath: 'assets/icons/account.svg',
          //   text: 'José Carlos Pereira da Silva Oliveira',
          //   style: AppTypography.contentMedium.copyWith(color: AppColorsNeutral.neutral800),
          // ),
          Row(
            children: [
               SvgPicture.asset(
                  'assets/icons/people.svg',
                  height: 18, width: 18,
                  colorFilter: ColorFilter.mode(AppColorsNeutral.neutral500, BlendMode.srcIn),
                ),
                const SizedBox(width: AppSpacing.spacing8),
                Text(
                  'José Carlos Pereira da Silva Oliveira',
                   style: AppTypography.contentMedium.copyWith(color: AppColorsNeutral.neutral800),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing8),
           Row(
            children: [
               SvgPicture.asset(
                  'assets/icons/credit_card.svg',
                  height: 18, width: 18,
                  colorFilter: ColorFilter.mode(AppColorsNeutral.neutral500, BlendMode.srcIn),
                ),
                const SizedBox(width: AppSpacing.spacing8),
                Text(
                  'R\$ 0.000,00',
                   style: AppTypography.contentMedium.copyWith(color: AppColorsNeutral.neutral800),
                ),
            ],
          ),
       ],
     );
  }
}
