CarListing.Views.UserDashboard = Backbone.View.extend({

  initialize: function () {
    this.user = CarListing.currentUser();
    this.listenTo(this.user, 'sync', this.render);

    this.subviews = [];
    this.user.listings().fetch({ silent: true });
    this.user.favoritedListings().fetch({ silent: true });
  },

  template: JST['users/dashboard'],

  render: function () {
    var skeleton = this.template({ user: this.user });
    this.$el.html(skeleton);
    this.renderOwnedListings();
    this.renderFavoritedListings();
    return this;
  },

  renderOwnedListings: function () {
    var $el = this.$('.owned-listings');
    this.renderListingsList($el, this.user.listings());
  },

  renderFavoritedListings: function () {
    var $el = this.$('.favorited-listings');
    this.renderListingsList($el, this.user.favoritedListings());
  },

  renderListingsList: function ($el, collection) {
    $el.empty();
    var view = new CarListing.Views.ListingsList({
      listings: collection,
      el: $el
    })

    this.subviews.push(view);
    view.render();
  },

  remove: function () {
    _( this.subviews ).each(function (subview) {
      subview.remove();
    });

    Backbone.View.prototype.remove.call(this);
  }

});