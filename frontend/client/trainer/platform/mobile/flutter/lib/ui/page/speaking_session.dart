import 'dart:async';

import 'package:bloc/entity/category/bloc.dart';
import 'package:built_collection/built_collection.dart';
import 'package:childspeak/assembly/bloc/category.dart';
import 'package:childspeak/assembly/framework/speaker.dart';
import 'package:childspeak/i18n/registry.dart';
import 'package:domain/entity.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_framework/domain/entity/speaker.dart';
import 'package:presentation/entity.dart';
import 'package:bloc/entity/bloc.dart';
import 'package:childspeak/assembly/bloc/entities.dart';
import 'package:flutter_framework/ioc/provider_locator.dart';
import 'package:flutter/material.dart';
import 'package:estd/type/null.dart';

class SpeakingSessionPage extends StatefulWidget {
  static const String name = 'speaking_session';

  // ignore: prefer_constructors_over_static_methods
  static SpeakingSessionPage builder(BuildContext ctx) =>
      const SpeakingSessionPage();

  const SpeakingSessionPage({Key key}) : super(key: key);

  @override
  _SpeakingSessionPageState createState() => _SpeakingSessionPageState();
}

class _SpeakingSessionPageState extends State<SpeakingSessionPage> {
  EntitiesBloc _bloc;
  EntitySpeaker _speaker;
  StreamSubscription<Object> _speakerLocaleUpdatingSubscription;

  @override
  void initState() {
    super.initState();
    var locator = ProviderServiceLocator(context);
    _bloc = EntitiesBlocFactory().create(locator);
    _speaker = EntitySpeakerFactory().create(locator);
    _speakerLocaleUpdatingSubscription = _bloc.state
        .map((state) => state.localeCode)
        .where(isNotNull)
        .distinct()
        .listen(_speaker.setLanguage);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    EntitiesState currentState = _bloc.currentState;
    String currentLocale = Localizations.localeOf(context).languageCode;
    if (currentState == null ||
        (currentState.isSuccessful &&
            currentState.localeCode != currentLocale)) {
      _bloc.refresh(currentLocale, _bloc.currentState?.category);
    }
  }

  @override
  void dispose() {
    super.dispose();
    _speakerLocaleUpdatingSubscription.cancel();
    _bloc.close();
    _speaker.close();
  }

  @override
  Widget build(BuildContext context) => _SpeakingSessionWidget(
        bloc: _bloc,
        speaker: _speaker,
        messages: ProviderServiceLocator(context).get<MessageRegistry>(),
      );
}

class _SpeakingSessionWidget extends StatelessWidget {
  final EntitiesBloc bloc;
  final EntitySpeaker speaker;
  final MessageRegistry messages;

  const _SpeakingSessionWidget({
    @required this.bloc,
    @required this.speaker,
    @required this.messages,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => StreamBuilder<EntitiesState>(
        stream: bloc.state,
        initialData: bloc.currentState,
        builder: (ctx, snapshot) => Scaffold(
          appBar: AppBar(
            title: Text(messages.entitiesNameSessionPageLabel()),
            actions: _buildAppBarActions(context, snapshot.data),
          ),
          body: _buildStateBasedTree(ctx, snapshot.data),
        ),
      );

  // region AppBar actions
  List<Widget> _buildAppBarActions(
    BuildContext context,
    EntitiesState state,
  ) =>
      <Widget>[
        if (state?.isSuccessful ?? false) _buildRefreshAction(state.localeCode),
        if (state?.isSuccessful ?? false)
          _buildSearchAction(context, state.localeCode),
      ];

  Widget _buildRefreshAction(String localeCode) => IconButton(
        onPressed: () => bloc.refresh(localeCode, bloc.currentState.category),
        icon: const Icon(Icons.refresh),
      );

  Widget _buildSearchAction(BuildContext context, String localeCode) =>
      IconButton(
        icon: const Icon(Icons.search),
        onPressed: () async {
          final category = await showSearch<Category>(
            context: context,
            delegate: TagsSearchDelegate(
              const CategoriesBlocFactory()
                  .create(ProviderServiceLocator(context)),
              messages,
            ),
          );
          bloc.refresh(localeCode, category);
        },
      );

  //endregion

  // region Page Content
  Widget _buildStateBasedTree(BuildContext context, EntitiesState state) {
    if (state == null || state.isRetrievingEntities) {
      return Center(child: _buildLoadingTree());
    } else if (state.hasError) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 8.0),
          child: _buildErrorTree(context, state.error),
        ),
      );
    } else if (state.isEmpty()) {
      return Center(child: _buildEmptyStateTree(context));
    } else {
      return _buildEntitiesTree(state.entities.map(EntityPM.of).toBuiltList());
    }
  }

  Widget _buildErrorTree(BuildContext context, Object error) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(messages.entitiesFetchError(error.toString())),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => bloc.refresh(
                Localizations.localeOf(context).languageCode,
                bloc.currentState.category),
          )
        ],
      );

  Widget _buildLoadingTree() => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const CircularProgressIndicator(),
          const SizedBox(height: 8),
          Text(messages.entitiesLoadingLabel()),
        ],
      );

  Widget _buildEmptyStateTree(BuildContext context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          Text(messages.entitiesEmptyStateLabel()),
          const SizedBox(height: 8),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => bloc.refresh(
                Localizations.localeOf(context).languageCode,
                bloc.currentState.category),
          )
        ],
      );

  Widget _buildEntitiesTree(BuiltList<EntityPM> entities) => PageView.builder(
        physics: const PageScrollPhysics(),
        // Dirty hack for the next image preload
        controller: PageController(viewportFraction: 0.99),
        itemCount: entities.length,
        itemBuilder: (ctx, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: EntityWidget(
            entity: entities[index],
            speaker: speaker,
          ),
        ),
      );
