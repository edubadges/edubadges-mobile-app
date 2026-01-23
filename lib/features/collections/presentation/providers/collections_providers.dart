import 'package:edubadges/core/network/network_providers.dart';
import 'package:edubadges/features/collections/data/datasources/collections_datasource.dart';
import 'package:edubadges/features/collections/data/models/collections_model.dart';
import 'package:edubadges/features/collections/data/repositories/collections_repository_impl.dart';
import 'package:edubadges/features/collections/domain/repositories/collections_repository.dart';
import 'package:edubadges/features/collections/domain/usecases/create_collection_use_case.dart';
import 'package:edubadges/features/collections/domain/usecases/delete_collection_use_case.dart';
import 'package:edubadges/features/collections/domain/usecases/update_collection_use_case.dart';
import 'package:edubadges/features/collections/presentation/state/collections_notifier.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final collectionsDataSourceProvider = Provider<CollectionsDataSource>((ref) {
  final client = ref.read(apiClientProvider);
  return CollectionsDataSourceImpl(client);
});

final collectionsRepositoryProvider = Provider<CollectionsRepository>((ref) {
  final dataSource = ref.read(collectionsDataSourceProvider);
  return CollectionsRepositoryImpl(dataSource);
});

final deleteCollectionUseCaseProvider = Provider<DeleteCollectionUseCase>((
  ref,
) {
  final repository = ref.read(collectionsRepositoryProvider);
  return DeleteCollectionUseCase(repository: repository);
});

final updateCollectionUseCaseProvider = Provider<UpdateCollectionUseCase>((
  ref,
) {
  final repository = ref.read(collectionsRepositoryProvider);
  return UpdateCollectionUseCase(repository: repository);
});

final createCollectionUseCaseProvider = Provider<CreateCollectionUseCase>((
  ref,
) {
  final repository = ref.read(collectionsRepositoryProvider);
  return CreateCollectionUseCase(repository: repository);
});

final collectionsProvider =
    AsyncNotifierProvider<CollectionsNotifier, List<CollectionsModel>>(
      CollectionsNotifier.new,
    );
