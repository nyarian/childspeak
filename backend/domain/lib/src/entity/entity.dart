import 'package:built_collection/built_collection.dart';
import 'package:equatable/equatable.dart';

class Entity with EquatableMixin {
  final EntityId id;
  final String title;
  final Uri depiction;
  final BuiltList<Category> categories;

  Entity(this.id, this.title, this.depiction, this.categories)
      : assert(
  title != null, "'title' is a required argument and can't be null"),
        assert(
        categories != null,
        "'categories' is a required argument and can't be null (pass empty "
            'list if the object does not have any)');

  Entity.create(String title, Uri depiction, BuiltList<Category>categories)
      : this(null, title, depiction, categories);

  @override
  List<Object> get props => <Object>[id, title, depiction, categories];
}

class EntityId with EquatableMixin {
  final String asString;

  EntityId(this.asString);

  @override
  List<Object> get props => <Object>[asString];
}

class Category with EquatableMixin {
  final String title;

  Category(this.title);

  @override
  List<Object> get props => <Object>[title];
}
