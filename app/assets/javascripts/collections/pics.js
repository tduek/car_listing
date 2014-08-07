CarListing.Collections.Pics = Backbone.Collection.extend({
  model: CarListing.Models.Pic,

  url: '/pics',

  comparator: 'ord'
});