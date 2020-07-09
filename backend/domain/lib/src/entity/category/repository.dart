import 'package:domain/src/entity/category/category.dart';

abstract class CategoryRepository {

  Future<List<Category>> getByTitlePart(String part);

}
