// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Portuguese (`pt`).
class AppLocalizationsPt extends AppLocalizations {
  AppLocalizationsPt([String locale = 'pt']) : super(locale);

  @override
  String get appTitle => 'TrabalheJá';

  @override
  String get welcomeBack => 'Bem-vindo de volta';

  @override
  String get welcome => 'Bem-vindo,';

  @override
  String get user => 'Usuário';

  @override
  String get requestFreelancer => 'Solicitar freelancer';

  @override
  String get requestFreelancerSubtitle =>
      'Precisa de um serviço? Solicite um freelancer agora e receba propostas';

  @override
  String get receivedProposals => 'Propostas recebidas';

  @override
  String get receivedProposalsSubtitle =>
      'Acompanhe as propostas enviadas pelos freelancers';

  @override
  String get rateServices => 'Avaliar serviços';

  @override
  String get rateServicesSubtitle =>
      'Avalie serviços realizados pelos freelancers';

  @override
  String get back => 'Voltar';

  @override
  String get welcomeBackToApp => 'Bem-vindo(a) de volta\nao TrabalheJá';

  @override
  String get chooseLoginMethod => 'Escolha seu método de entrada da sua conta.';

  @override
  String get loginWithEmail => 'Entrar com email e senha';

  @override
  String get loginWithFacebook => 'Entrar com Facebook';

  @override
  String get loginWithGoogle => 'Entrar com Google';

  @override
  String get noAccount => 'Não tenho uma conta';

  @override
  String get myData => 'Meus dados';

  @override
  String get securityAndPassword => 'Segurança e senha';

  @override
  String get bankDetails => 'Dados Bancários';

  @override
  String get myCards => 'Meus Cartões';

  @override
  String get addresses => 'Endereços';

  @override
  String get termsOfUse => 'Termos de uso';

  @override
  String get privacyPolicy => 'Política de privacidade';

  @override
  String get logout => 'Sair da conta';

  @override
  String get logoutConfirmTitle => 'Sair da conta';

  @override
  String get logoutConfirmMessage =>
      'Tem certeza que deseja sair da sua conta?';

  @override
  String get cancel => 'Cancelar';

  @override
  String get exit => 'Sair';

  @override
  String get talkToSupport => 'Falar com suporte';

  @override
  String get frequentQuestions => 'Dúvidas frequentes';

  @override
  String get client => 'Cliente';

  @override
  String get freelancer => 'Freelancer';

  @override
  String get language => 'Idioma';

  @override
  String get selectLanguage => 'Selecionar idioma';

  @override
  String get portuguese => 'Português';

  @override
  String get english => 'Inglês';

  @override
  String get nearbyServices => 'Bicos próximos';

  @override
  String get searchServicesTitle => 'Qual bico você está procurando?';

  @override
  String get searchServicesHint => 'Pesquisar serviços';

  @override
  String get selectedClient => 'Cliente selecionado';

  @override
  String get nearbyClients => 'Clientes próximos';

  @override
  String get noServicesFound => 'Nenhum bico encontrado';

  @override
  String get noServicesFoundSubtitle =>
      'Não há solicitações próximas no momento. Tente aumentar seu raio de atuação.';

  @override
  String noSearchResults(String query) {
    return 'Nenhum resultado para \"$query\"';
  }

  @override
  String get serviceDetails => 'Detalhes do serviço';

  @override
  String distanceAway(String distance) {
    return 'Em $distance';
  }

  @override
  String deadlineInHours(int hours) {
    return 'Em até $hours horas';
  }

  @override
  String errorLoggingOut(String error) {
    return 'Erro ao sair: $error';
  }

  @override
  String get all => 'Todas';

  @override
  String get pending => 'Pendentes';

  @override
  String pendingCount(int count) {
    return 'Pendentes ($count)';
  }

  @override
  String get accepted => 'Aceitas';

  @override
  String acceptedCount(int count) {
    return 'Aceitas ($count)';
  }

  @override
  String get completed => 'Concluídas';

  @override
  String completedCount(int count) {
    return 'Concluídas ($count)';
  }

  @override
  String get sentProposals => 'Propostas enviadas';

