// lib/features/auth/view/freelancer_picture_page.dart
import 'dart:io'; // Para usar File
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:image_picker/image_picker.dart'; // Importar image_picker
import 'package:dotted_border/dotted_border.dart'; // Importar dotted_border
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/core/widgets/MainAppShell.dart';

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
  final _supabase = Supabase.instance.client;

  // Função para selecionar imagem da galeria
  Future<void> _pickImage() async {
    try {
      final XFile? pickedFile = await _picker.pickImage(
        source: ImageSource.gallery,
        imageQuality: 80, // Comprimir um pouco a imagem
      );
      if (pickedFile != null) {
        // Validar tamanho (máximo 10MB)
        final file = File(pickedFile.path);
        final sizeInMB = await file.length() / (1024 * 1024);
        const maxSizeMB = 10;
        
        if (sizeInMB > maxSizeMB) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('A foto excede o tamanho máximo de ${maxSizeMB}MB.'),
                backgroundColor: AppColorsError.error600,
              ),
            );
          }
          return;
        }

        setState(() {
          _imageFile = pickedFile;
        });
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Erro ao selecionar imagem: ${e.toString()}'),
            backgroundColor: AppColorsError.error600,
          ),
        );
      }
    }
  }

  Future<void> _finalizeRegistration() async {
    // Foto agora é opcional - não precisa validar
    
    setState(() => _isLoading = true);

    try {
      final user = _supabase.auth.currentUser;
      if (user == null) {
        throw Exception('Usuário não autenticado');
      }

      // 1. Fazer upload da imagem para o Supabase Storage (se houver)
      String? imageUrl;
      if (_imageFile != null) {
        final fileExtension = _imageFile!.path.split('.').last.toLowerCase();
        final fileName = '${user.id}/profile_picture.$fileExtension';
        
        print('📤 Iniciando upload de foto de perfil...');
        print('   Bucket: profiles');
        print('   FileName: $fileName');
        print('   Extension: $fileExtension');
        
        // Determinar contentType baseado na extensão
        String contentType;
        if (fileExtension == 'png') {
          contentType = 'image/png';
        } else if (fileExtension == 'jpg' || fileExtension == 'jpeg') {
          contentType = 'image/jpeg';
        } else {
          contentType = 'image/jpeg'; // fallback
        }
        
        final imageFile = File(_imageFile!.path);
        
        print('   ContentType: $contentType');
        print('   File size: ${await imageFile.length()} bytes');
        
        // Tentar upload usando o método correto
        try {
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
          print('✅ Upload concluído com sucesso!');
          
          // Obter URL pública da imagem
          imageUrl = _supabase.storage
              .from('profiles')
              .getPublicUrl(fileName);
          
          print('   URL pública: $imageUrl');
        } catch (uploadError) {
          print('❌ Erro no upload: $uploadError');
          
          // Verificar se é erro de bucket não encontrado
          final errorString = uploadError.toString().toLowerCase();
          if (errorString.contains('bucket') || 
              errorString.contains('not found') ||
              errorString.contains('does not exist')) {
            print('⚠️ Bucket "profiles" não encontrado. Continuando sem foto.');
            // Continuar sem foto - não é crítico já que a foto é opcional
            imageUrl = null;
          } else {
            // Tentar método alternativo para outros erros
            try {
              print('🔄 Tentando método alternativo de upload...');
              final imageBytes = await imageFile.readAsBytes();
              await _supabase.storage
                  .from('profiles')
                  .uploadBinary(
                    fileName,
                    imageBytes,
                    fileOptions: FileOptions(
                      contentType: contentType,
                      upsert: true,
                    ),
                  );
              print('✅ Upload concluído usando método alternativo!');
              
              // Obter URL pública da imagem
              imageUrl = _supabase.storage
                  .from('profiles')
                  .getPublicUrl(fileName);
              
              print('   URL pública: $imageUrl');
            } catch (alternativeError) {
              print('❌ Método alternativo também falhou: $alternativeError');
              // Continuar sem foto mesmo em caso de erro
              imageUrl = null;
            }
          }
        }
      } else {
        print('ℹ️ Nenhuma foto selecionada - continuando sem foto de perfil');
      }

      // 3. Buscar todos os dados já salvos nas páginas anteriores
      // Como o perfil ainda não existe (não foi criado), vamos buscar do auth.user
      // e das outras fontes de dados que precisamos
      print('📋 [FreelancerPicturePage] Buscando dados coletados...');
      
      // Buscar dados do perfil atual (se existir algum dado temporário)
      Map<String, dynamic>? existingProfileData;
      try {
        final existing = await _supabase
            .from('profiles')
            .select('*')
            .eq('id', user.id)
            .maybeSingle();
        
        if (existing != null) {
          existingProfileData = Map<String, dynamic>.from(existing);
          print('   ✅ Dados existentes encontrados no perfil');
        }
      } catch (e) {
        print('   ℹ️ Nenhum perfil existente encontrado (esperado para freelancer)');
      }

      // Buscar email do usuário autenticado
      final userEmail = user.email ?? user.userMetadata?['email'] as String?;
      if (userEmail == null) {
        throw Exception('Email do usuário não encontrado');
      }

      // Buscar phone dos metadados
      final userPhone = user.userMetadata?['phone'] as String?;
      if (userPhone == null) {
        throw Exception('Telefone do usuário não encontrado');
      }

      // Preparar dados completos para criação do perfil FREELANCER
      final profileData = <String, dynamic>{
        'id': user.id,
        'account_type': 'freelancer',
        'email': userEmail,
        'phone': userPhone,
      };

      // Adicionar URL da foto apenas se houver
      if (imageUrl != null) {
        profileData['profile_picture_url'] = imageUrl;
      }

      // Adicionar dados que podem ter sido salvos nas páginas anteriores
      if (existingProfileData != null) {
        // Se houver dados existentes (por algum motivo), mesclar
        if (existingProfileData['full_name'] != null) {
          profileData['full_name'] = existingProfileData['full_name'];
        }
        if (existingProfileData['services'] != null) {
          profileData['services'] = existingProfileData['services'];
        }
        if (existingProfileData['address_cep'] != null) {
          profileData['address_cep'] = existingProfileData['address_cep'];
        }
        if (existingProfileData['address_bairro'] != null) {
          profileData['address_bairro'] = existingProfileData['address_bairro'];
        }
        if (existingProfileData['address_rua'] != null) {
          profileData['address_rua'] = existingProfileData['address_rua'];
        }
        if (existingProfileData['address_numero'] != null) {
          profileData['address_numero'] = existingProfileData['address_numero'];
        }
        if (existingProfileData['address_complemento'] != null) {
          profileData['address_complemento'] = existingProfileData['address_complemento'];
        }
        if (existingProfileData['address_cidade'] != null) {
          profileData['address_cidade'] = existingProfileData['address_cidade'];
        }
        if (existingProfileData['service_radius'] != null) {
          profileData['service_radius'] = existingProfileData['service_radius'];
        }
        if (existingProfileData['service_latitude'] != null) {
          profileData['service_latitude'] = existingProfileData['service_latitude'];
        }
        if (existingProfileData['service_longitude'] != null) {
          profileData['service_longitude'] = existingProfileData['service_longitude'];
        }
      }

      // Debug: mostrar o que será criado/atualizado
      print('📤 [FreelancerPicturePage] Finalizando perfil FREELANCER:');
      print('   - id: ${profileData['id']}');
      print('   - account_type: ${profileData['account_type']}');
      print('   - email: ${profileData['email']}');
      print('   - phone: ${profileData['phone']}');
      print('   - profile_picture_url: ${profileData['profile_picture_url']}');
      print('   - service_latitude: ${profileData['service_latitude'] ?? 'não definido'}');
      print('   - service_longitude: ${profileData['service_longitude'] ?? 'não definido'}');

      // Verificar se o perfil já existe (pode ter sido criado parcialmente na página de raio)
      if (existingProfileData != null) {
        // Perfil já existe, fazer UPDATE
        print('📝 [FreelancerPicturePage] Perfil já existe, fazendo UPDATE...');
        await _supabase.from('profiles').update(profileData).eq('id', user.id);
        print('✅ [FreelancerPicturePage] Perfil FREELANCER atualizado com sucesso!');
      } else {
        // Perfil não existe, criar completo (INSERT)
        print('📝 [FreelancerPicturePage] Criando perfil FREELANCER completo...');
        await _supabase.from('profiles').insert(profileData);
        print('✅ [FreelancerPicturePage] Perfil FREELANCER criado com sucesso!');
      }

      if (!mounted) return;

      // 4. Navegar para a tela principal
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => const MainAppShell()),
        (route) => false,
      );
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Cadastro finalizado com sucesso!')),
      );
    } catch (e) {
      if (!mounted) return;
      
      // Log detalhado do erro
      print('❌ ERRO CRÍTICO no cadastro:');
      print('   Tipo: ${e.runtimeType}');
      print('   Mensagem: ${e.toString()}');
      if (e is StorageException) {
        print('   StatusCode: ${e.statusCode}');
        print('   Message: ${e.message}');
      }
      
      // Mensagem de erro mais específica para o usuário
      String errorMessage = 'Erro ao finalizar cadastro.';
      final errorString = e.toString().toLowerCase();
      
      if (errorString.contains('email') && errorString.contains('não encontrado')) {
        errorMessage = 'Email do usuário não encontrado. Tente fazer login novamente.';
      } else if (errorString.contains('phone') || errorString.contains('telefone')) {
        errorMessage = 'Telefone do usuário não encontrado. Verifique seus dados.';
      } else if (errorString.contains('permission') || errorString.contains('policy')) {
        errorMessage = 'Sem permissão. Verifique as configurações do banco de dados.';
      } else if (errorString.contains('duplicate') || errorString.contains('unique')) {
        errorMessage = 'Este perfil já existe. Redirecionando...';
        // Tentar navegar mesmo assim
        Future.delayed(const Duration(seconds: 1), () {
          if (mounted) {
            Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const MainAppShell()),
              (route) => false,
            );
          }
        });
      }
      
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(errorMessage),
          backgroundColor: Colors.red,
          duration: const Duration(seconds: 5),
        ),
      );
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
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