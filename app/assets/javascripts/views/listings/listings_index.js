CarListing.Views.ListingsIndex = Backbone.View.extend({

  template: JST['listings/index'],

  render: function () {
    var renderedContent = this.template({listings: this.collection});

    this.$el.html(renderedContent);

    return this;
  }
});
