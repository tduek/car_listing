CarListing.Collections.Users = Backbone.Collection.extend({

  url: '/users',

  model: CarListing.Models.User,

  getOrFetch: function (id, cb) {
    var collection = this, user = this.get(id);

    if (!user) {
      user = new this.model({id: id});
      collection.add(user);

      user.fetch({
        success: function () {
          if (cb) cb(user);
        }
      });
    }

    return user;
  }
});