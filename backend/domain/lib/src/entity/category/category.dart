import 'package:meta/meta.dart';

@immutable
class Category {
  final String title;

  const Category(this.title);

  // ignore: prefer_constructors_over_static_methods
  static Category fromString(String title) => Category(title);

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is Category &&
          runtimeType == other.runtimeType &&
          title == other.title;

  @override
  int get hashCode => title.hashCode;

  @override
  String toString() => 'Category{title: $title}';
}
