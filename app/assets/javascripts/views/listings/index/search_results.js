CarListing.Views.SearchResults = Backbone.View.extend({

  initialize: function (options) {
    this.listenTo(CarListing.listings, 'reset', this.render)
    this.listenTo(CarListing.listings, 'add', this.addListing);
  },

  template: JST['listings/search_results'],

  render: function () {
    var view = this;
    view.$el.html(view.template({}));

    view.$listingsContainer = $(view.$el.find('.listings'));
    CarListing.listings.each(function(listing) {
      view.addListing(listing);
    });

    return view;
  },

  addListing: function (listing) {
    var listItemView = new CarListing.Views.ListItem({model: listing});
    var $renderedContent = listItemView.render().$el;

    this.$listingsContainer.append($renderedContent);
  }

});