// lib/features/auth/view/freelancer_portfolio_page.dart
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/auth/view/freelancer_address_page.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';

class FreelancerPortfolioPage extends StatefulWidget {
  const FreelancerPortfolioPage({
    super.key,
  });

  @override
  State<FreelancerPortfolioPage> createState() => _FreelancerPortfolioPageState();
}

class _FreelancerPortfolioPageState extends State<FreelancerPortfolioPage> {
  final _supabase = Supabase.instance.client;
  final ImagePicker _picker = ImagePicker();
  
  List<XFile> _selectedPhotos = [];
  List<XFile> _selectedVideos = [];
  bool _isLoading = false;

  // Limites
  static const int maxPhotos = 3;
  static const int minPhotos = 1;
  static const int maxVideos = 2;
  static const int minVideos = 0;
  static const int maxPhotoSizeMB = 10;
  static const int maxVideoSizeMB = 150;

  Future<void> _selectPhotos() async {
    try {
      final List<XFile> photos = await _picker.pickMultiImage();
      
      if (photos.isEmpty) return;

      // Verificar quantas fotos podem ser adicionadas
      final int remainingSlots = maxPhotos - _selectedPhotos.length;
      if (remainingSlots <= 0) {
        _showError('Você já selecionou o máximo de $maxPhotos fotos.');
        return;
      }

      // Adicionar apenas as fotos que cabem no limite
      final List<XFile> photosToAdd = photos.take(remainingSlots).toList();
      
      // Validar tamanho de cada foto
      for (final photo in photosToAdd) {
        final file = File(photo.path);
        final sizeInMB = await file.length() / (1024 * 1024);
        if (sizeInMB > maxPhotoSizeMB) {
          _showError('A foto "${photo.name}" excede o tamanho máximo de ${maxPhotoSizeMB}MB.');
          return;
        }
      }

      setState(() {
        _selectedPhotos.addAll(photosToAdd);
      });

      if (photos.length > remainingSlots) {
        _showInfo('Apenas ${remainingSlots} foto(s) foram adicionadas (máximo de $maxPhotos).');
      }
    } catch (e) {
      _showError('Erro ao selecionar fotos: ${e.toString()}');
    }
  }

  Future<void> _selectVideos() async {
    try {
      final XFile? video = await _picker.pickVideo(
        source: ImageSource.gallery,
      );
      
      if (video == null) return;

      // Verificar limite
      if (_selectedVideos.length >= maxVideos) {
        _showError('Você já selecionou o máximo de $maxVideos vídeos.');
        return;
      }

      // Validar tamanho
      final file = File(video.path);
      final sizeInMB = await file.length() / (1024 * 1024);
      if (sizeInMB > maxVideoSizeMB) {
        _showError('O vídeo "${video.name}" excede o tamanho máximo de ${maxVideoSizeMB}MB.');
        return;
      }

      setState(() {
        _selectedVideos.add(video);
      });
    } catch (e) {
      _showError('Erro ao selecionar vídeo: ${e.toString()}');
    }
  }

  void _removePhoto(int index) {
    setState(() {
      _selectedPhotos.removeAt(index);
    });
  }

  void _removeVideo(int index) {
    setState(() {
      _selectedVideos.removeAt(index);
    });
  }

  bool _validateFiles() {
    if (_selectedPhotos.length < minPhotos) {
      _showError('Você precisa selecionar pelo menos $minPhotos fotos.');
      return false;
    }
    if (_selectedVideos.length < minVideos) {
      _showError('Você precisa selecionar pelo menos $minVideos vídeos.');
      return false;
    }
    return true;
  }

