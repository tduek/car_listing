CarListing.Views.PicsIndex = Backbone.View.extend({

  initialize: function (options) {
    this.listing = options.listing;
    this.selectedPicID = parseInt(options.selectedPicID);
    this.listenTo(this.listing.pics(), 'add', this.render);
    this.listenTo(this.listing, 'change', this.render);
    this.bindKeyEvents();
  },

  events: {
    'click .thumb-container': 'changeFeaturedPic',
    'click .exit-lightbox': 'remove'
  },

  bindKeyEvents: function () {
    var view = this;
    $(document).on('keydown', function (event) {
      view.handleKeyPress(event);
    });
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

  handleKeyPress: function (event) {
    if (event.keyCode === 27) {
      // pressed Esc
      this.remove();
    } else if (event.keyCode === 39) {
      // pressed right arrow
      this.showNextPic();
    } else if (event.keyCode === 37) {
      // pressed left arrow
      this.showPrevPic();
    }
  },

  showNextPic: function () {
    var pics = this.listing.pics();
    var currentlyShowedPic = pics.get(this.selectedPicID);
    var indexOfCurrentPic = pics.indexOf(currentlyShowedPic);
    if (indexOfCurrentPic < pics.length - 1) {
      var nextPic = pics.at(indexOfCurrentPic + 1);
      this.changeFeaturedPic(nextPic);
    }
  },

  showPrevPic: function () {
    var pics = this.listing.pics();
    var currentlyShowedPic = pics.get(this.selectedPicID);
    var indexOfCurrentPic = pics.indexOf(currentlyShowedPic);
    if (indexOfCurrentPic > 0) {
      var prevPic = pics.at(indexOfCurrentPic - 1);
      this.changeFeaturedPic(prevPic);
    }
  },

  clickPic: function (event) {
    var picIDstr = $(event.currentTarget).data('id');
    var selectedPicID = parseInt(picIDstr);
    var selectedPic = this.listing.pics().get(selectedPicID);
    this.changeFeaturedPic(selectedPic);
  },

  changeFeaturedPic: function (pic) {
    this.selectedPicID = pic.id;
    this.$('article > img.featured').attr('src', pic.get('url'));
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
    var selectedLeftCorner = navCenter - leftOfParent;
    var selectedLeftMargin = selectedLeftCorner - 29;

    $thumbs.animate({'margin-left': '' + selectedLeftMargin + 'px'})
  },

  remove: function () {
    $(document).off('keydown');
    this.$el.removeClass('is-active');
    Backbone.View.prototype.remove.call(this);
  },

  activate: function () {
    $('#lightbox').html(this.render().$el)
    this.$el.addClass('is-active');
    this.centerFeaturedThumb();
  }
});