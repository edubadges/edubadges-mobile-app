import 'package:edubadges/core/constants/assets.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

class BadgesOverviewPage extends StatelessWidget {
  const BadgesOverviewPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: SvgPicture.asset(Assets.imageLogo), centerTitle: true),
      body: const Center(child: Text('BadgesOverview Page')),
    );
  }
}
