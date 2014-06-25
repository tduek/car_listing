CarListing.Models.User = Backbone.Model.extend({

  urlRoot: '/users',

  listings: function () {
    if (!this._ownedListings) {
      this._ownedListings = new CarListing.Collections.Listings();
    }

    return this._ownedListings;
  },

  favoritedListings: function () {
    if (!this._favoritedListings) {
      this._favoritedListings = new CarListing.Subsets.FavoritedListings([], {
        parentCollection: CarListing.allListings
      });
    }

    return this._favoritedListings;
  }



});