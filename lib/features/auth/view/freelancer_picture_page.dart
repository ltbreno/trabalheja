// lib/features/auth/view/freelancer_picture_page.dart
import 'dart:io'; // Para usar File
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart'; // Importar image_picker
import 'package:dotted_border/dotted_border.dart'; // Importar dotted_border
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';

class FreelancerPicturePage extends StatefulWidget {
  // Receber dados das telas anteriores
  // final String fullName;
  // final Map<String, dynamic> addressData;
  // final String radius;

  const FreelancerPicturePage({
    super.key,
    // required this.fullName,
    // required this.addressData,
    // required this.radius,
  });

  @override
  State<FreelancerPicturePage> createState() => _FreelancerPicturePageState();
}

class _FreelancerPicturePageState extends State<FreelancerPicturePage> {
  bool _isLoading = false;
  XFile? _imageFile; // Para armazenar a imagem selecionada
  final ImagePicker _picker = ImagePicker();

  // Função para selecionar imagem da galeria
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Comprimir um pouco a imagem
      );
      if (pickedFile != null) {
        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      print('Erro ao selecionar imagem: $e');
      // Mostrar SnackBar de erro
    }
  }

  void _finalizeRegistration() async {
    if (_imageFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, envie uma foto de perfil.')),
      );
      return;
    }

    setState(() => _isLoading = true);

    // TODO:
    // 1. Fazer upload da imagem (_imageFile.path) para o Supabase Storage
    //    e obter a URL pública.
    // 2. Salvar/Atualizar o perfil do usuário na tabela 'profiles' com
    //    todos os dados coletados (nome, endereço, raio, e a URL da foto).
    // 3. (Opcional) Salvar os dados do cadastro original (auth.signUp)
    //    neste ponto, se ainda não foi feito.

    print('Finalizando cadastro com todos os dados...');
    await Future.delayed(const Duration(seconds: 2)); // Simular

    if (mounted) {
      setState(() => _isLoading = false);
      // TODO: Navegar para a tela principal/dashboard
      // Navigator.of(context).pushAndRemoveUntil(...)
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro finalizado com sucesso!')),
      );
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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.spacing16),
              Text(
                'Foto de perfil', // Título
                style: AppTypography.heading1.copyWith(
                  color: AppColorsNeutral.neutral900,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing8),
              Text(
                'Envie uma foto de perfil. É importante que seu rosto esteja visível.', // Subtítulo
                style: AppTypography.contentRegular.copyWith(
                  color: AppColorsNeutral.neutral600,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing32),

              // Seção Foto de Perfil
              Text(
                'Foto de perfil',
                style: AppTypography.highlightBold.copyWith(color: AppColorsNeutral.neutral800),
              ),
              const SizedBox(height: AppSpacing.spacing16),
              
              // Área de Upload Tracejada
              DottedBorder(

                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(
                    vertical: AppSpacing.spacing32,
                    horizontal: AppSpacing.spacing16,
                  ),
                  decoration: BoxDecoration(
                    color: AppColorsPrimary.primary50.withOpacity(0.5), // Fundo roxo bem claro
                    borderRadius: AppRadius.radius12,
                  ),
                  // Conteúdo muda se a imagem foi selecionada
                  child: _imageFile == null
                      ? _buildUploadPrompt() // Mostra o prompt
                      : _buildImagePreview(), // Mostra a imagem
                ),
              ),
              const SizedBox(height: AppSpacing.spacing8),
              Text(
                'Arquivos em PNG ou JPG (Tamanho máximo 10Mb)',
                style: AppTypography.footnoteRegular.copyWith(color: AppColorsNeutral.neutral500),
              ),

              const SizedBox(height: AppSpacing.spacing48), // Mais espaço

              // Botão Finalizar cadastro
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton.primary(
                      text: 'Finalizar cadastro',
                      onPressed: _finalizeRegistration,
                      minWidth: double.infinity,
                    ),
              const SizedBox(height: AppSpacing.spacing16),
            ],
          ),
        ),
      ),
    );
  }

  // Widget para o prompt de upload
  Widget _buildUploadPrompt() {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        SvgPicture.asset(
          'assets/icons/cloud_upload.svg', // Ícone de nuvem
          height: 32,
          width: 32,
          colorFilter: ColorFilter.mode(AppColorsPrimary.primary700, BlendMode.srcIn),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        Text(
          'Envie sua foto de perfil',
          textAlign: TextAlign.center,
          style: AppTypography.captionRegular.copyWith(color: AppColorsPrimary.primary900),
        ),
        const SizedBox(height: AppSpacing.spacing16),
        ElevatedButton.icon(
          icon: SvgPicture.asset(
            'assets/icons/upload_file.svg', // Ícone de upload
            height: 16,
            colorFilter: ColorFilter.mode(AppColorsNeutral.neutral0, BlendMode.srcIn),
          ),
          label: Text(
            'Selecionar do dispositivo',
            style: AppTypography.captionBold.copyWith(color: AppColorsNeutral.neutral0),
          ),
          onPressed: _pickImage,
          style: ElevatedButton.styleFrom(
            backgroundColor: AppColorsPrimary.primary900, // Botão roxo
            foregroundColor: AppColorsPrimary.primary200, // Splash
            shape: RoundedRectangleBorder(borderRadius: AppRadius.radius8),
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16, vertical: AppSpacing.spacing8),
          ),
        ),
      ],
    );
  }

  // Widget para mostrar a imagem selecionada
  Widget _buildImagePreview() {
    return Column(
      children: [
        ClipRRect( // Mostra a imagem como um círculo
          borderRadius: AppRadius.radiusRound,
          child: Image.file(
            File(_imageFile!.path),
            width: 120, // Tamanho do preview
            height: 120,
            fit: BoxFit.cover,
          ),
        ),
        const SizedBox(height: AppSpacing.spacing16),
        TextButton( // Botão para trocar a imagem
          onPressed: _pickImage,
          child: Text(
            'Trocar foto',
             style: AppTypography.contentMedium.copyWith(
              color: AppColorsPrimary.primary800,
              decoration: TextDecoration.underline,
              decorationColor: AppColorsPrimary.primary800,
            ),
          ),
        )
      ],
    );
  }
}