import 'package:equatable/equatable.dart';

class Category with EquatableMixin {
  final String title;

  Category(this.title);

  // ignore: prefer_constructors_over_static_methods
  static Category fromString(String title) => Category(title);

  @override
  List<Object> get props => <Object>[title];

  @override
  bool get stringify => true;
}