  @override
  String proposalsReceivedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count propostas recebidas',
      one: '1 proposta recebida',
    );
    return '$_temp0';
  }

  @override
  String proposalsSentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count propostas enviadas',
      one: '1 proposta enviada',
    );
    return '$_temp0';
  }

  @override
  String get proposalAcceptedSuccess => 'Proposta aceita com sucesso!';

  @override
  String get proposalRejected => 'Proposta rejeitada.';

  @override
  String get errorAcceptingProposal => 'Erro ao aceitar proposta';

  @override
  String get errorAcceptingProposalMessage =>
      'Não foi possível aceitar a proposta. Tente novamente.';

  @override
  String get errorRejectingProposal => 'Erro ao rejeitar proposta';

  @override
  String get errorRejectingProposalMessage =>
      'Não foi possível rejeitar a proposta. Tente novamente.';

  @override
  String get chatInDevelopment => 'Chat em desenvolvimento';

  @override
  String timeframe(int time, String unit) {
    return 'Em até $time $unit';
  }

  @override
  String get reject => 'Rejeitar';

  @override
  String get accept => 'Aceitar';

  @override
  String get proposalAcceptedBadge => 'Proposta Aceita';

  @override
  String get paymentAction => 'Realize o pagamento para iniciar o serviço';

  @override
  String get paymentReleasedBadge => 'Pagamento liberado para o freelancer ✓';

  @override
  String get paymentHeldBadge =>
      'Pagamento realizado! Libere após finalizar o serviço';

  @override
  String get makePayment => 'Realizar Pagamento';

  @override
  String get chatWithFreelancer => 'Conversar com Freelancer';

  @override
  String get chat => 'Conversar';

  @override
  String get releasePayment => 'Liberar Pagamento';

  @override
  String get paidBadge => 'PAGA';

  @override
  String get released => 'Liberado';

  @override
  String get retained => 'Retido';

  @override
  String get paymentReleased => 'Pagamento Liberado';

  @override
  String get paymentRetained => 'Pagamento Retido';

  @override
  String get waitingConfirmation => 'Aguardando confirmação';

  @override
  String get serviceLabel => 'Serviço:';

  @override
  String get pix => 'PIX';

  @override
  String get creditCard => 'Cartão de Crédito';

  @override
  String get notInformed => 'Não informado';

  @override
  String get dateNotAvailable => 'Data não disponível';

  @override
  String get invalidDate => 'Data inválida';

  @override
  String get atTime => 'às';

  @override
  String get accessMyAccount => 'Acessar minha conta';

  @override
  String get createAccount => 'Criar nova conta';

  @override
  String get welcomeBackTitle => 'Bem-vindo(a) de volta\nao TrabalheJá';

  @override
  String get dontHaveAccount => 'Não tenho uma conta';

  @override
  String get fillFieldsCorrectly =>
      'Por favor, preencha todos os campos corretamente.';

  @override
  String get loginErrorGeneric => 'Erro ao fazer login. Tente novamente.';

  @override
  String get invalidCredentials => 'Email ou senha incorretos.';

  @override
  String get emailNotConfirmed =>
      'Por favor, confirme seu email antes de fazer login.';

  @override
  String get tooManyRequests =>
      'Muitas tentativas. Aguarde alguns instantes e tente novamente.';

  @override
  String get enterEmail => 'Digite seu e-mail';

  @override
  String get emailHint => 'E-mail';

  @override
  String get invalidEmail => 'Por favor, digite um e-mail válido';

  @override
  String get enterPassword => 'Digite sua senha';

  @override
  String get passwordHint => 'Senha';

  @override
  String get passwordMinLength => 'A senha deve ter pelo menos 6 caracteres';

  @override
  String get loginButton => 'Entrar';

  @override
  String get forgotPassword => 'Esqueci minha senha';

  @override
  String get createAccountTitle => 'Primeiro, vamos criar\nsua conta';

  @override
  String get continueButton => 'Continuar';

  @override
  String get alreadyHaveAccount => 'Já tenho uma conta';

  @override
  String get termsText1 => 'Ao se cadastrar, você concorda com nossos ';

  @override
  String get termsLink => 'Termos e Condições';

  @override
  String get termsText2 => ' e ';

  @override
  String get privacyLink => 'Política de Privacidade';

  @override
  String get termsText3 => '.';

  @override
  String get createAccountError => 'Erro ao criar conta. Tente novamente.';

  @override
  String get emailAlreadyRegistered => 'Este email já está cadastrado.';

  @override
  String get invalidEmailOrPassword => 'Email ou senha inválidos.';

  @override
  String createAccountErrorDetails(String error) {
    return 'Erro ao criar conta: $error';
  }

  @override
  String get signupDetailsTitle =>
      'Por último, precisamos\nde mais alguns dados';

  @override
  String get signupDetailsSubtitle =>
      'Vamos precisar que informe alguns dados extras de segurança e contato.';

  @override
  String get enterPhone => 'Qual seu telefone?';

  @override
  String get phoneHint => '(00) 00000-0000';

  @override
  String get enterPhoneError => 'Por favor, digite seu telefone';

  @override
  String get incompletePhone => 'Telefone incompleto';

  @override
  String get choosePassword => 'Escolha uma senha';

  @override
  String get enterPasswordHint => 'Digite uma senha';

  @override
  String get confirmPassword => 'Confirme a senha';

  @override
  String get reenterPassword => 'Digite novamente a senha';

  @override
  String get confirmPasswordError => 'Por favor, confirme sua senha';

  @override
  String get passwordsDoNotMatch => 'As senhas não coincidem';
}
