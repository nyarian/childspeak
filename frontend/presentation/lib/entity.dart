import 'package:domain/entity.dart';
import 'package:equatable/equatable.dart';

class EntityPM with EquatableMixin {
  final Entity _origin;

  EntityPM(this._origin);

  // ignore: prefer_constructors_over_static_methods
  static EntityPM of(Entity entity) => EntityPM(entity);

  String get title => _origin.title;

  String get imageUrl => _origin.depiction.toString();

  @override
  List<Object> get props => <Object>[_origin];

  @override
  bool get stringify => true;

}
