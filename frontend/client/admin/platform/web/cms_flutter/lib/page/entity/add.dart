import 'package:bloc/entity/add/bloc.dart';
import 'package:cms/assembly/bloc/entity_crud.dart';
import 'package:cms/widget/text_field.dart';
import 'package:flutter/material.dart';
import 'package:flutter_framework/ioc/provider_locator.dart';

class AddEntityPage extends StatefulWidget {
  static const String name = '/entity/add';

  static Widget builder(BuildContext context) => const AddEntityPage();

  const AddEntityPage({Key key}) : super(key: key);

  @override
  _AddEntityPageState createState() => _AddEntityPageState();
}

class _AddEntityPageState extends State<AddEntityPage> {
  final TextEditingController _titleController = TextEditingController();
  final TextEditingController _imageUrlController = TextEditingController();
  EntityCrudBloc _bloc;
  String _currentCode = 'ru';

  @override
  void initState() {
    super.initState();
    _bloc = EntityCrudBlocFactory().create(ProviderServiceLocator(context));
  }

  @override
  void dispose() {
    super.dispose();
    _bloc.close();
  }

  @override
  Widget build(BuildContext context) => Scaffold(
        body: StreamBuilder<EntityCrudState>(
          stream: _bloc.state,
          initialData: _bloc.currentState,
          builder: (ctx, snapshot) => Center(
            child: _buildStateBasedTree(ctx, snapshot.data),
          ),
        ),
      );

  Widget _buildStateBasedTree(BuildContext context, EntityCrudState state) {
    if (state.hasError) {
      return _buildErrorTree(context, state);
    } else if (state.status == OperationStatus.running) {
      return _buildRunningOperationTree(context, state);
    } else if (state.status == OperationStatus.success) {
      return _buildSuccessfulOperationTree(context, state);
    } else {
      return _buildCreateEntityForm(context);
    }
  }

  Widget _buildRunningOperationTree(
          BuildContext context, EntityCrudState state) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          Text('${_deductOperationTitle(state.operation)} operation is '
              'running...'),
        ],
      );

  String _deductOperationTitle(CrudOperation operation) {
    switch (operation) {
      case CrudOperation.create:
        return 'Creation';
    }
    throw ArgumentError.notNull('operation');
  }

  Widget _buildErrorTree(BuildContext context, EntityCrudState state) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('Error occurred: ${state.error.toString()}'),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _bloc.onErrorProcessedEvent,
          )
        ],
      );

  Widget _buildSuccessfulOperationTree(
          BuildContext context, EntityCrudState state) =>
      Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text('${_deductOperationTitle(state.operation)} operation '
              'successful!'),
          RaisedButton(
            color: Theme.of(context).accentColor,
            onPressed: _bloc.onSuccessProcessedEvent,
            child: Padding(
              padding: const EdgeInsets.all(8),
              child:
                  Text('Nice', style: Theme.of(context).accentTextTheme.button),
            ),
          ),
        ],
      );

  Widget _buildCreateEntityForm(BuildContext context) => Form(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            _buildTitleField(),
            _buildImageUrlField(),
            ..._buildLocalePicker(),
            _buildCreateEntityCTA(Theme.of(context)),
          ],
        ),
      );

  Widget _buildTitleField() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ColoredTextFormField(
          controller: _titleController,
          autoFocus: true,
          labelText: 'Entity name',
          hintText: 'Name...',
          keyboardType: TextInputType.text,
        ),
      );

  Widget _buildImageUrlField() => Padding(
        padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
        child: ColoredTextFormField(
          controller: _imageUrlController,
          labelText: 'Image url',
          hintText: 'Image url...',
          keyboardType: TextInputType.url,
        ),
      );

  List<Widget> _buildLocalePicker() => <Widget>[
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: RadioListTile<String>(
            title: const Text('en'),
            value: 'en',
            groupValue: _currentCode,
            onChanged: (code) => setState(() => _currentCode = code),
          ),
        ),
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
          child: RadioListTile<String>(
            title: const Text('ru'),
            value: 'ru',
            groupValue: _currentCode,
            onChanged: (code) => setState(() => _currentCode = code),
          ),
        ),
      ];

  Widget _buildCreateEntityCTA(ThemeData theme) => Padding(
        padding: const EdgeInsets.only(top: 8, left: 16, right: 16),
        child: SizedBox(
          child: RaisedButton(
            color: theme.accentColor,
            onPressed: () => _bloc.onCreateEntityEvent(
              localeCode: _currentCode,
              title: _titleController.text,
              depictionUrl: _imageUrlController.text,
            ),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: Text('Create entity', style: theme.accentTextTheme.button),
            ),
          ),
        ),
      );
}
