CarListing.Views.ListingsList = Backbone.View.extend({

  initialize: function (options) {
    this.showSpinner();
    this.subviews = [];
    this.listings = options.listings;
    this.listenTo(this.listings, 'remove sync', this.reactToCollectionChange);
    this.listenTo(this.listings, 'add', this.addListing);
    this.listenTo(this.listings, 'request', this.reactToFetch)
  },

  reactToFetch: function (collection, xhr, options) {
    if (options.reset) this.showSpinner();
  },

  showSpinner: function () {
    this.$el.html('<img src="' + CarListing.spinnerURL + '" class="spinner">');
  },

  showEmptyMsg: function () {
    this.$el.html('<span class="empty-msg">Sorry, no listings here.</span>');
  },

  reactToCollectionChange: function () {
    if (this.listings.isEmpty()) {
      this.showEmptyMsg();
    }
    else {
      this.render();
    }
  },

  reactToAdd: function (model) {
    this.addListing(model);
  },

  render: function () {
    this.renderedListings = [];
    this.listings.each(this.addListing.bind(this));
  },

  addListing: function (listing) {
    if (this.renderedListings.length === 0) this.$el.empty();

    if ( _(this.renderedListings).contains(listing) ) return;
    this.renderedListings.push(listing);

    var listItemView = new CarListing.Views.ListItem({ listing: listing });
    this.subviews.push(listItemView);
    this.$el.append(listItemView.render().$el);

  },

  remove: function () {
    _( this.subviews ).each(function (subview) {
      subview.remove();
    });

    Backbone.View.prototype.remove.call(this);
  }
});