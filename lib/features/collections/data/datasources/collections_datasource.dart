import 'package:edubadges/features/collections/data/models/collections_model.dart';

abstract class CollectionsDataSource {
  Future<List<CollectionsModel>> getCollectionss();
  Future<CollectionsModel> getCollectionsById(String id);
}
