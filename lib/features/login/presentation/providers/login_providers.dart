import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/login/data/datasources/login_datasource.dart';
import 'package:edubadges/features/login/data/datasources/login_remote_datasource.dart';
import 'package:edubadges/features/login/data/models/login_user_status.dart';
import 'package:edubadges/features/login/data/repositories/login_repository_impl.dart';
import 'package:edubadges/features/login/domain/repositories/login_repository.dart';
import 'package:edubadges/shared/presentation/providers/auth_providers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final loginDataSourceProvider = Provider.autoDispose<LoginDataSource>((ref) {
  final oidc = ref.watch(oidcAuthDataSourceProvider);
  return LoginDataSourceImpl(oidc);
});

final loginRemoteDataSourceProvider = Provider.autoDispose<LoginRemoteDataSource>((ref) {
  final client = ref.watch(apiClientProvider);
  return LoginRemoteDataSourceImpl(client);
});

final loginRepositoryProvider = Provider.autoDispose<LoginRepository>((ref) {
  final local = ref.watch(loginDataSourceProvider);
  final remote = ref.watch(loginRemoteDataSourceProvider);
  return LoginRepositoryImpl(local, remote);
});

/// What the API says about the signed-in user right after login: whether
/// they still have to accept the general terms, for instance.
///
/// Null while nobody is signed in, without calling the API. The router keeps
/// this provider alive, so it must not call `/login` without a session.
final loginStatusProvider = FutureProvider.autoDispose<LoginUserAuthStatus?>((
  ref,
) async {
  final bool loggedIn = ref.watch(
    authProvider.select((state) => state.asData?.value ?? false),
  );
  if (!loggedIn) return null;
  final remoteDataSource = ref.watch(loginRemoteDataSourceProvider);
  return remoteDataSource.login();
});
