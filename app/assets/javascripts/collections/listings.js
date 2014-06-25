CarListing.Collections.Listings = Backbone.Collection.extend({

  initialize: function (models, options) {
  },

  model: CarListing.Models.Listing,
  url: '/listings',

  getOrFetch: function (id) {
    var prefetchedListing = this.get(id);
    if (prefetchedListing) return prefetchedListing;

    var collection = this;
    var listing = new CarListing.Models.Listing({id: id});
    listing.collections = this;
    listing.fetch({
      success: function (model) {
        collection.add(model);
      }
    });

    return listing;
  },

  findByPicID: function (picID) {
    return this.find(function (listing) {
      if (listing.pics().get(picID)) return true;
    });
  }

});
