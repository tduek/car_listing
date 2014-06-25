CarListing.Views.UserDashboard = Backbone.View.extend({

  initialize: function () {
    this.user = CarListing.currentUser();
    this.listenTo(this.user, 'change sync', this.render);
    this.listenTo(this.user.listings(), 'remove', this.renderOwnedListings);
    this.listenTo(this.user.favoritedListings(), 'remove', this.renderFavoritedListings);
  },

  template: JST['users/dashboard'],

  render: function () {
    var skeleton = this.template({user: this.user});

    this.renderOwnedListings();

    return this;
  },

  renderOwnedListings: function () {
    var $el = this.$('.owned-listings');
    $el.empty();
    this.renderListings($el, this.user.listings());
  },

  renderFavoritedListings: function () {
    var $el = this.$('.favorited-listings');
    $el.empty();
    this.renderListings($el, this.user.favoritedListings());
  },

  renderListings: function ($el, collection) {
    collection.each(this.addListing.bind(this, $el));
  },

  addListing: function ($el, listing) {
    var listItemView = new CarListing.Views.ListItem({ listing: listing });

    $el.append(listItemView.render().$el);
  }

});