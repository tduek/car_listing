CarListing.Subsets.FavoritedListings = Backbone.Subset.extend({

  url: 'api/listings/favorites',

  initialize: function () {
    var subset = this;
    subset.listenTo(subset, 'change:is_favorite', function (model) {
      console.log('favoritedListings listenTo change:is_favorite cb. model: ', model);
      subset.remove(model);
    });
  }

});