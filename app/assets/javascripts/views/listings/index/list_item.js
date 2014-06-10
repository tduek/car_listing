CarListing.Views.ListItem = Backbone.View.extend({

  initialize: function (options) {
    this.listenTo(this.model, 'change', this.render);
  },

  template: JST['listings/list_item'],

  tagName: 'article',

  className: 'search-result-listing clear-fix',

  render: function () {
    var renderedContent = this.template({listing: this.model});
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
      this.model.toggleFavorite($btnContainer);
    }
    else {
      window.location.href = "/listings/new";
    }

  },



});
