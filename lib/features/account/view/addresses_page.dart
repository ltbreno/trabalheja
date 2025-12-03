import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_radius.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';

class AddressesPage extends StatefulWidget {
  const AddressesPage({super.key});

  @override
  State<AddressesPage> createState() => _AddressesPageState();
}

class _AddressesPageState extends State<AddressesPage> {
  final _supabase = Supabase.instance.client;
  Map<String, dynamic>? _addressData;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadAddressData();
  }

  Future<void> _loadAddressData() async {
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
          .select(
            'address_cep, address_bairro, address_rua, address_numero, address_complemento, address_cidade',
          )
          .eq('id', user.id)
          .maybeSingle();

      setState(() {
        _addressData = profile;
        _isLoading = false;
      });
    } catch (e) {
      print('Erro ao carregar dados de endereço: $e');
      setState(() {
        _isLoading = false;
      });
    }
  }

  bool _hasAddress() {
    if (_addressData == null) return false;
    
    final cep = _addressData?['address_cep'];
    final rua = _addressData?['address_rua'];
    final numero = _addressData?['address_numero'];
    final bairro = _addressData?['address_bairro'];
    final cidade = _addressData?['address_cidade'];
    
    return (cep != null && cep.toString().isNotEmpty) ||
           (rua != null && rua.toString().isNotEmpty) ||
           (numero != null && numero.toString().isNotEmpty) ||
           (bairro != null && bairro.toString().isNotEmpty) ||
           (cidade != null && cidade.toString().isNotEmpty);
  }

  String _formatAddress() {
    if (!_hasAddress()) return '';
    
    final parts = <String>[];
    
    if (_addressData?['address_rua'] != null && 
        _addressData!['address_rua'].toString().isNotEmpty) {
      final rua = _addressData!['address_rua'].toString();
      final numero = _addressData?['address_numero']?.toString();
      
      if (numero != null && numero.isNotEmpty) {
        parts.add('$rua, $numero');
      } else {
        parts.add(rua);
      }
    }
    
    if (_addressData?['address_bairro'] != null && 
        _addressData!['address_bairro'].toString().isNotEmpty) {
      parts.add(_addressData!['address_bairro'].toString());
    }
    
    if (_addressData?['address_complemento'] != null && 
        _addressData!['address_complemento'].toString().isNotEmpty) {
      parts.add(_addressData!['address_complemento'].toString());
    }
    
    if (_addressData?['address_cidade'] != null && 
        _addressData!['address_cidade'].toString().isNotEmpty) {
      parts.add(_addressData!['address_cidade'].toString());
    }
    
    if (_addressData?['address_cep'] != null && 
        _addressData!['address_cep'].toString().isNotEmpty) {
      parts.add('CEP: ${_addressData!['address_cep']}');
    }
    
    return parts.join('\n');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColorsNeutral.neutral0,
      appBar: AppBar(
        backgroundColor: AppColorsNeutral.neutral0,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: AppColorsPrimary.primary900),
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
        child: _isLoading
            ? const Center(child: CircularProgressIndicator())
            : RefreshIndicator(
                onRefresh: _loadAddressData,
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(AppSpacing.spacing24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      const SizedBox(height: AppSpacing.spacing16),
                      // Título
                      Text(
                        'Endereços',
                        style: AppTypography.heading1.copyWith(
                          color: AppColorsPrimary.primary900,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing8),
                      Text(
                        'Endereço cadastrado no seu perfil',
                        style: AppTypography.contentRegular.copyWith(
                          color: AppColorsNeutral.neutral600,
                        ),
                      ),
                      const SizedBox(height: AppSpacing.spacing32),
                      
                      // Card com o endereço
                      if (_hasAddress())
                        _buildAddressCard()
                      else
                        _buildEmptyAddressCard(),
                      
                      const SizedBox(height: AppSpacing.spacing32),
                    ],
                  ),
                ),
              ),
      ),
    );
  }

  Widget _buildAddressCard() {
    final formattedAddress = _formatAddress();
    
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing24),
      decoration: BoxDecoration(
        color: AppColorsNeutral.neutral0,
        borderRadius: AppRadius.radius12,
        border: Border.all(color: AppColorsNeutral.neutral200),
        boxShadow: [
          BoxShadow(
            color: AppColorsNeutral.neutral100.withOpacity(0.5),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Cabeçalho do card
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(AppSpacing.spacing8),
                decoration: BoxDecoration(
                  color: AppColorsPrimary.primary100,
                  borderRadius: AppRadius.radius8,
                ),
                child: SvgPicture.asset(
                  'assets/icons/location_pin.svg',
                  height: 24,
                  width: 24,
                  colorFilter: ColorFilter.mode(
                    AppColorsPrimary.primary900,
                    BlendMode.srcIn,
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.spacing12),
              Expanded(
                child: Text(
                  'Endereço Principal',
                  style: AppTypography.highlightBold.copyWith(
                    color: AppColorsPrimary.primary900,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.spacing16),
          
          // Endereço formatado
          Text(
            formattedAddress,
            style: AppTypography.contentRegular.copyWith(
              color: AppColorsNeutral.neutral700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildEmptyAddressCard() {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.spacing32),
      decoration: BoxDecoration(
        color: AppColorsNeutral.neutral50,
        borderRadius: AppRadius.radius12,
        border: Border.all(color: AppColorsNeutral.neutral200),
      ),
      child: Column(
        children: [
          Icon(
            Icons.location_off,
            size: 64,
            color: AppColorsNeutral.neutral400,
          ),
          const SizedBox(height: AppSpacing.spacing16),
          Text(
            'Nenhum endereço cadastrado',
            style: AppTypography.highlightBold.copyWith(
              color: AppColorsNeutral.neutral700,
            ),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Text(
            'Você ainda não cadastrou um endereço no seu perfil.',
            style: AppTypography.contentRegular.copyWith(
              color: AppColorsNeutral.neutral600,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}

