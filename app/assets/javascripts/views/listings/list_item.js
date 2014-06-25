CarListing.Views.ListItem = Backbone.View.extend({

  initialize: function (options) {
    this.listing = options.listing;
    this.listenTo(this.listing, 'change', this.render);
  },

  template: JST['listings/list_item'],

  tagName: 'article',

  className: 'listing clear-fix',

  render: function () {
    var renderedContent = this.template({listing: this.listing});
    this.$el.html(renderedContent);
    this.$el.find('time.timeago').timeago();

    return this;
  },

  events: {
    'click .favoriting > .buttons': 'toggleFavorite'
  },

  toggleFavorite: function (event) {
    if (CarListing.userSignedIn()) {
      var $btnContainer = $(event.currentTarget).parents('.favoriting');
      $btnContainer.addClass('busy');
      this.listing.toggleFavorite();
    }
    else {
      window.location.href = "/listings/new";
    }

  },



});
