CarListing.Models.User = Backbone.Model.extend({

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
    if (this.get('is_dealer')) {
      return this.escape('company_name');
    }
    else {
      var vals = [this.escape('fname'), this.escape('lname')];
      return _( vals ).compact().join(' ');
    }
  },

  contactURL: function () {
    return '/api/users/' + this.id + '/contact_info';
  }


});