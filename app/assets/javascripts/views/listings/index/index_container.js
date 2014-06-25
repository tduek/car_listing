CarListing.Views.IndexContainer = Backbone.View.extend({

  initialize: function (options) {
    var view = this;
    this.installInfiniteScroll();
  },

  installInfiniteScroll: function () {
    var listings = CarListing.indexListings;
    var view = this;
    $(window).on('scroll', function (event) {
      if (CarListing.distanceFromBottom() < 500 && !listings.requestingNextPage) {
        if (listings.currentPage < listings.totalPages) {

          var $endOfPage = view.$el.find("#end-of-page");
          listings.fetchNextPage($endOfPage);
        }
        else {
          view.$el.find("#end-of-list").show();
        }
      }
    });
  },

  remove: function () {
    $(window).off('scroll');
    Backbone.View.prototype.remove.call(this);
  },

  template: JST['listings/index/index_container'],

  render: function () {
    this.$el.html(this.template({}));

    this.renderSidebar();

    this.renderSearchResults();

    return this;
  },

  renderSidebar: function () {
    var $sidebar = this.$('#sidebar')
    var searchFormView = new CarListing.Views.SearchForm({});
    $sidebar.html(searchFormView.render().setDefaults().$el);
  },

  renderSearchResults: function () {
    var searchResultsView = new CarListing.Views.SearchResults({
      el: this.$('#search-results')
    });
    searchResultsView.render();
  }

});