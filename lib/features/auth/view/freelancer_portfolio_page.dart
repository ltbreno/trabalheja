// lib/features/auth/view/freelancer_portfolio_page.dart
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Para o ícone de upload
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/auth/view/freelancer_address_page.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';

// Importe a tela principal ou de dashboard
// import 'package:trabalheja/features/home/view/home_page.dart';

// Pacote para desenhar borda tracejada (adicione ao pubspec.yaml)
// import 'package:dotted_border/dotted_border.dart';

class FreelancerPortfolioPage extends StatefulWidget {
  // Receber dados das telas anteriores
  // final String fullName;
  // final String services;

  const FreelancerPortfolioPage({
    super.key,
    // required this.fullName,
    // required this.services,
  });

  @override
  State<FreelancerPortfolioPage> createState() => _FreelancerPortfolioPageState();
}

class _FreelancerPortfolioPageState extends State<FreelancerPortfolioPage> {

  void _selectPhotos() {
    // TODO: Implementar lógica para selecionar fotos usando image_picker
    print('Selecionar Fotos');
  }

  void _selectVideos() {
    // TODO: Implementar lógica para selecionar vídeos usando file_picker ou similar
    print('Selecionar Vídeos');
  }

  void _continue() async {
     print('Finalizando cadastro do freelancer...');
     // TODO:
     // 1. Fazer upload das fotos/vídeos selecionados para o Supabase Storage.
     // 2. Salvar/Atualizar o perfil do usuário na tabela 'profiles' com
     //    todos os dados coletados (nome, serviços, URLs do portfólio, etc.).

     Navigator.push(context, MaterialPageRoute(builder: (context) => FreelancerAddressPage()));
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
        child: SingleChildScrollView( // Permite rolagem
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.spacing16),
              Text(
                'Portfólio', // Título
                style: AppTypography.heading1.copyWith(
                  color: AppColorsNeutral.neutral900,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing8),
              Text(
                'Envie fotos e vídeos do seu trabalho para atrair novos clientes e aumentar a sua credibilidade.', // Subtítulo
                style: AppTypography.contentRegular.copyWith(
                  color: AppColorsNeutral.neutral600,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing32),

              // Seção Fotos
              _buildUploadSection(
                title: 'Fotos',
                description: 'Envie pelo menos 3 fotos\ndo seu trabalho',
                buttonText: 'Selecionar do dispositivo',
                allowedFormats: 'Arquivos em PNG ou JPG (Tamanho máximo 10Mb)',
                onSelect: _selectPhotos,
                uploadIconPath: 'assets/icons/cloud_upload.svg', // Crie este ícone
              ),

              const SizedBox(height: AppSpacing.spacing32),

              // Seção Vídeos
              _buildUploadSection(
                title: 'Vídeos',
                description: 'Envie pelos menos 2 vídeos\ndo seu trabalho',
                buttonText: 'Selecionar do dispositivo',
                allowedFormats: 'Arquivos em MP4, MOV ou AVI (Tamanho máximo 150Mb)',
                onSelect: _selectVideos,
                uploadIconPath: 'assets/icons/cloud_upload.svg', // Reutiliza o ícone
              ),

              const SizedBox(height: AppSpacing.spacing32),

              // Botão Continuar
               AppButton(
                      type: AppButtonType.primary,
                      text: 'Continuar',
                      onPressed: _continue, // Chama a função final
                      minWidth: double.infinity,
                    ),

              const SizedBox(height: AppSpacing.spacing16), // Espaço inferior
            ],
          ),
        ),
      ),
    );
  }

  // Widget auxiliar para as seções de upload
  Widget _buildUploadSection({
    required String title,
    required String description,
    required String buttonText,
    required String allowedFormats,
    required VoidCallback onSelect,
    required String uploadIconPath,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: AppTypography.highlightBold.copyWith(color: AppColorsNeutral.neutral800),
        ),
        const SizedBox(height: AppSpacing.spacing16),
        // Container tracejado - Usando Container normal como fallback
        // Para tracejado real, use o pacote dotted_border:
        // DottedBorder(
        //   color: AppColors.Neutral.neutral300,
        //   strokeWidth: 1,
        //   dashPattern: const [6, 4], // Ajuste o padrão do tracejado
        //   radius: AppRadius.radius12.topLeft, // Usar topLeft ou all()?
        //   borderType: BorderType.RRect,
        //   child: _buildUploadContent(...)
        // )
         Container(
           padding: const EdgeInsets.symmetric(
             vertical: AppSpacing.spacing24,
             horizontal: AppSpacing.spacing16,
           ),
           decoration: BoxDecoration(
             color: AppColorsNeutral.neutral50, // Fundo cinza claro
             borderRadius: BorderRadius.circular(AppSpacing.spacing12),
             border: Border.all(color: AppColorsNeutral.neutral200), // Borda sólida como fallback
           ),
           child: _buildUploadContent(
             uploadIconPath: uploadIconPath,
             description: description,
             buttonText: buttonText,
             onSelect: onSelect,
           ),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        Text(
          allowedFormats,
          style: AppTypography.footnoteRegular.copyWith(color: AppColorsNeutral.neutral500),
        ),
      ],
    );
  }

  // Conteúdo interno da área de upload
  Widget _buildUploadContent({
    required String uploadIconPath,
    required String description,
    required String buttonText,
    required VoidCallback onSelect,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            uploadIconPath,
            height: 32,
            width: 32,
            colorFilter: ColorFilter.mode(AppColorsNeutral.neutral400, BlendMode.srcIn),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Text(
            description,
            textAlign: TextAlign.center,
            style: AppTypography.captionRegular.copyWith(color: AppColorsNeutral.neutral600),
          ),
          const SizedBox(height: AppSpacing.spacing16),
          // Botão interno para selecionar
          ElevatedButton.icon(
            icon: SvgPicture.asset(
              'assets/icons/upload_file.svg', // Use um ícone apropriado (ou Icon)
              height: 16,
               colorFilter: ColorFilter.mode(AppColorsNeutral.neutral0, BlendMode.srcIn),
            ),
            label: Text(
              buttonText,
              style: AppTypography.captionBold.copyWith(color: AppColorsNeutral.neutral0),
            ),
            onPressed: onSelect,
            style: ElevatedButton.styleFrom(
               backgroundColor: AppColorsPrimary.primary800, // Cor do botão interno
               foregroundColor: AppColorsNeutral.neutral0,
               shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(AppSpacing.spacing8)),
               padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16, vertical: AppSpacing.spacing8),
            ),
          ),
        ],
      ),
    );
  }
}