window.CarListing = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  initialize: function() {
    var listingsData = JSON.parse($('#bootstrapped-listings').html());
    window.listings = new this.Collections.Listings(listingsData);


    var listingsView = new this.Views.ListingsIndex({collection: window.listings})
    $('section.listings').html(listingsView.render().$el);
  }
};

$(document).ready(function(){
  CarListing.initialize();
});
