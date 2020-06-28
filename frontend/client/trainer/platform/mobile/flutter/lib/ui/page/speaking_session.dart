import 'package:built_collection/built_collection.dart';
import 'package:childspeak/assembly/framework/speaker.dart';
import 'package:childspeak/i18n/registry.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_framework/domain/entity/speaker.dart';
import 'package:presentation/entity.dart';
import 'package:bloc/entity/entity.dart';
import 'package:childspeak/assembly/bloc/entities.dart';
import 'package:estd/type/lateinit.dart';
import 'package:flutter_framework/ioc/provider_locator.dart';
import 'package:flutter/material.dart';

class SpeakingSessionPage extends StatefulWidget {
  const SpeakingSessionPage({Key key}) : super(key: key);

  @override
  _SpeakingSessionPageState createState() => _SpeakingSessionPageState();
}

class _SpeakingSessionPageState extends State<SpeakingSessionPage> {
  final ImmutableLateinit<EntitiesBloc> _blocRef =
      ImmutableLateinit<EntitiesBloc>.unset();
  final ImmutableLateinit<EntitySpeaker> _speakerRef =
      ImmutableLateinit<EntitySpeaker>.unset();

  @override
  void initState() {
    super.initState();
    var locator = ProviderServiceLocator(context);
    _blocRef.value = EntitiesBlocFactory().create(locator)..refresh();
    _speakerRef.value = EntitySpeakerFactory().create(locator);
  }

  @override
  void dispose() {
    super.dispose();
    _blocRef.value.close();
    _speakerRef.value.close();
  }

  @override
  Widget build(BuildContext context) => _SpeakingSessionWidget(
        bloc: _blocRef.value,
        speaker: _speakerRef.value,
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
  Widget build(BuildContext context) => Scaffold(
        appBar: AppBar(
          title: Text(messages.entitiesNameSessionPageLabel()),
        ),
        body: StreamBuilder<EntitiesState>(
          stream: bloc.state,
          initialData: bloc.currentState,
          builder: (ctx, snapshot) => _buildStateBasedTree(ctx, snapshot.data),
        ),
      );

  Widget _buildStateBasedTree(BuildContext context, EntitiesState state) {
    if (state == null || state.isRetrievingEntities) {
      return Center(child: _buildLoadingTree());
    } else if (state.hasError) {
      return Center(child: _buildErrorTree(state.error));
    } else if (state.isEmpty()) {
      return Center(child: _buildEmptyStateTree());
    } else {
      return _buildEntitiesTree(state.entities.map(EntityPM.of).toBuiltList());
    }
  }

  Widget _buildErrorTree(Object error) => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(messages.entitiesFetchError(error.toString())),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: bloc.refresh,
          )
        ],
      );

  Widget _buildLoadingTree() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          const CircularProgressIndicator(),
          Text(messages.entitiesLoadingLabel()),
        ],
      );

  Widget _buildEmptyStateTree() => Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Text(messages.entitiesEmptyStateLabel()),
          IconButton(
            icon: Icon(Icons.refresh),
            onPressed: bloc.refresh,
          )
        ],
      );

  Widget _buildEntitiesTree(BuiltList<EntityPM> entities) => PageView.builder(
        physics: const PageScrollPhysics(),
        itemCount: entities.length,
        scrollDirection: Axis.horizontal,
        itemBuilder: (ctx, index) => Padding(
          padding: const EdgeInsets.all(8.0),
          child: EntityWidget(
            entity: entities[index],
            speaker: speaker,
          ),
        ),
      );
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
