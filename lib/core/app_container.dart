import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

/// Root [ProviderContainer] from [main], for reads outside the widget tree.
ProviderContainer? appProviderContainer;

/// [GoRouter] instance registered from [appRouter]; avoids importing [appRouter]
/// from general-terms navigation (circular import with [routes.dart]).
GoRouter? appGoRouter;