  Future<void> _continue() async {
    if (!_validateFiles()) return;

    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // Upload das fotos
      final List<String> photoUrls = [];
      for (int i = 0; i < _selectedPhotos.length; i++) {
        final photo = _selectedPhotos[i];
        final fileExtension = photo.path.split('.').last.toLowerCase();
        final fileName = '${user.id}/portfolio/photo_${i + 1}.$fileExtension';
        
        final contentType = fileExtension == 'png' ? 'image/png' : 'image/jpeg';
        final file = File(photo.path);

        try {
          await _supabase.storage
              .from('profiles')
              .upload(
                fileName,
                file,
                fileOptions: FileOptions(
                  contentType: contentType,
                  upsert: true,
                ),
              );

          final url = _supabase.storage
              .from('profiles')
              .getPublicUrl(fileName);
          
          photoUrls.add(url);
        } catch (uploadError) {
          print('❌ Erro no upload da foto ${i + 1}: $uploadError');
          // Se for erro 403, dar mensagem mais específica
          final errorString = uploadError.toString().toLowerCase();
          if (errorString.contains('403') || errorString.contains('forbidden') || errorString.contains('permission')) {
            throw Exception('Erro de permissão: Verifique as políticas do Storage no Supabase. O usuário precisa ter permissão para fazer upload na pasta ${user.id}/portfolio/');
          }
          rethrow;
        }
      }

      // Upload dos vídeos
      final List<String> videoUrls = [];
      for (int i = 0; i < _selectedVideos.length; i++) {
        final video = _selectedVideos[i];
        final fileExtension = video.path.split('.').last.toLowerCase();
        final fileName = '${user.id}/portfolio/video_${i + 1}.$fileExtension';
        
        final contentType = _getVideoContentType(fileExtension);
        final file = File(video.path);

        try {
          await _supabase.storage
              .from('profiles')
              .upload(
                fileName,
                file,
                fileOptions: FileOptions(
                  contentType: contentType,
                  upsert: true,
                ),
              );

          final url = _supabase.storage
              .from('profiles')
              .getPublicUrl(fileName);
          
          videoUrls.add(url);
        } catch (uploadError) {
          print('❌ Erro no upload do vídeo ${i + 1}: $uploadError');
          // Se for erro 403, dar mensagem mais específica
          final errorString = uploadError.toString().toLowerCase();
          if (errorString.contains('403') || errorString.contains('forbidden') || errorString.contains('permission')) {
            throw Exception('Erro de permissão: Verifique as políticas do Storage no Supabase. O usuário precisa ter permissão para fazer upload na pasta ${user.id}/portfolio/');
          }
          rethrow;
        }
      }

      // Atualizar perfil com as URLs
      await _supabase.from('profiles').update({
        'portfolio_photos': photoUrls,
        'portfolio_videos': videoUrls,
      }).eq('id', user.id);

      if (!mounted) return;

      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const FreelancerAddressPage()),
      );
    } catch (e) {
      if (!mounted) return;
      _showError('Erro ao fazer upload: ${e.toString()}');
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  String _getVideoContentType(String extension) {
    switch (extension.toLowerCase()) {
      case 'mp4':
        return 'video/mp4';
      case 'mov':
        return 'video/quicktime';
      case 'avi':
        return 'video/x-msvideo';
      default:
        return 'video/mp4';
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColorsError.error600,
        duration: const Duration(seconds: 4),
      ),
    );
  }

  void _showInfo(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: AppColorsNeutral.neutral600,
        duration: const Duration(seconds: 3),
      ),
    );
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
              _buildPhotoSection(),

              const SizedBox(height: AppSpacing.spacing32),

              // Seção Vídeos
              _buildVideoSection(),

              const SizedBox(height: AppSpacing.spacing32),

              // Botão Continuar
              _isLoading
                  ? const Center(child: CircularProgressIndicator())
                  : AppButton(
                      type: AppButtonType.primary,
                      text: 'Continuar',
                      onPressed: _continue,
                      minWidth: double.infinity,
                    ),

              const SizedBox(height: AppSpacing.spacing16), // Espaço inferior
            ],
          ),
        ),
      ),
    );
  }

  // Seção de Fotos
  Widget _buildPhotoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Fotos',
              style: AppTypography.highlightBold.copyWith(color: AppColorsNeutral.neutral800),
            ),
            Text(
              '${_selectedPhotos.length}/$maxPhotos',
              style: AppTypography.captionMedium.copyWith(color: AppColorsNeutral.neutral600),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing16),
        Container(
          padding: const EdgeInsets.all(AppSpacing.spacing16),
          decoration: BoxDecoration(
            color: AppColorsNeutral.neutral50,
            borderRadius: AppRadius.radius12,
            border: Border.all(
              color: AppColorsNeutral.neutral300,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
            child: _selectedPhotos.isEmpty
                ? _buildUploadPrompt(
                    description: 'Envie de $minPhotos a $maxPhotos fotos\ndo seu trabalho',
                    buttonText: 'Selecionar do dispositivo',
                    onSelect: _selectPhotos,
                  )
              : _buildPhotoGrid(),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        Text(
          'Arquivos em PNG ou JPG (Tamanho máximo ${maxPhotoSizeMB}MB)',
          style: AppTypography.footnoteRegular.copyWith(color: AppColorsNeutral.neutral500),
        ),
      ],
    );
  }

  // Seção de Vídeos
  Widget _buildVideoSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Vídeos',
              style: AppTypography.highlightBold.copyWith(color: AppColorsNeutral.neutral800),
            ),
            Text(
              '${_selectedVideos.length}/$maxVideos',
              style: AppTypography.captionMedium.copyWith(color: AppColorsNeutral.neutral600),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.spacing16),
        Container(
          padding: const EdgeInsets.all(AppSpacing.spacing16),
          decoration: BoxDecoration(
            color: AppColorsNeutral.neutral50,
            borderRadius: AppRadius.radius12,
            border: Border.all(
              color: AppColorsNeutral.neutral300,
              width: 1,
              style: BorderStyle.solid,
            ),
          ),
            child: _selectedVideos.isEmpty
                ? _buildUploadPrompt(
                    description: 'Envie de $minVideos a $maxVideos vídeos\ndo seu trabalho',
                    buttonText: 'Selecionar do dispositivo',
                    onSelect: _selectVideos,
                  )
              : _buildVideoList(),
        ),
        const SizedBox(height: AppSpacing.spacing8),
        Text(
          'Arquivos em MP4, MOV ou AVI (Tamanho máximo ${maxVideoSizeMB}MB)',
          style: AppTypography.footnoteRegular.copyWith(color: AppColorsNeutral.neutral500),
        ),
      ],
    );
  }

  // Grid de preview de fotos
  Widget _buildPhotoGrid() {
    return Column(
      children: [
        GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 3,
            crossAxisSpacing: AppSpacing.spacing8,
            mainAxisSpacing: AppSpacing.spacing8,
          ),
          itemCount: _selectedPhotos.length,
          itemBuilder: (context, index) {
            return Stack(
              children: [
                ClipRRect(
                  borderRadius: AppRadius.radius8,
                  child: Image.file(
                    File(_selectedPhotos[index].path),
                    width: double.infinity,
                    height: double.infinity,
                    fit: BoxFit.cover,
                  ),
                ),
                Positioned(
                  top: 4,
                  right: 4,
                  child: GestureDetector(
                    onTap: () => _removePhoto(index),
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        color: AppColorsError.error600,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.close,
                        color: AppColorsNeutral.neutral0,
                        size: 16,
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
        if (_selectedPhotos.length < maxPhotos) ...[
          const SizedBox(height: AppSpacing.spacing12),
          ElevatedButton.icon(
            icon: SvgPicture.asset(
              'assets/icons/upload_file.svg',
              height: 16,
              colorFilter: ColorFilter.mode(AppColorsNeutral.neutral0, BlendMode.srcIn),
            ),
            label: Text(
              'Adicionar mais fotos',
              style: AppTypography.captionBold.copyWith(color: AppColorsNeutral.neutral0),
            ),
            onPressed: _selectPhotos,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsPrimary.primary800,
              foregroundColor: AppColorsNeutral.neutral0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radius8),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16, vertical: AppSpacing.spacing8),
            ),
          ),
        ],
      ],
    );
  }

  // Lista de preview de vídeos
  Widget _buildVideoList() {
    return Column(
      children: [
        ...List.generate(_selectedVideos.length, (index) {
          return Padding(
            padding: const EdgeInsets.only(bottom: AppSpacing.spacing8),
            child: Container(
              padding: const EdgeInsets.all(AppSpacing.spacing12),
              decoration: BoxDecoration(
                color: AppColorsNeutral.neutral100,
                borderRadius: AppRadius.radius8,
                border: Border.all(color: AppColorsNeutral.neutral200),
              ),
              child: Row(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: BoxDecoration(
                      color: AppColorsPrimary.primary100,
                      borderRadius: AppRadius.radius8,
                    ),
                    child: const Icon(
                      Icons.videocam,
                      color: AppColorsPrimary.primary700,
                      size: 24,
                    ),
                  ),
                  const SizedBox(width: AppSpacing.spacing12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _selectedVideos[index].name,
                          style: AppTypography.captionMedium.copyWith(
                            color: AppColorsNeutral.neutral900,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'Vídeo ${index + 1}',
                          style: AppTypography.footnoteRegular.copyWith(
                            color: AppColorsNeutral.neutral600,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.delete_outline, color: AppColorsError.error600),
                    onPressed: () => _removeVideo(index),
                  ),
                ],
              ),
            ),
          );
        }),
        if (_selectedVideos.length < maxVideos) ...[
          const SizedBox(height: AppSpacing.spacing12),
          ElevatedButton.icon(
            icon: SvgPicture.asset(
              'assets/icons/upload_file.svg',
              height: 16,
              colorFilter: ColorFilter.mode(AppColorsNeutral.neutral0, BlendMode.srcIn),
            ),
            label: Text(
              'Adicionar mais vídeos',
              style: AppTypography.captionBold.copyWith(color: AppColorsNeutral.neutral0),
            ),
            onPressed: _selectVideos,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsPrimary.primary800,
              foregroundColor: AppColorsNeutral.neutral0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radius8),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16, vertical: AppSpacing.spacing8),
            ),
          ),
        ],
      ],
    );
  }

  // Prompt de upload
  Widget _buildUploadPrompt({
    required String description,
    required String buttonText,
    required VoidCallback onSelect,
  }) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SvgPicture.asset(
            'assets/icons/cloud_upload.svg',
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
          ElevatedButton.icon(
            icon: SvgPicture.asset(
              'assets/icons/upload_file.svg',
              height: 16,
              colorFilter: ColorFilter.mode(AppColorsNeutral.neutral0, BlendMode.srcIn),
            ),
            label: Text(
              buttonText,
              style: AppTypography.captionBold.copyWith(color: AppColorsNeutral.neutral0),
            ),
            onPressed: onSelect,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColorsPrimary.primary800,
              foregroundColor: AppColorsNeutral.neutral0,
              shape: RoundedRectangleBorder(borderRadius: AppRadius.radius8),
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.spacing16, vertical: AppSpacing.spacing8),
            ),
          ),
        ],
      ),
    );
  }
}