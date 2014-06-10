CarListing.Models.Listing = Backbone.Model.extend({

  price: function () {
    return accounting.formatMoney(this.get('price'));
  },

  toggleFavorite: function () {
    if (this.get('is_favorite')) {
      this.unfavorite();
    }
    else {
      this.favorite();
    }
  },

  favorite: function () {
    var favoriteURL = '/listings/' + this.id + '/favorite';
    var listing = this;
    $.ajax({
      method: 'post',
      url: favoriteURL,
      success: function () {
        listing.set('is_favorite', true);
      }
    });
  },

  unfavorite: function () {
    var unfavoriteURL = '/listings/' + this.id + '/unfavorite';
    var listing = this;
    $.ajax({
      method: 'delete',
      url: unfavoriteURL,
      success: function () {
        listing.set('is_favorite', false);
      }
    });
  }


});
