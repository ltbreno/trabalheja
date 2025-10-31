// lib/features/auth/view/freelancer_services_page.dart
import 'package:flutter/material.dart';
import 'package:trabalheja/core/constants/app_colors.dart';
import 'package:trabalheja/core/constants/app_spacing.dart';
import 'package:trabalheja/core/constants/app_typography.dart';
import 'package:trabalheja/features/home/widgets/app.button.dart';
import 'package:trabalheja/features/home/widgets/app_text_field.dart';
import 'package:trabalheja/features/auth/view/freelancer_services_page.dart';
import 'package:trabalheja/features/auth/view/freelancer_portfolio_page.dart';

class FreelancerServicesPage extends StatefulWidget {
  // Receber dados das telas anteriores, se necessário (email, tipo de conta, etc.)
  // final String email;
  // final String phone;
  // final AccountType accountType = AccountType.freelancer;

  const FreelancerServicesPage({
    super.key,
    // required this.email,
    // required this.phone,
  });

  @override
  State<FreelancerServicesPage> createState() => _FreelancerServicesPageState();
}

class _FreelancerServicesPageState extends State<FreelancerServicesPage> {
  final _nameController = TextEditingController();
  final _servicesController = TextEditingController(); // Controller para serviços
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _nameController.dispose();
    _servicesController.dispose();
    super.dispose();
  }

  void _continue() {
    if (_formKey.currentState?.validate() ?? false) {
      final name = _nameController.text;
      final services = _servicesController.text;
      print('Nome completo: $name');
      print('Serviços: $services');
      // TODO: Navegar para FreelancerPortfolioPage passando os dados acumulados
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => const FreelancerServicesPage(
              // Passar dados como nome, email, serviços...
              // fullName: name,
              // services: services,
              ),
        ),
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
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppSpacing.spacing16),
                // Campo Nome Completo
                AppTextField(
                  label: 'Nome completo',
                  hintText: 'Informe seu nome completo',
                  controller: _nameController,
                  keyboardType: TextInputType.name,
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, informe seu nome completo';
                    }
                    if (value.trim().split(' ').length < 2) {
                      return 'Por favor, informe nome e sobrenome';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: AppSpacing.spacing24),

                // Campo Serviços Oferecidos
                AppTextField(
                  label: 'Serviços oferecidos',
                  hintText: 'Liste os serviços que você realiza',
                  controller: _servicesController,
                  keyboardType: TextInputType.multiline, // Permite múltiplas linhas
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) {
                      return 'Por favor, liste seus serviços';
                    }
                    return null;
                  },
                ),

                const SizedBox(height: AppSpacing.spacing32), // Espaço antes do botão

                // Botão Continuar
                AppButton(
                  type: AppButtonType.primary,
                  text: 'Continuar',
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const FreelancerPortfolioPage()));
                  },
                  minWidth: double.infinity,
                ),

                const SizedBox(height: AppSpacing.spacing16), // Espaço inferior
              ],
            ),
          ),
        ),
      ),
    );
  }
}