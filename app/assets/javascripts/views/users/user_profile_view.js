CarListing.Views.UserProfile = Backbone.View.extend({

  initialize: function (options) {
    this.subviews = [];
    this.user = options.user;

    this.listenTo(this.user, 'change sync', this.render);
  },

  template: JST['users/profile'],

  render: function () {
    var renderedContent = this.template({ user: this.user });

    this.$el.html(renderedContent);
    this.renderListings();
    return this;
  },

  events: {
    'click a.phone': 'openRecaptchaForm'
  },

  renderListings: function () {
    var $el = this.$('.listings');
    var listings = this.user.listings();
    var view = this;

    listings.fetch({
      success: function () {
        listingsView = new CarListing.Views.ListingsList({
          el: $el,
          listings: listings
        });

        view.subviews.push(listingsView);
        listingsView.render();
      }
    });

  },

  openRecaptchaForm: function () {
    var recaptchaView = new CarListing.Views.PhoneRecaptcha({
      model: this.user
    });
  },

  remove: function () {
    _( this.subviews ).each(function (subview) {
      subview.remove();
    });

    Backbone.View.prototype.remove.call(this);
  }



});