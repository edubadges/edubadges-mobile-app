import 'package:edubadges/features/catalog/data/models/catalog_model.dart';

abstract class CatalogDataSource {
  Future<List<CatalogModel>> getCatalogs();
  Future<CatalogModel> getCatalogById(String id);
}
