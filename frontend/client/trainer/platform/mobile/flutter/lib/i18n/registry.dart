abstract class MessageRegistry {

  //region Common messages
  String unknownError();

  //endregion

  //region Splash page

  String splashPageAuthenticationError(String message);

  String splashPageLoadingLabel();

  //endregion

  //region Entities page
  String entitiesNameSessionPageLabel();

  String entitiesFetchError(String description);

  String entitiesLoadingLabel();

  String entitiesEmptyStateLabel();

  String entitiesSearchLabel();

  String entitiesCategoriesSearchEmptyStateLabel(String query);

  String entitiesSearchError(String description);
  //endregion

}
