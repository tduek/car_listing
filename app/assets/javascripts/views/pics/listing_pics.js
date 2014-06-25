CarListing.Views.PicsIndex = Backbone.View.extend({

  initialize: function (options) {
    this.listing = options.listing;
    this.selectedPicID = parseInt(options.selectedPicID);
    this.listenTo(this.listing.pics(), 'add', this.render);
    this.listenTo(this.listing, 'change', this.render);
  },

  events: {
    'click .thumb-container': 'changeFeaturedPic',
    'click .exit-lightbox': 'remove'
  },

  template: JST['pics/index'],

  render: function () {
    var renderedContent = this.template({
      listing: this.listing,
      selectedPicID: this.selectedPicID
    });

    this.$el.html(renderedContent);
    return this;
  },

  changeFeaturedPic: function (event) {
    var picIDstr = $(event.currentTarget).data('id');
    this.selectedPicID = parseInt(picIDstr);
    var selectedPic = this.listing.pics().get(this.selectedPicID);
    this.$('article > img.featured').attr('src', selectedPic.get('url'));
    this.centerFeaturedThumb()
  },

  centerFeaturedThumb: function () {
    var view = this;
    view.$('nav .thumb-container.featured').removeClass('featured');
    var id = view.selectedPicID;
    var $newSelected = view.$('.thumb-container[data-id="' + id + '"]');
    $newSelected.addClass('featured');

    var $thumbs = view.$('.thumbs');
    var containerOffset = parseInt($thumbs.css('margin-left'));
    var leftOfParent = $newSelected.position().left - containerOffset;


    var $nav = $thumbs.parent();
    var navCenter = parseInt($nav.css('width')) / 2;
    var selectedLeftMargin = navCenter - leftOfParent;

    $thumbs.animate({'margin-left': '' + selectedLeftMargin + 'px'})
  },

  remove: function () {
    this.$el.removeClass('is-active');
    Backbone.View.prototype.remove.call(this);
  },

  activate: function () {
    $('#lightbox').html(this.render().$el)
    this.$el.addClass('is-active');
    this.centerFeaturedThumb();
  }
});