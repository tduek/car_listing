CarListing.Models.Listing = Backbone.Model.extend({

  price: function () {
    return accounting.formatMoney(this.get('price'));
  }

});
