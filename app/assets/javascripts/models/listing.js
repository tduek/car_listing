CarListing.Models.Listing = Backbone.Model.extend({

  urlRoot: 'api/listings',

  initialize: function () {
    this.collections = [];
  },

  parse: function (json) {
    if (json.pics) {
      this.pics().set(json.pics);
      delete json.pics
    }

    if (json.mainPic) {
      this.mainPic().set(json.main_pic);
      delete json.main_pic;
    }

    if (json.seller) {
      this.seller().set(json.seller);
      delete json.seller
    }

    return json;
  },

  price: function () {
    return accounting.formatMoney(this.get('price'));
  },

  miles: function () {
    var miles = this.escape('miles');
    if (miles) {
      return accounting.formatNumber(miles);
    }
    else {
      return 'N/A';
    }
  },

  mainPicURL: function () {
    return this.pics().first().get('url');
  },

  mainPic: function () {
    if (!this._mainPic) {
      this._mainPic = new CarListing.Models.Pic();
    }

    return this._mainPic;
  },

  pics: function () {
    if (!this._pics) {
      this._pics = new CarListing.Collections.Pics();
    }

    return this._pics;
  },

  seller: function () {
    if (!this._seller) {
      this._seller = new CarListing.Models.User();
      CarListing.users.add(this._seller, {merge: true});
    }

    return this._seller;
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
    var listing = this;
    $.ajax({
      type: 'post',
      url: '/api/listings/' + this.id + '/favorite',
      success: function () {
        listing.set('is_favorite', true);
        CarListing.currentUser().favoritedListings().add(listing);
      }
    });
  },

  unfavorite: function () {
    var listing = this;
    $.ajax({
      type: 'delete',
      url: '/api/listings/' + this.id + '/unfavorite',
      success: function () {
        listing.set('is_favorite', false);
      }
    });
  },

  truncatedTitle: function (length) {
    var title = this.escape('title');
    length = (length || 80)
    if (title.length > length) {
      return title.substring(0, length) + '...';
    }
    else {
      return title;
    }
  }


});
