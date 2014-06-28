CarListing.Views.ListingShow = Backbone.View.extend({

  initialize: function (options) {
    this.listing = options.listing;
    this.listenTo(this.listing, 'change sync', this.render);
  },

  template: JST['listings/show/container'],

  render: function () {
    var renderedContent = this.template({listing: this.listing});
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
    var $span = $link.parent();

    var recaptchaView = new CarListing.Views.PhoneRecaptcha({
      model: this.listing
    });

    var view = this;
    $span.after(recaptchaView.render().$el);
    recaptchaView.showRecaptcha();
    $link.remove();
  },

  openLightbox: function (event) {
    var picID = $(event.currentTarget).data('id');

    var lightboxView = new CarListing.Views.PicsIndex({
      listing: this.listing,
      selectedPicID: picID
    });

    lightboxView.activate();
  }

});