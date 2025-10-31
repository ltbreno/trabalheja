import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';

class ProfileDataPage extends StatefulWidget {
  const ProfileDataPage({super.key});

  @override
  State<ProfileDataPage> createState() => _ProfileDataPageState();
}

class _ProfileDataPageState extends State<ProfileDataPage> {
  final _nameController = TextEditingController(text: 'José Carlos Pereira da Silva Oliveira');
  final _emailController = TextEditingController(text: 'umemaildojose@gmail.com');
  final _phoneController = TextEditingController(text: '(00) 00000-0000');
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = false;

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  void _saveChanges() {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);
    // TODO: Implementar lógica de atualização de perfil no Supabase
    // (ex: supabase.auth.updateUser(...) ou supabase.from('profiles').update(...))
    print('Salvando alterações...');
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Dados atualizados com sucesso!')),
      );
      Navigator.pop(context);
    });
  }

  void _addPhoto() {
    // TODO: Implementar lógica de image_picker
    print('Adicionar foto');
  }

  void _removePhoto() {
    // TODO: Implementar lógica de remoção
    print('Remover foto');
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
                  'Meus dados',
                  style: AppTypography.heading1.copyWith(
                    color: AppColorsNeutral.neutral900,
                  ),
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Seção Avatar
                _buildAvatarSection(),

                const SizedBox(height: AppSpacing.spacing32),

                // Campo Nome Completo
                AppTextField(
                  label: 'Nome completo',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  validator: (value) { /* ... Validação ... */ return null; },
                ),
                const SizedBox(height: AppSpacing.spacing16),

                // Campo E-mail
                AppTextField(
                  label: 'E-mail',
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  validator: (value) { /* ... Validação ... */ return null; },
                ),
                const SizedBox(height: AppSpacing.spacing16),
                
                // Campo Telefone
                AppTextField(
                  label: 'Telefone',
                  controller: _phoneController,
                  keyboardType: TextInputType.phone,
                  // Adicionar máscara se necessário
                  validator: (value) { /* ... Validação ... */ return null; },
                ),
                const SizedBox(height: AppSpacing.spacing32),

                // Botão Salvar
                _isLoading
                   ? const Center(child: CircularProgressIndicator())
                   : AppButton.primary(
                      text: 'Salvar alterações',
                      onPressed: _saveChanges,
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

  Widget _buildAvatarSection() {
    return Column(
      children: [
        CircleAvatar(
          radius: 40,
          backgroundColor: AppColorsPrimary.primary900,
          child: Text(
            'JC',
            style: AppTypography.heading2.copyWith(color: AppColorsNeutral.neutral0),
          ),
        ),
        const SizedBox(height: AppSpacing.spacing16),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextButton.icon(
              icon: SvgPicture.asset(
                'assets/icons/camera.svg', // Use o ícone correto
                height: 18,
                colorFilter: ColorFilter.mode(AppColorsPrimary.primary900, BlendMode.srcIn),
              ),
              label: Text(
                'Adicionar foto de perfil',
                style: AppTypography.captionMedium.copyWith(color: AppColorsPrimary.primary900),
              ),
              onPressed: _addPhoto,
            ),
            const SizedBox(width: AppSpacing.spacing16),
            TextButton.icon(
              icon: SvgPicture.asset(
                'assets/icons/trash.svg', // Use o ícone correto
                height: 18,
                colorFilter: ColorFilter.mode(AppColorsNeutral.neutral700, BlendMode.srcIn),
              ),
              label: Text(
                'Remover',
                 style: AppTypography.captionMedium.copyWith(color: AppColorsNeutral.neutral700),
              ),
              onPressed: _removePhoto,
            ),
          ],
        ),
      ],
    );
  }
}