CarListing.Collections.Listings = Backbone.Collection.extend({

  model: CarListing.Models.Listing,
  url: '/listings',
  parse: function (json, options) {
    this.listingsCount = json.listings_count;
    this.totalPages = json.total_pages;
    this.currentPage = json.current_page;
    return json.listings;
  }

});
