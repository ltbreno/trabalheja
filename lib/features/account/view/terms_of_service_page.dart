import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';

class TermsOfServicePage extends StatelessWidget {
  const TermsOfServicePage({super.key});

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
                'Termos de Uso',
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
              
              // Conteúdo dos termos
              _buildSection(
                '1. Aceitação dos Termos',
                'Ao acessar e usar o aplicativo TrabalheJá, você concorda em cumprir e estar vinculado aos seguintes termos e condições de uso.',
              ),
              
              _buildSection(
                '2. Descrição do Serviço',
                'O TrabalheJá é uma plataforma que conecta clientes que precisam de serviços com freelancers qualificados. A plataforma facilita a comunicação, negociação e pagamento entre as partes.',
              ),
              
              _buildSection(
                '3. Cadastro e Conta',
                'Para usar nossos serviços, você precisa criar uma conta fornecendo informações precisas e atualizadas. Você é responsável por manter a segurança de sua conta e senha. Todas as atividades realizadas em sua conta são de sua responsabilidade.',
              ),
              
              _buildSection(
                '4. Uso do Serviço',
                'Você concorda em usar o TrabalheJá apenas para fins legais e de acordo com estes Termos. Você não deve:\n\n• Usar o serviço para atividades ilegais\n• Violar direitos de propriedade intelectual\n• Transmitir vírus ou códigos maliciosos\n• Interferir no funcionamento da plataforma\n• Criar contas falsas ou se passar por outra pessoa',
              ),
              
              _buildSection(
                '5. Responsabilidades',
                'O TrabalheJá atua apenas como intermediário entre clientes e freelancers. Não somos responsáveis pela qualidade, pontualidade ou legalidade dos serviços prestados pelos freelancers, nem pelos pagamentos ou disputas entre usuários.',
              ),
              
              _buildSection(
                '6. Pagamentos',
                'Os pagamentos são processados através de métodos seguros. O TrabalheJá pode cobrar taxas de transação. Todas as taxas serão claramente comunicadas antes da conclusão da transação.',
              ),
              
              _buildSection(
                '7. Propriedade Intelectual',
                'Todo o conteúdo do aplicativo, incluindo textos, gráficos, logos, ícones e software, é propriedade do TrabalheJá e está protegido por leis de direitos autorais.',
              ),
              
              _buildSection(
                '8. Modificações dos Termos',
                'Reservamos o direito de modificar estes Termos a qualquer momento. As alterações entrarão em vigor imediatamente após a publicação. É sua responsabilidade revisar periodicamente estes Termos.',
              ),
              
              _buildSection(
                '9. Cancelamento e Encerramento',
                'Você pode encerrar sua conta a qualquer momento. O TrabalheJá reserva-se o direito de suspender ou encerrar contas que violem estes Termos ou que sejam usadas de forma inadequada.',
              ),
              
              _buildSection(
                '10. Contato',
                'Se você tiver dúvidas sobre estes Termos de Uso, entre em contato conosco através do suporte do aplicativo.',
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




