CarListing.Subsets.OwnedListings = Backbone.Subset.extend({

  url: function () {
    return '/api/users/' + this._owner.id + '/listings';
  },

  initialize: function (models, options) {
    this._owner = options.owner;
  }

})