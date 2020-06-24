import 'package:equatable/equatable.dart';

class Entity with EquatableMixin {

  final EntityId id;
  final String title;
  final Uri depiction;

  Entity(this.id, this.title, this.depiction);

  @override
  List<Object> get props => <Object>[id, title, depiction];

}

class EntityId with EquatableMixin {

  final String asString;

  EntityId(this.asString);

  @override
  List<Object> get props => <Object>[asString];

}
