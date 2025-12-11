import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_pt.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('pt')
  ];

  /// No description provided for @appTitle.
  ///
  /// In pt, this message translates to:
  /// **'TrabalheJá'**
  String get appTitle;

  /// No description provided for @welcomeBack.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo de volta'**
  String get welcomeBack;

  /// No description provided for @welcome.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo,'**
  String get welcome;

  /// No description provided for @user.
  ///
  /// In pt, this message translates to:
  /// **'Usuário'**
  String get user;

  /// No description provided for @requestFreelancer.
  ///
  /// In pt, this message translates to:
  /// **'Solicitar freelancer'**
  String get requestFreelancer;

  /// No description provided for @requestFreelancerSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Precisa de um serviço? Solicite um freelancer agora e receba propostas'**
  String get requestFreelancerSubtitle;

  /// No description provided for @receivedProposals.
  ///
  /// In pt, this message translates to:
  /// **'Propostas recebidas'**
  String get receivedProposals;

  /// No description provided for @receivedProposalsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Acompanhe as propostas enviadas pelos freelancers'**
  String get receivedProposalsSubtitle;

  /// No description provided for @rateServices.
  ///
  /// In pt, this message translates to:
  /// **'Avaliar serviços'**
  String get rateServices;

  /// No description provided for @rateServicesSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Avalie serviços realizados pelos freelancers'**
  String get rateServicesSubtitle;

  /// No description provided for @back.
  ///
  /// In pt, this message translates to:
  /// **'Voltar'**
  String get back;

  /// No description provided for @welcomeBackToApp.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo(a) de volta\nao TrabalheJá'**
  String get welcomeBackToApp;

  /// No description provided for @chooseLoginMethod.
  ///
  /// In pt, this message translates to:
  /// **'Escolha seu método de entrada da sua conta.'**
  String get chooseLoginMethod;

  /// No description provided for @loginWithEmail.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com email e senha'**
  String get loginWithEmail;

  /// No description provided for @loginWithFacebook.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com Facebook'**
  String get loginWithFacebook;

  /// No description provided for @loginWithGoogle.
  ///
  /// In pt, this message translates to:
  /// **'Entrar com Google'**
  String get loginWithGoogle;

  /// No description provided for @noAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tenho uma conta'**
  String get noAccount;

  /// No description provided for @myData.
  ///
  /// In pt, this message translates to:
  /// **'Meus dados'**
  String get myData;

  /// No description provided for @securityAndPassword.
  ///
  /// In pt, this message translates to:
  /// **'Segurança e senha'**
  String get securityAndPassword;

  /// No description provided for @bankDetails.
  ///
  /// In pt, this message translates to:
  /// **'Dados Bancários'**
  String get bankDetails;

  /// No description provided for @myCards.
  ///
  /// In pt, this message translates to:
  /// **'Meus Cartões'**
  String get myCards;

  /// No description provided for @addresses.
  ///
  /// In pt, this message translates to:
  /// **'Endereços'**
  String get addresses;

  /// No description provided for @termsOfUse.
  ///
  /// In pt, this message translates to:
  /// **'Termos de uso'**
  String get termsOfUse;

  /// No description provided for @privacyPolicy.
  ///
  /// In pt, this message translates to:
  /// **'Política de privacidade'**
  String get privacyPolicy;

  /// No description provided for @logout.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get logout;

  /// No description provided for @logoutConfirmTitle.
  ///
  /// In pt, this message translates to:
  /// **'Sair da conta'**
  String get logoutConfirmTitle;

  /// No description provided for @logoutConfirmMessage.
  ///
  /// In pt, this message translates to:
  /// **'Tem certeza que deseja sair da sua conta?'**
  String get logoutConfirmMessage;

  /// No description provided for @cancel.
  ///
  /// In pt, this message translates to:
  /// **'Cancelar'**
  String get cancel;

  /// No description provided for @exit.
  ///
  /// In pt, this message translates to:
  /// **'Sair'**
  String get exit;

  /// No description provided for @talkToSupport.
  ///
  /// In pt, this message translates to:
  /// **'Falar com suporte'**
  String get talkToSupport;

  /// No description provided for @frequentQuestions.
  ///
  /// In pt, this message translates to:
  /// **'Dúvidas frequentes'**
  String get frequentQuestions;

  /// No description provided for @client.
  ///
  /// In pt, this message translates to:
  /// **'Cliente'**
  String get client;

  /// No description provided for @freelancer.
  ///
  /// In pt, this message translates to:
  /// **'Freelancer'**
  String get freelancer;

  /// No description provided for @language.
  ///
  /// In pt, this message translates to:
  /// **'Idioma'**
  String get language;

  /// No description provided for @selectLanguage.
  ///
  /// In pt, this message translates to:
  /// **'Selecionar idioma'**
  String get selectLanguage;

  /// No description provided for @portuguese.
  ///
  /// In pt, this message translates to:
  /// **'Português'**
  String get portuguese;

  /// No description provided for @english.
  ///
  /// In pt, this message translates to:
  /// **'Inglês'**
  String get english;

  /// No description provided for @nearbyServices.
  ///
  /// In pt, this message translates to:
  /// **'Bicos próximos'**
  String get nearbyServices;

  /// No description provided for @searchServicesTitle.
  ///
  /// In pt, this message translates to:
  /// **'Qual bico você está procurando?'**
  String get searchServicesTitle;

  /// No description provided for @searchServicesHint.
  ///
  /// In pt, this message translates to:
  /// **'Pesquisar serviços'**
  String get searchServicesHint;

  /// No description provided for @selectedClient.
  ///
  /// In pt, this message translates to:
  /// **'Cliente selecionado'**
  String get selectedClient;

  /// No description provided for @nearbyClients.
  ///
  /// In pt, this message translates to:
  /// **'Clientes próximos'**
  String get nearbyClients;

  /// No description provided for @noServicesFound.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum bico encontrado'**
  String get noServicesFound;

  /// No description provided for @noServicesFoundSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Não há solicitações próximas no momento. Tente aumentar seu raio de atuação.'**
  String get noServicesFoundSubtitle;

  /// No description provided for @noSearchResults.
  ///
  /// In pt, this message translates to:
  /// **'Nenhum resultado para \"{query}\"'**
  String noSearchResults(String query);

  /// No description provided for @serviceDetails.
  ///
  /// In pt, this message translates to:
  /// **'Detalhes do serviço'**
  String get serviceDetails;

  /// No description provided for @distanceAway.
  ///
  /// In pt, this message translates to:
  /// **'Em {distance}'**
  String distanceAway(String distance);

  /// No description provided for @deadlineInHours.
  ///
  /// In pt, this message translates to:
  /// **'Em até {hours} horas'**
  String deadlineInHours(int hours);

  /// No description provided for @errorLoggingOut.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao sair: {error}'**
  String errorLoggingOut(String error);

  /// No description provided for @all.
  ///
  /// In pt, this message translates to:
  /// **'Todas'**
  String get all;

  /// No description provided for @pending.
  ///
  /// In pt, this message translates to:
  /// **'Pendentes'**
  String get pending;

  /// No description provided for @pendingCount.
  ///
  /// In pt, this message translates to:
  /// **'Pendentes ({count})'**
  String pendingCount(int count);

  /// No description provided for @accepted.
  ///
  /// In pt, this message translates to:
  /// **'Aceitas'**
  String get accepted;

  /// No description provided for @acceptedCount.
  ///
  /// In pt, this message translates to:
  /// **'Aceitas ({count})'**
  String acceptedCount(int count);

  /// No description provided for @completed.
  ///
  /// In pt, this message translates to:
  /// **'Concluídas'**
  String get completed;

  /// No description provided for @completedCount.
  ///
  /// In pt, this message translates to:
  /// **'Concluídas ({count})'**
  String completedCount(int count);

  /// No description provided for @sentProposals.
  ///
  /// In pt, this message translates to:
  /// **'Propostas enviadas'**
  String get sentProposals;

  /// No description provided for @proposalsReceivedCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 proposta recebida} other{{count} propostas recebidas}}'**
  String proposalsReceivedCount(int count);

  /// No description provided for @proposalsSentCount.
  ///
  /// In pt, this message translates to:
  /// **'{count, plural, =1{1 proposta enviada} other{{count} propostas enviadas}}'**
  String proposalsSentCount(int count);

  /// No description provided for @proposalAcceptedSuccess.
  ///
  /// In pt, this message translates to:
  /// **'Proposta aceita com sucesso!'**
  String get proposalAcceptedSuccess;

  /// No description provided for @proposalRejected.
  ///
  /// In pt, this message translates to:
  /// **'Proposta rejeitada.'**
  String get proposalRejected;

  /// No description provided for @errorAcceptingProposal.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao aceitar proposta'**
  String get errorAcceptingProposal;

  /// No description provided for @errorAcceptingProposalMessage.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível aceitar a proposta. Tente novamente.'**
  String get errorAcceptingProposalMessage;

  /// No description provided for @errorRejectingProposal.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao rejeitar proposta'**
  String get errorRejectingProposal;

  /// No description provided for @errorRejectingProposalMessage.
  ///
  /// In pt, this message translates to:
  /// **'Não foi possível rejeitar a proposta. Tente novamente.'**
  String get errorRejectingProposalMessage;

  /// No description provided for @chatInDevelopment.
  ///
  /// In pt, this message translates to:
  /// **'Chat em desenvolvimento'**
  String get chatInDevelopment;

  /// No description provided for @timeframe.
  ///
  /// In pt, this message translates to:
  /// **'Em até {time} {unit}'**
  String timeframe(int time, String unit);

  /// No description provided for @reject.
  ///
  /// In pt, this message translates to:
  /// **'Rejeitar'**
  String get reject;

  /// No description provided for @accept.
  ///
  /// In pt, this message translates to:
  /// **'Aceitar'**
  String get accept;

  /// No description provided for @proposalAcceptedBadge.
  ///
  /// In pt, this message translates to:
  /// **'Proposta Aceita'**
  String get proposalAcceptedBadge;

  /// No description provided for @paymentAction.
  ///
  /// In pt, this message translates to:
  /// **'Realize o pagamento para iniciar o serviço'**
  String get paymentAction;

  /// No description provided for @paymentReleasedBadge.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento liberado para o freelancer ✓'**
  String get paymentReleasedBadge;

  /// No description provided for @paymentHeldBadge.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento realizado! Libere após finalizar o serviço'**
  String get paymentHeldBadge;

  /// No description provided for @makePayment.
  ///
  /// In pt, this message translates to:
  /// **'Realizar Pagamento'**
  String get makePayment;

  /// No description provided for @chatWithFreelancer.
  ///
  /// In pt, this message translates to:
  /// **'Conversar com Freelancer'**
  String get chatWithFreelancer;

  /// No description provided for @chat.
  ///
  /// In pt, this message translates to:
  /// **'Conversar'**
  String get chat;

  /// No description provided for @releasePayment.
  ///
  /// In pt, this message translates to:
  /// **'Liberar Pagamento'**
  String get releasePayment;

  /// No description provided for @paidBadge.
  ///
  /// In pt, this message translates to:
  /// **'PAGA'**
  String get paidBadge;

  /// No description provided for @released.
  ///
  /// In pt, this message translates to:
  /// **'Liberado'**
  String get released;

  /// No description provided for @retained.
  ///
  /// In pt, this message translates to:
  /// **'Retido'**
  String get retained;

  /// No description provided for @paymentReleased.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento Liberado'**
  String get paymentReleased;

  /// No description provided for @paymentRetained.
  ///
  /// In pt, this message translates to:
  /// **'Pagamento Retido'**
  String get paymentRetained;

  /// No description provided for @waitingConfirmation.
  ///
  /// In pt, this message translates to:
  /// **'Aguardando confirmação'**
  String get waitingConfirmation;

  /// No description provided for @serviceLabel.
  ///
  /// In pt, this message translates to:
  /// **'Serviço:'**
  String get serviceLabel;

  /// No description provided for @pix.
  ///
  /// In pt, this message translates to:
  /// **'PIX'**
  String get pix;

  /// No description provided for @creditCard.
  ///
  /// In pt, this message translates to:
  /// **'Cartão de Crédito'**
  String get creditCard;

  /// No description provided for @notInformed.
  ///
  /// In pt, this message translates to:
  /// **'Não informado'**
  String get notInformed;

  /// No description provided for @dateNotAvailable.
  ///
  /// In pt, this message translates to:
  /// **'Data não disponível'**
  String get dateNotAvailable;

  /// No description provided for @invalidDate.
  ///
  /// In pt, this message translates to:
  /// **'Data inválida'**
  String get invalidDate;

  /// No description provided for @atTime.
  ///
  /// In pt, this message translates to:
  /// **'às'**
  String get atTime;

  /// No description provided for @accessMyAccount.
  ///
  /// In pt, this message translates to:
  /// **'Acessar minha conta'**
  String get accessMyAccount;

  /// No description provided for @createAccount.
  ///
  /// In pt, this message translates to:
  /// **'Criar nova conta'**
  String get createAccount;

  /// No description provided for @welcomeBackTitle.
  ///
  /// In pt, this message translates to:
  /// **'Bem-vindo(a) de volta\nao TrabalheJá'**
  String get welcomeBackTitle;

  /// No description provided for @dontHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Não tenho uma conta'**
  String get dontHaveAccount;

  /// No description provided for @fillFieldsCorrectly.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, preencha todos os campos corretamente.'**
  String get fillFieldsCorrectly;

  /// No description provided for @loginErrorGeneric.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao fazer login. Tente novamente.'**
  String get loginErrorGeneric;

  /// No description provided for @invalidCredentials.
  ///
  /// In pt, this message translates to:
  /// **'Email ou senha incorretos.'**
  String get invalidCredentials;

  /// No description provided for @emailNotConfirmed.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, confirme seu email antes de fazer login.'**
  String get emailNotConfirmed;

  /// No description provided for @tooManyRequests.
  ///
  /// In pt, this message translates to:
  /// **'Muitas tentativas. Aguarde alguns instantes e tente novamente.'**
  String get tooManyRequests;

  /// No description provided for @enterEmail.
  ///
  /// In pt, this message translates to:
  /// **'Digite seu e-mail'**
  String get enterEmail;

  /// No description provided for @emailHint.
  ///
  /// In pt, this message translates to:
  /// **'E-mail'**
  String get emailHint;

  /// No description provided for @invalidEmail.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite um e-mail válido'**
  String get invalidEmail;

  /// No description provided for @enterPassword.
  ///
  /// In pt, this message translates to:
  /// **'Digite sua senha'**
  String get enterPassword;

  /// No description provided for @passwordHint.
  ///
  /// In pt, this message translates to:
  /// **'Senha'**
  String get passwordHint;

  /// No description provided for @passwordMinLength.
  ///
  /// In pt, this message translates to:
  /// **'A senha deve ter pelo menos 6 caracteres'**
  String get passwordMinLength;

  /// No description provided for @loginButton.
  ///
  /// In pt, this message translates to:
  /// **'Entrar'**
  String get loginButton;

  /// No description provided for @forgotPassword.
  ///
  /// In pt, this message translates to:
  /// **'Esqueci minha senha'**
  String get forgotPassword;

  /// No description provided for @createAccountTitle.
  ///
  /// In pt, this message translates to:
  /// **'Primeiro, vamos criar\nsua conta'**
  String get createAccountTitle;

  /// No description provided for @continueButton.
  ///
  /// In pt, this message translates to:
  /// **'Continuar'**
  String get continueButton;

  /// No description provided for @alreadyHaveAccount.
  ///
  /// In pt, this message translates to:
  /// **'Já tenho uma conta'**
  String get alreadyHaveAccount;

  /// No description provided for @termsText1.
  ///
  /// In pt, this message translates to:
  /// **'Ao se cadastrar, você concorda com nossos '**
  String get termsText1;

  /// No description provided for @termsLink.
  ///
  /// In pt, this message translates to:
  /// **'Termos e Condições'**
  String get termsLink;

  /// No description provided for @termsText2.
  ///
  /// In pt, this message translates to:
  /// **' e '**
  String get termsText2;

  /// No description provided for @privacyLink.
  ///
  /// In pt, this message translates to:
  /// **'Política de Privacidade'**
  String get privacyLink;

  /// No description provided for @termsText3.
  ///
  /// In pt, this message translates to:
  /// **'.'**
  String get termsText3;

  /// No description provided for @createAccountError.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao criar conta. Tente novamente.'**
  String get createAccountError;

  /// No description provided for @emailAlreadyRegistered.
  ///
  /// In pt, this message translates to:
  /// **'Este email já está cadastrado.'**
  String get emailAlreadyRegistered;

  /// No description provided for @invalidEmailOrPassword.
  ///
  /// In pt, this message translates to:
  /// **'Email ou senha inválidos.'**
  String get invalidEmailOrPassword;

  /// No description provided for @createAccountErrorDetails.
  ///
  /// In pt, this message translates to:
  /// **'Erro ao criar conta: {error}'**
  String createAccountErrorDetails(String error);

  /// No description provided for @signupDetailsTitle.
  ///
  /// In pt, this message translates to:
  /// **'Por último, precisamos\nde mais alguns dados'**
  String get signupDetailsTitle;

  /// No description provided for @signupDetailsSubtitle.
  ///
  /// In pt, this message translates to:
  /// **'Vamos precisar que informe alguns dados extras de segurança e contato.'**
  String get signupDetailsSubtitle;

  /// No description provided for @enterPhone.
  ///
  /// In pt, this message translates to:
  /// **'Qual seu telefone?'**
  String get enterPhone;

  /// No description provided for @phoneHint.
  ///
  /// In pt, this message translates to:
  /// **'(00) 00000-0000'**
  String get phoneHint;

  /// No description provided for @enterPhoneError.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, digite seu telefone'**
  String get enterPhoneError;

  /// No description provided for @incompletePhone.
  ///
  /// In pt, this message translates to:
  /// **'Telefone incompleto'**
  String get incompletePhone;

  /// No description provided for @choosePassword.
  ///
  /// In pt, this message translates to:
  /// **'Escolha uma senha'**
  String get choosePassword;

  /// No description provided for @enterPasswordHint.
  ///
  /// In pt, this message translates to:
  /// **'Digite uma senha'**
  String get enterPasswordHint;

  /// No description provided for @confirmPassword.
  ///
  /// In pt, this message translates to:
  /// **'Confirme a senha'**
  String get confirmPassword;

  /// No description provided for @reenterPassword.
  ///
  /// In pt, this message translates to:
  /// **'Digite novamente a senha'**
  String get reenterPassword;

  /// No description provided for @confirmPasswordError.
  ///
  /// In pt, this message translates to:
  /// **'Por favor, confirme sua senha'**
  String get confirmPasswordError;

  /// No description provided for @passwordsDoNotMatch.
  ///
  /// In pt, this message translates to:
  /// **'As senhas não coincidem'**
  String get passwordsDoNotMatch;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'pt'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'pt':
      return AppLocalizationsPt();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
