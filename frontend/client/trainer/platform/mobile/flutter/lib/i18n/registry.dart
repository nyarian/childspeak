abstract class MessageRegistry {
  //region Splash page

  String splashPageAuthenticationError(String message);

  String splashPageLoadingLabel();

  //endregion

  //region Entities page
  String entitiesNameSessionPageLabel();

  String entitiesFetchError(String description);

  String entitiesLoadingLabel();

  String entitiesEmptyStateLabel();
  //endregion

}
