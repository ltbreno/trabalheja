import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
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
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _phoneController = TextEditingController();
  final _formKey = GlobalKey<FormState>();
  final _supabase = Supabase.instance.client;
  final _imagePicker = ImagePicker();
  bool _isLoading = false;
  bool _isLoadingData = true;
  bool _isUploadingPhoto = false;
  String? _profilePictureUrl;
  XFile? _selectedImage;

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
          _isLoadingData = false;
        });
        return;
      }

      final profile = await _supabase
          .from('profiles')
          .select('full_name, email, phone, profile_picture_url')
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        _nameController.text = profile?['full_name'] as String? ?? '';
        _emailController.text = profile?['email'] as String? ?? user.email ?? '';
        _phoneController.text = profile?['phone'] as String? ?? '';
        _profilePictureUrl = profile?['profile_picture_url'] as String?;
        _isLoadingData = false;
      });
    } catch (e) {
      print('Erro ao carregar dados do perfil: $e');
      setState(() {
        _isLoadingData = false;
      });
    }
  }

  Future<void> _saveChanges() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Atualizar perfil no Supabase
      await _supabase.from('profiles').update({
        'full_name': _nameController.text.trim(),
        'email': _emailController.text.trim(),
        'phone': _phoneController.text.trim(),
      }).eq('id', user.id);

      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Dados atualizados com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoading = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao atualizar dados: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
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

  Future<void> _addPhoto() async {
    try {
      // Mostrar opções: Câmera ou Galeria
      final ImageSource? source = await showModalBottomSheet<ImageSource>(
        context: context,
        builder: (context) => SafeArea(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              ListTile(
                leading: const Icon(Icons.camera_alt),
                title: const Text('Tirar foto'),
                onTap: () => Navigator.pop(context, ImageSource.camera),
              ),
              ListTile(
                leading: const Icon(Icons.photo_library),
                title: const Text('Escolher da galeria'),
                onTap: () => Navigator.pop(context, ImageSource.gallery),
              ),
              ListTile(
                leading: const Icon(Icons.cancel),
                title: const Text('Cancelar'),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        ),
      );

      if (source == null) return;

      final XFile? pickedFile = await _imagePicker.pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1024,
        maxHeight: 1024,
      );

      if (pickedFile != null) {
        // Validar tamanho (máximo 5MB)
        final file = File(pickedFile.path);
        final sizeInMB = await file.length() / (1024 * 1024);
        const maxSizeMB = 5;

        if (sizeInMB > maxSizeMB) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('A foto excede o tamanho máximo de ${maxSizeMB}MB.'),
                backgroundColor: Colors.red,
              ),
            );
          }
          return;
        }

        setState(() {
          _selectedImage = pickedFile;
        });

        // Fazer upload imediatamente
        await _uploadPhoto();
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  Future<void> _uploadPhoto() async {
    if (_selectedImage == null) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      final fileExtension = _selectedImage!.path.split('.').last.toLowerCase();
      final fileName = '${user.id}/profile_picture.$fileExtension';

      // Determinar contentType
      String contentType;
      if (fileExtension == 'png') {
        contentType = 'image/png';
      } else if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
        contentType = 'image/jpeg';
      } else {
        contentType = 'image/jpeg';
      }

      final imageFile = File(_selectedImage!.path);

      // Fazer upload
      await _supabase.storage
          .from('profiles')
          .upload(
            fileName,
            imageFile,
            fileOptions: FileOptions(
              contentType: contentType,
              upsert: true,
            ),
          );

      // Obter URL pública
      final imageUrl = _supabase.storage
          .from('profiles')
          .getPublicUrl(fileName);

      // Atualizar perfil com a URL da imagem
      await _supabase.from('profiles').update({
        'profile_picture_url': imageUrl,
      }).eq('id', user.id);

      setState(() {
        _profilePictureUrl = imageUrl;
        _selectedImage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil atualizada com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao fazer upload da foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
    }
  }

  Future<void> _removePhoto() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Remover foto'),
        content: const Text('Tem certeza que deseja remover sua foto de perfil?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancelar'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Remover', style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );

    if (confirm != true) return;

    setState(() => _isUploadingPhoto = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Remover URL do perfil
      await _supabase.from('profiles').update({
        'profile_picture_url': null,
      }).eq('id', user.id);

      setState(() {
        _profilePictureUrl = null;
        _selectedImage = null;
      });

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Foto de perfil removida com sucesso!'),
            backgroundColor: Colors.green,
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao remover foto: ${e.toString()}'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isUploadingPhoto = false);
      }
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
        child: _isLoadingData
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
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
    final initials = _getInitials(_nameController.text);
    ImageProvider? imageToShow;
    if (_selectedImage != null) {
      imageToShow = FileImage(File(_selectedImage!.path));
    } else if (_profilePictureUrl != null) {
      imageToShow = NetworkImage(_profilePictureUrl!);
    }

    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing16),
      decoration: BoxDecoration(
        color: AppColorsPrimary.primary100,
        borderRadius: AppRadius.radius12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Stack(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColorsPrimary.primary900,
                backgroundImage: imageToShow,
                child: imageToShow == null
                ? Text(
                    initials,
                    style: AppTypography.heading4.copyWith(color: AppColorsNeutral.neutral0),
                  )
                : null,
              ),
              if (_isUploadingPhoto)
                Positioned.fill(
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black54,
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(width: AppSpacing.spacing16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: SvgPicture.asset(
                    'assets/icons/camera.svg',
                    height: 18,
                    colorFilter: ColorFilter.mode(AppColorsPrimary.primary900, BlendMode.srcIn),
                  ),
                  label: Text(
                    'Adicionar foto de perfil',
                    style: AppTypography.captionMedium.copyWith(
                      color: AppColorsPrimary.primary900,
                      decoration: TextDecoration.underline,
                    ),
                  ),
                  onPressed: _isUploadingPhoto ? null : _addPhoto,
                ),
                const SizedBox(height: AppSpacing.spacing12),
                TextButton.icon(
                  style: TextButton.styleFrom(
                    padding: EdgeInsets.zero,
                    minimumSize: const Size(0, 0),
                    tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                  ),
                  icon: SvgPicture.asset(
                    'assets/icons/trash.svg',
                    height: 18,
                    colorFilter: ColorFilter.mode(AppColorsNeutral.neutral700, BlendMode.srcIn),
                  ),
                  label: Text(
                    'Remover',
                    style: AppTypography.captionMedium.copyWith(
                      color: AppColorsNeutral.neutral700,
                    ),
                  ),
                  onPressed: (_isUploadingPhoto || _profilePictureUrl == null) ? null : _removePhoto,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}