//endregion
}

class EntityWidget extends StatelessWidget {
  final EntityPM entity;
  final EntitySpeaker speaker;

  const EntityWidget({
    @required this.entity,
    @required this.speaker,
    Key key,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) => FittedBox(
        child: GestureDetector(
          onTap: () => speaker.speak(entity.title),
          child: Image.network(entity.imageUrl),
        ),
      );
}

class TagsSearchDelegate extends SearchDelegate<Category> {
  final CategoriesBloc _bloc;
  final MessageRegistry _registry;

  TagsSearchDelegate(this._bloc, this._registry);

  @override
  List<Widget> buildActions(BuildContext context) => <Widget>[
        IconButton(
          icon: const Icon(Icons.close),
          onPressed: () => super.query = '',
        )
      ];

  @override
  Widget buildLeading(BuildContext context) => IconButton(
        icon: const BackButtonIcon(),
        onPressed: () => super.close(context, null),
      );

  @override
  Widget buildSuggestions(BuildContext context) => buildResults(context);

  @override
  Widget buildResults(BuildContext context) {
    _updateQuery();
    return StreamBuilder<CategoriesState>(
      initialData: _bloc.currentState,
      stream: _bloc.state,
      builder: (ctx, snapshot) => _buildResultsFromState(ctx, snapshot.data),
    );
  }

  void _updateQuery() {
    if (query.isEmpty) {
      _bloc.onReset();
    } else {
      _bloc.onSearch(query);
    }
  }

  Widget _buildResultsFromState(BuildContext context, CategoriesState state) {
    if (state.isIdle) {
      return Center(child: _buildIdleWidget());
    } else if (state.isProcessing) {
      return Center(child: _buildLoadingWidget());
    } else if (state.hasError) {
      return Center(child: _buildErrorWidget(state.error));
    } else if (state.result.categories.isEmpty) {
      return Center(child: _buildEmptyState(context, state.result.query));
    } else {
      return _buildTags(context, state.result.categories);
    }
  }

  Widget _buildIdleWidget() => Text(_registry.entitiesSearchLabel());

  Widget _buildLoadingWidget() => const CircularProgressIndicator();

  Widget _buildErrorWidget(Object error) => Text(
        _registry
            .entitiesSearchError(error?.toString() ?? _registry.unknownError()),
      );

  Widget _buildEmptyState(BuildContext context, String query) =>
      Text(_registry.entitiesCategoriesSearchEmptyStateLabel(query));

  Widget _buildTags(BuildContext context, BuiltList<Category> categories) =>
      ListView.separated(
        itemCount: categories.length,
        itemBuilder: (context, index) => ListTile(
          title: Text(categories[index].title),
          onTap: () => close(context, categories[index]),
        ),
        separatorBuilder: (_, __) => const Divider(),
      );
}
