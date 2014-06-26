CarListing.Views.ListingsList = Backbone.View.extend({

  initialize: function (options) {
    this.subviews = [];
    this.listings = options.listings;

    this.listenTo(this.listings, 'remove sync', this.reactToCollectionChange);
    this.listenTo(this.listings, 'add', this.addListing);
  },

  reactToCollectionChange: function () {
    if (this.listings.isEmpty()) {
      this.$el.html('<span>Sorry, no listings here.</span>');
    }
    else {
      this.render();
    }
  },

  reactToAdd: function (model) {
    if (this.listings.length === 1) this.$el.empty();

    this.addListing(model);
  },

  render: function () {
    this.listings.each(this.addListing.bind(this));
  },

  addListing: function (listing) {
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