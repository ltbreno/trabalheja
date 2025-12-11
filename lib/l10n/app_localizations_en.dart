// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'TrabalheJá';

  @override
  String get welcomeBack => 'Welcome back';

  @override
  String get welcome => 'Welcome,';

  @override
  String get user => 'User';

  @override
  String get requestFreelancer => 'Request freelancer';

  @override
  String get requestFreelancerSubtitle =>
      'Need a service? Request a freelancer now and receive proposals';

  @override
  String get receivedProposals => 'Received proposals';

  @override
  String get receivedProposalsSubtitle => 'Track proposals sent by freelancers';

  @override
  String get rateServices => 'Rate services';

  @override
  String get rateServicesSubtitle => 'Rate services performed by freelancers';

  @override
  String get back => 'Back';

  @override
  String get welcomeBackToApp => 'Welcome back\nto TrabalheJá';

  @override
  String get chooseLoginMethod => 'Choose your login method.';

  @override
  String get loginWithEmail => 'Login with email and password';

  @override
  String get loginWithFacebook => 'Login with Facebook';

  @override
  String get loginWithGoogle => 'Login with Google';

  @override
  String get noAccount => 'I don\'t have an account';

  @override
  String get myData => 'My data';

  @override
  String get securityAndPassword => 'Security and password';

  @override
  String get bankDetails => 'Bank Details';

  @override
  String get myCards => 'My Cards';

  @override
  String get addresses => 'Addresses';

  @override
  String get termsOfUse => 'Terms of use';

  @override
  String get privacyPolicy => 'Privacy policy';

  @override
  String get logout => 'Log out';

  @override
  String get logoutConfirmTitle => 'Log out';

  @override
  String get logoutConfirmMessage =>
      'Are you sure you want to log out of your account?';

  @override
  String get cancel => 'Cancel';

  @override
  String get exit => 'Log out';

  @override
  String get talkToSupport => 'Talk to support';

  @override
  String get frequentQuestions => 'Frequently asked questions';

  @override
  String get client => 'Client';

  @override
  String get freelancer => 'Freelancer';

  @override
  String get language => 'Language';

  @override
  String get selectLanguage => 'Select language';

  @override
  String get portuguese => 'Portuguese';

  @override
  String get english => 'English';

  @override
  String get nearbyServices => 'Nearby jobs';

  @override
  String get searchServicesTitle => 'What job are you looking for?';

  @override
  String get searchServicesHint => 'Search services';

  @override
  String get selectedClient => 'Selected client';

  @override
  String get nearbyClients => 'Nearby clients';

  @override
  String get noServicesFound => 'No jobs found';

  @override
  String get noServicesFoundSubtitle =>
      'No nearby requests at the moment. Try increasing your service radius.';

  @override
  String noSearchResults(String query) {
    return 'No results for \"$query\"';
  }

  @override
  String get serviceDetails => 'Service details';

  @override
  String distanceAway(String distance) {
    return 'At $distance';
  }

  @override
  String deadlineInHours(int hours) {
    return 'Within $hours hours';
  }

  @override
  String errorLoggingOut(String error) {
    return 'Error logging out: $error';
  }

  @override
  String get all => 'All';

  @override
  String get pending => 'Pending';

  @override
  String pendingCount(int count) {
    return 'Pending ($count)';
  }

  @override
  String get accepted => 'Accepted';

  @override
  String acceptedCount(int count) {
    return 'Accepted ($count)';
  }

  @override
  String get completed => 'Completed';

  @override
  String completedCount(int count) {
    return 'Completed ($count)';
  }

  @override
  String get sentProposals => 'Sent proposals';

  @override
  String proposalsReceivedCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count received proposals',
      one: '1 received proposal',
    );
    return '$_temp0';
  }

  @override
  String proposalsSentCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count sent proposals',
      one: '1 sent proposal',
    );
    return '$_temp0';
  }

  @override
  String get proposalAcceptedSuccess => 'Proposal accepted successfully!';

  @override
  String get proposalRejected => 'Proposal rejected.';

  @override
  String get errorAcceptingProposal => 'Error accepting proposal';

  @override
  String get errorAcceptingProposalMessage =>
      'Could not accept proposal. Please try again.';

  @override
  String get errorRejectingProposal => 'Error rejecting proposal';

  @override
  String get errorRejectingProposalMessage =>
      'Could not reject proposal. Please try again.';

  @override
  String get chatInDevelopment => 'Chat in development';

  @override
  String timeframe(int time, String unit) {
    return 'Within $time $unit';
  }

  @override
  String get reject => 'Reject';

  @override
  String get accept => 'Accept';

  @override
  String get proposalAcceptedBadge => 'Proposal Accepted';

  @override
  String get paymentAction => 'Make payment to start service';

  @override
  String get paymentReleasedBadge => 'Payment released to freelancer ✓';

  @override
  String get paymentHeldBadge =>
      'Payment made! Release after service completion';

  @override
  String get makePayment => 'Make Payment';

  @override
  String get chatWithFreelancer => 'Chat with Freelancer';

  @override
  String get chat => 'Chat';

  @override
  String get releasePayment => 'Release Payment';

  @override
  String get paidBadge => 'PAID';

  @override
  String get released => 'Released';

  @override
  String get retained => 'Retained';

  @override
  String get paymentReleased => 'Payment Released';

  @override
  String get paymentRetained => 'Payment Retained';

  @override
  String get waitingConfirmation => 'Waiting confirmation';

  @override
  String get serviceLabel => 'Service:';

  @override
  String get pix => 'PIX';

  @override
  String get creditCard => 'Credit Card';

  @override
  String get notInformed => 'Not informed';

  @override
  String get dateNotAvailable => 'Date not available';

  @override
  String get invalidDate => 'Invalid date';

  @override
  String get atTime => 'at';

  @override
  String get accessMyAccount => 'Access my account';

  @override
  String get createAccount => 'Create new account';

  @override
  String get welcomeBackTitle => 'Welcome back\nto TrabalheJá';

  @override
  String get dontHaveAccount => 'I don\'t have an account';

  @override
  String get fillFieldsCorrectly => 'Please fill all fields correctly.';

  @override
  String get loginErrorGeneric => 'Error logging in. Please try again.';

  @override
  String get invalidCredentials => 'Invalid email or password.';

  @override
  String get emailNotConfirmed =>
      'Please confirm your email before logging in.';

  @override
  String get tooManyRequests =>
      'Too many attempts. Please wait a moment and try again.';

  @override
  String get enterEmail => 'Enter your email';

  @override
  String get emailHint => 'Email';

  @override
  String get invalidEmail => 'Please enter a valid email';

  @override
  String get enterPassword => 'Enter your password';

  @override
  String get passwordHint => 'Password';

  @override
  String get passwordMinLength => 'Password must be at least 6 characters';

  @override
  String get loginButton => 'Login';

  @override
  String get forgotPassword => 'Forgot my password';

  @override
  String get createAccountTitle => 'First, let\'s create\nyour account';

  @override
  String get continueButton => 'Continue';

  @override
  String get alreadyHaveAccount => 'I already have an account';

  @override
  String get termsText1 => 'By signing up, you agree to our ';

  @override
  String get termsLink => 'Terms and Conditions';

  @override
  String get termsText2 => ' and ';

  @override
  String get privacyLink => 'Privacy Policy';

  @override
  String get termsText3 => '.';

  @override
  String get createAccountError => 'Error creating account. Please try again.';

  @override
  String get emailAlreadyRegistered => 'This email is already registered.';

  @override
  String get invalidEmailOrPassword => 'Invalid email or password.';

  @override
  String createAccountErrorDetails(String error) {
    return 'Error creating account: $error';
  }

  @override
  String get signupDetailsTitle => 'Lastly, we need\na few more details';

  @override
  String get signupDetailsSubtitle =>
      'We need some extra security and contact details.';

  @override
  String get enterPhone => 'What is your phone number?';

  @override
  String get phoneHint => '(00) 00000-0000';

  @override
  String get enterPhoneError => 'Please enter your phone number';

  @override
  String get incompletePhone => 'Incomplete phone number';

  @override
  String get choosePassword => 'Choose a password';

  @override
  String get enterPasswordHint => 'Enter a password';

  @override
  String get confirmPassword => 'Confirm password';

  @override
  String get reenterPassword => 'Enter password again';

  @override
  String get confirmPasswordError => 'Please confirm your password';

  @override
  String get passwordsDoNotMatch => 'Passwords do not match';
}
