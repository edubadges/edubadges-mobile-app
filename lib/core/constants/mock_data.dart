import 'package:edubadges/features/account/data/models/agreement_route_model.dart';

class MockData {
  MockData._();

  static const String privacyAgreementTitle = 'Edubadges and your privacy';
  static const String privacyAgreementTitleLong =
      'Edubadges and your privacy - Full Version';

  static const String privacyAgreementTextShort =
      '''Below are the most important points about edubadges and your privacy. In the [full version](https://raw.githubusercontent.com/edubadges/privacy/master/hogeschool-utrecht/edubadges-formal-text-en.md) detailed information about this processing can be found.

University of applied sciences Utrecht is the controller and SURF is the processor for issuing edubadges. For the edubadges platform to function, it is necessary to process your personal data. By clicking 'I have read this', you declare that you have read the [full privacy statement](https://raw.githubusercontent.com/edubadges/privacy/master/hogeschool-utrecht/edubadges-formal-text-en.md).''';

  static const String privacyAgreementTextLong =
      '''Below are the most important points about edubadges and your privacy. In the [full version](https://raw.githubusercontent.com/edubadges/privacy/master/hogeschool-utrecht/edubadges-formal-text-en.md) detailed information about this processing can be found.

University of applied sciences Utrecht is the controller and SURF is the processor for issuing edubadges. For the edubadges platform to function, it is necessary to process your personal data. By using digital badges, Hogeschool Utrecht enables the students and participant to visibly present their acquired competences at other educational institutions and social media such as LinkedIN. With badges the students and participants are enabled to be in charge of their own choices regarding the learning progress and respective learning process.

To issue edubadges, your first name, last name, a unique identifier and email address are processed. In addition the edubadge contains your eduID and supplementary information such as the time of issue, the publisher (University of applied sciences Utrecht) and information about the achievement, educational module and/or learning outcomes. If you have any questions about your privacy, please contact [askprivacy@hu.nl](mailto:askprivacy@hu.nl).

By clicking 'I have read this', you declare that you have read the [full privacy statement](https://raw.githubusercontent.com/edubadges/privacy/master/hogeschool-utrecht/edubadges-formal-text-en.md).''';

  static AgreementRouteModel getMockAgreement(String agreementId) {
    return AgreementRouteModel(
      agreementId: agreementId,
      titleLong: privacyAgreementTitleLong,
      textUrlLong: privacyAgreementTextLong,
      titleShort: privacyAgreementTitle,
      textUrlShort: privacyAgreementTextShort,
    );
  }
}
