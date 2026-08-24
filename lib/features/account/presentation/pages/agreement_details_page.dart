import 'package:edubadges/features/account/data/models/agreement_route_model.dart';
import 'package:edubadges/features/account/presentation/widgets/agreement_details_view.dart';
import 'package:flutter/material.dart';

class AgreementDetailsPage extends StatelessWidget {
  final AgreementRouteModel agreement;

  const AgreementDetailsPage({super.key, required this.agreement});

  @override
  Widget build(BuildContext context) {
    return AgreementDetailsView(agreement: agreement);
  }
}
