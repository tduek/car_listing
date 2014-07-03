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
    var listingsView = new CarListing.Views.ListingsList({
      el: this.$('.listings'),
      listings: this.user.listings()
    });
    this.subviews.push(listingsView);
    listingsView.render();

    this.user.listings().fetch();
  },

  openRecaptchaForm: function (event) {
    event.preventDefault();
    var $link = $(event.currentTarget);
    recaptchaView = new CarListing.Views.PhoneRecaptcha({
      model: this.user,
      $link: $link,
      $container: $link.parent()
    });
    recaptchaView.showRecaptcha();
  },

  remove: function () {
    _( this.subviews ).each(function (subview) {
      subview.remove();
    });

    Backbone.View.prototype.remove.call(this);
  }



});