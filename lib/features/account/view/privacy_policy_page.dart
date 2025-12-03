import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';

class PrivacyPolicyPage extends StatelessWidget {
  const PrivacyPolicyPage({super.key});

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
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(AppSpacing.spacing24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppSpacing.spacing16),
              // Título
              Text(
                'Política de Privacidade',
                style: AppTypography.heading1.copyWith(
                  color: AppColorsPrimary.primary900,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing8),
              Text(
                'Última atualização: ${_getCurrentDate()}',
                style: AppTypography.captionRegular.copyWith(
                  color: AppColorsNeutral.neutral600,
                ),
              ),
              const SizedBox(height: AppSpacing.spacing32),
              
              // Conteúdo da política
              _buildSection(
                '1. Introdução',
                'O TrabalheJá está comprometido em proteger sua privacidade. Esta Política de Privacidade explica como coletamos, usamos, compartilhamos e protegemos suas informações pessoais quando você usa nosso aplicativo.',
              ),
              
              _buildSection(
                '2. Informações que Coletamos',
                'Coletamos as seguintes informações:\n\n• Informações de cadastro: nome, email, telefone\n• Informações de perfil: foto, endereço, tipo de conta\n• Informações de localização: coordenadas GPS (quando permitido)\n• Informações de uso: interações com o aplicativo, serviços solicitados\n• Informações de pagamento: processadas de forma segura por terceiros',
              ),
              
              _buildSection(
                '3. Como Usamos suas Informações',
                'Utilizamos suas informações para:\n\n• Fornecer e melhorar nossos serviços\n• Conectar clientes com freelancers\n• Processar pagamentos\n• Enviar notificações importantes sobre serviços\n• Personalizar sua experiência\n• Detectar e prevenir fraudes\n• Cumprir obrigações legais',
              ),
              
              _buildSection(
                '4. Compartilhamento de Informações',
                'Não vendemos suas informações pessoais. Podemos compartilhar suas informações apenas:\n\n• Com outros usuários da plataforma (conforme necessário para o serviço)\n• Com provedores de serviços terceirizados (processamento de pagamento)\n• Quando exigido por lei ou ordem judicial\n• Para proteger nossos direitos e segurança',
              ),
              
              _buildSection(
                '5. Segurança dos Dados',
                'Implementamos medidas de segurança técnicas e organizacionais para proteger suas informações contra acesso não autorizado, alteração, divulgação ou destruição. No entanto, nenhum método de transmissão pela internet é 100% seguro.',
              ),
              
              _buildSection(
                '6. Seus Direitos',
                'Você tem o direito de:\n\n• Acessar suas informações pessoais\n• Corrigir informações incorretas\n• Solicitar exclusão de seus dados\n• Retirar consentimento para processamento de dados\n• Portabilidade de dados\n• Opor-se ao processamento de seus dados',
              ),
              
              _buildSection(
                '7. Cookies e Tecnologias Similares',
                'Usamos cookies e tecnologias similares para melhorar sua experiência, analisar o uso do aplicativo e personalizar conteúdo. Você pode controlar cookies através das configurações do seu dispositivo.',
              ),
              
              _buildSection(
                '8. Retenção de Dados',
                'Mantemos suas informações pessoais apenas pelo tempo necessário para cumprir os propósitos descritos nesta política, a menos que um período de retenção mais longo seja exigido ou permitido por lei.',
              ),
              
              _buildSection(
                '9. Privacidade de Menores',
                'Nossos serviços são destinados a usuários maiores de 18 anos. Não coletamos intencionalmente informações de menores de idade. Se tomarmos conhecimento de que coletamos informações de um menor, tomaremos medidas para excluir essas informações.',
              ),
              
              _buildSection(
                '10. Alterações nesta Política',
                'Podemos atualizar esta Política de Privacidade periodicamente. Notificaremos sobre mudanças significativas através do aplicativo ou por email. A data da última atualização está indicada no topo desta página.',
              ),
              
              _buildSection(
                '11. Contato',
                'Se você tiver dúvidas, preocupações ou solicitações relacionadas a esta Política de Privacidade ou ao tratamento de seus dados pessoais, entre em contato conosco através do suporte do aplicativo.',
              ),
              
              const SizedBox(height: AppSpacing.spacing32),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSection(String title, String content) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.spacing24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: AppTypography.highlightBold.copyWith(
              color: AppColorsPrimary.primary900,
            ),
          ),
          const SizedBox(height: AppSpacing.spacing8),
          Text(
            content,
            style: AppTypography.contentRegular.copyWith(
              color: AppColorsNeutral.neutral700,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }

  String _getCurrentDate() {
    final now = DateTime.now();
    return '${now.day.toString().padLeft(2, '0')}/${now.month.toString().padLeft(2, '0')}/${now.year}';
  }
}




