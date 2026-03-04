import 'package:edubadges/core/constants/assets.dart';
import 'package:edubadges/core/constants/route_path.dart';
import 'package:edubadges/core/widgets/max_width_wrapper.dart';
import 'package:edubadges/core/widgets/outlined_button.dart';
import 'package:edubadges/core/widgets/primary_button.dart';
import 'package:edubadges/l10n/app_localizations.dart';
import 'package:edubadges/shared/presentation/providers/device_registration_providers.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class NotificationPermissionPage extends ConsumerWidget {
  const NotificationPermissionPage({super.key});

  Future<void> _requestPermission(BuildContext context, WidgetRef ref) async {
    await Permission.notification.request();
    final notificationSettings = await FirebaseMessaging.instance.requestPermission();

    if (notificationSettings.authorizationStatus == AuthorizationStatus.authorized) {
      await ref.read(deviceRegistrationServiceProvider).registerDevice();
    }

    if (context.mounted) {
      context.go(RoutePath.main);
    }
  }

  void _skipPermission(BuildContext context) {
    context.go(RoutePath.main);
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = AppLocalizations.of(context);
    final theme = Theme.of(context);
    final colorScheme = theme.colorScheme;
    final textTheme = theme.textTheme;

    return Scaffold(
      backgroundColor: colorScheme.surfaceContainer,
      body: MaxWidthWrapper(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 24.0),
          child: Column(
            children: [
              const Spacer(flex: 2),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 50.0),
                child: Column(
                  children: [
                    Text(
                      l10n.notificationPermissionsTitle,
                      style: textTheme.headlineLarge?.copyWith(color: colorScheme.onSurface),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    Text(
                      l10n.notificationPermissionsSubtitle,
                      style: textTheme.bodyMedium?.copyWith(color: colorScheme.onSurface),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
              ConstrainedBox(
                constraints: const BoxConstraints(
                  maxHeight: 400,
                ),
                child: Image.asset(
                  Assets.imageNotifications,
                  width: double.infinity,
                  fit: BoxFit.contain,
                  alignment: Alignment.center,
                ),
              ),
              const Spacer(flex: 3),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  children: [
                    Text(
                      l10n.notificationPermissionsLabel,
                      style: textTheme.labelMedium?.copyWith(color: colorScheme.onSurface),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    PrimaryButton(
                      text: l10n.notificationPermissionsButtonAllow,
                      onPressed: () => _requestPermission(context, ref),
                    ),
                    const SizedBox(height: 16),
                    CustomOutlinedButton(
                      text: l10n.notificationPermissionsButtonDeny,
                      onPressed: () => _skipPermission(context),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
