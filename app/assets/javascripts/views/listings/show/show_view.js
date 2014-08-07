CarListing.Views.ListingShow = Backbone.View.extend({

  initialize: function (options) {
    this.subviews = [];
    this.listing = options.listing;
    this.listenTo(this.listing, 'change sync', this.render);
  },

  template: JST['listings/show/container'],

  render: function () {
    var renderedContent;

    if (this.listing.isLoaded()) {
      renderedContent = this.template({listing: this.listing});
    } else {
      renderedContent = '<img src="' + CarListing.spinnerURL + '" class="spinner">';
    }

    this.$el.html(renderedContent);

    return this;
  },

  events: {
    'click a.phone': 'openRecaptchaForm',
    'click .car-pic': 'openLightbox'
  },

  openRecaptchaForm: function (event) {
    event.preventDefault();

    var $link = $(event.currentTarget)
    var recaptchaView = new CarListing.Views.PhoneRecaptcha({
      model: this.listing.seller(),
      $link: $link,
      $container: $link.parent()
    });
    this.subviews.push(recaptchaView);
    recaptchaView.showRecaptcha();
  },

  openLightbox: function (event) {
    var picID = $(event.currentTarget).data('id');

    var lightboxView = new CarListing.Views.PicsIndex({
      listing: this.listing,
      selectedPicID: picID
    });

    lightboxView.activate();
  },

  remove: function () {
    _( this.subviews ).each(function (subview) {
      subview.remove();
    });

    Backbone.View.prototype.remove.call(this);
  }

});