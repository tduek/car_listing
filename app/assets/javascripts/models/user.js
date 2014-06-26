CarListing.Models.User = Backbone.Model.extend({

  urlRoot: '/users',

  listings: function () {
    if (!this._ownedListings) {
      this._ownedListings = new CarListing.Subsets.OwnedListings([], {
        owner: this,
        parentCollection: CarListing.allListings
      });
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
  },

  name: function () {
    return this.get('fname') + ' ' + this.get('lname');
  }



});