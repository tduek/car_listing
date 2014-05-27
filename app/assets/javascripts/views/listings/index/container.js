CarListing.Views.IndexContainer = Backbone.View.extend({
  template: JST['listings/index_container'],

  render: function () {
    this.$el.html(this.template({}));

    this.renderSidebar();


    this.renderSearchResults();

    return this;
  },

  renderSidebar: function () {
    var $sidebar = this.$el.find('#sidebar')
    var searchFormView = new CarListing.Views.SearchForm({});
    $sidebar.html(searchFormView.render().setDefaults().$el);
  },

  renderSearchResults: function () {
    var searchResultsView = new CarListing.Views.SearchResults({
      el: this.$el.find('#search-results')
    });
    searchResultsView.render();
  }

});