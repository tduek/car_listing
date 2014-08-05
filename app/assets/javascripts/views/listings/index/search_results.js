CarListing.Views.SearchResults = Backbone.View.extend({

  initialize: function (options) {
    this.subviews = [];
    this.listenTo(CarListing.indexListings, 'reset', this.render)
    this.listenTo(CarListing.indexListings, 'add', this.addListing);
  },

  template: JST['listings/index/search_results'],

  render: function () {
    this.$el.html(this.template({}));

    this.renderListingsList();

    return this;
  },

  renderListingsList: function () {
    var $el = this.$('.listings');

    $el.empty();
    var view = new CarListing.Views.ListingsList({
      listings: CarListing.indexListings,
      el: $el
    });

    this.subviews.push(view);
    view.render();
  },

  remove: function () {
    _( this.subviews ).each(function (subview) { subview.remove() });

    Backbone.View.prototype.remove.call(this);
  }

});