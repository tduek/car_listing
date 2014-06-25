CarListing.Routers.Listings = Backbone.Router.extend({

  initialize: function (options) {

  },

  routes: {
    '': 'index',
    'listings/:id': 'show'
  },

  index: function () {
    var indexView = new CarListing.Views.IndexContainer()
    CarListing._swapView(indexView);
  },

  show: function (id) {
    var listing = CarListing.allListings.getOrFetch(id);

    var showView = new CarListing.Views.ListingShow({
      listing: listing,
    });

    CarListing._swapView(showView);
  }

});
