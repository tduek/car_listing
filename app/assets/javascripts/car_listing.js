window.CarListing = {
  Models: {},
  Collections: {},
  Subsets: {},
  Views: {},
  Routers: {},
  initialize: function(options) {
    this.loadClippy();
    this.currentUserID = options.currentUserID;
    this.users = new this.Collections.Users();

    var bootstrappedData = JSON.parse($('#bootstrapped-listings').html());

    var listingsData = _.defaults(bootstrappedData.listingsData, options);
    this.allListings = new this.Collections.Listings(listingsData.listings, { parse: true });
    this.indexListings = new this.Subsets.ListingsIndex(listingsData, {
      parse: true,
      parentCollection: this.allListings
    });

    var subdivisionsJSON = bootstrappedData.subdivisions;
    this.subdivisions = new this.Collections.Subdivisions(subdivisionsJSON, {parse: true});

    this.years = bootstrappedData.years.sort().reverse();
    this.sortOptions = bootstrappedData.sortOptions;

    this.RECAPTCHA_PUBLIC_KEY = bootstrappedData.RECAPTCHA_PUBLIC_KEY;

    var router = new this.Routers.Listings();
    Backbone.history.start();
  },

  loadClippy: function () {
    var clippySuccess = function (agent) { CarListing.clippy = agent; };
    var clippyFail = function () { CarListing.clippy = false; };
    clippy.load('Clippy', clippySuccess, clippyFail);
  },

  userSignedIn: function () {
    console.log('called userSignedIn')
    return !!this.currentUserID;
  },

  currentUser: function () {
    if (this.currentUserID) {
      return this.users.getOrFetch(this.currentUserID);
    } else {
      return null;
    }
  },

  distanceFromBottom: function () {
    var doc = $(document);
    return doc.height() - (window.innerHeight + doc.scrollTop())
  },

  _swapView: function (view) {
    this._currentView && this._currentView.remove();
    this._currentView = view;
    $('main#content').html(view.render().$el);
  }

};