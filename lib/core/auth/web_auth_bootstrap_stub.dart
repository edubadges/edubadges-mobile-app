import 'package:flutter_riverpod/flutter_riverpod.dart';

/// No-op on non-web platforms; the OIDC redirect is only completed on web.
Future<void> completeWebLoginRedirect(ProviderContainer container) async {}
