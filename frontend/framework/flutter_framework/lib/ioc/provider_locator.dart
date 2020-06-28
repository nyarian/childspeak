import 'package:estd/ioc/service_locator.dart';
import 'package:flutter/widgets.dart';
import 'package:provider/provider.dart';

class ProviderServiceLocator implements ServiceLocator {

  final BuildContext _context;

  ProviderServiceLocator(this._context);

  @override
  T get<T>() => Provider.of<T>(_context, listen: false);

}
