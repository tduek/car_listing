CarListing.Collections.Listings = Backbone.Collection.extend({

  initialize: function (models, options) {
  },

  model: CarListing.Models.Listing,

  getOrFetch: function (id, cb) {
    var listing = this.get(id), collection = this;

    if (listing) {
      if (cb) cb(listing);
    }
    else {
      listing = new CarListing.Models.Listing({id: id});
      listing.collection = collection;
      listing.fetch({
        success: function () {
          collection.add(listing);
          collection.add(listing);
          if (cb) cb(listing);
        }
      });
      listing.collections = this;
    }

    return listing;
  },

  findByPicID: function (picID) {
    return this.find(function (listing) {
      if (listing.pics().get(picID)) return true;
    });
  }

});
