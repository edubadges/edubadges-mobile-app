import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/badges_overview/data/datasources/badges_overview_datasource.dart';
import 'package:edubadges/features/badges_overview/data/repositories/badges_overview_repository_impl.dart';
import 'package:edubadges/features/badges_overview/domain/entities/badges_overview_state.dart';
import 'package:edubadges/features/badges_overview/domain/repositories/badges_overview_repository.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final badgesOverviewDataSourceProvider = Provider<BadgesOverviewDataSource>((
  ref,
) {
  final client = ref.read(apiClientProvider);
  return BadgesOverviewDataSourceImpl(client);
});

final badgesOverviewRepositoryProvider = Provider<BadgesOverviewRepository>((
  ref,
) {
  final datasource = ref.read(badgesOverviewDataSourceProvider);
  return BadgesOverviewRepositoryImpl(datasource);
});

final badgesOverviewProvider =
    AsyncNotifierProvider<BadgesOverviewNotifier, BadgesOverviewState>(
      BadgesOverviewNotifier.new,
    );

class BadgesOverviewNotifier extends AsyncNotifier<BadgesOverviewState> {
  Future<void> _ensureTokenFresh() async {
    await ref.read(oidcAuthDataSourceProvider).refreshTokenIfExpired();
  }

  @override
  Future<BadgesOverviewState> build() async {
    await _ensureTokenFresh();
    final repository = ref.read(badgesOverviewRepositoryProvider);

    final results = await Future.wait([
      repository.getBadgeInstances(),
      repository.getDirectAwards(),
      repository.getEnrollments(),
    ]);

    final claimedResult = results[0];
    final unclaimedResult = results[1];
    final requestedResult = results[2];

    final claimedBadges = claimedResult.fold(
      (failure) => throw failure,
      (entities) => entities,
    );

    final unclaimedBadges = unclaimedResult.fold(
      (failure) => throw failure,
      (entities) => entities,
    );

    final requestedBadges = requestedResult.fold(
      (failure) => throw failure,
      (entities) => entities,
    );

    return BadgesOverviewState(
      claimedBadges: claimedBadges,
      unclaimedBadges: unclaimedBadges,
      requestedBadges: requestedBadges,
    );
  }

  /// Refresh the badge instances list.
  /// Set [silent] to keep current data visible while refreshing.
  Future<void> refresh({bool silent = true}) async {
    if (!silent) {
      state = const AsyncLoading();
    }
    try {
      await _ensureTokenFresh();
      final repository = ref.read(badgesOverviewRepositoryProvider);

      final results = await Future.wait([
        repository.getBadgeInstances(),
        repository.getDirectAwards(),
        repository.getEnrollments(),
      ]);

      final claimedResult = results[0];
      final unclaimedResult = results[1];
      final requestedResult = results[2];

      final claimedBadges = claimedResult.fold(
        (failure) => throw failure,
        (entities) => entities,
      );

      final unclaimedBadges = unclaimedResult.fold(
        (failure) => throw failure,
        (entities) => entities,
      );

      final requestedBadges = requestedResult.fold(
        (failure) => throw failure,
        (entities) => entities,
      );

      state = AsyncData(
        BadgesOverviewState(
          claimedBadges: claimedBadges,
          unclaimedBadges: unclaimedBadges,
          requestedBadges: requestedBadges,
        ),
      );
    } catch (error, stackTrace) {
      final AsyncValue<BadgesOverviewState> previous = state;
      final AsyncError<BadgesOverviewState> errorState =
          AsyncError<BadgesOverviewState>(error, stackTrace);
      if (!silent || !previous.hasValue) {
        state = errorState;
      } else {
        // Retain prior badges so background refresh failures stay soft.
        // ignore: invalid_use_of_internal_member
        state = errorState.copyWithPrevious(previous);
      }
    }
  }

}
