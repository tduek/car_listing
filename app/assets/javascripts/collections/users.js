CarListing.Collections.Users = Backbone.Collection.extend({

  url: '/users',

  model: CarListing.Models.User,

  getOrFetch: function (id, cb) {
    var collection = this, user = this.get(id);

    if (user) {
      if (cb) cb(user);
    }
    else {
      user = new this.model({id: id});
      user.fetch({
        success: function () {
          collection.add(user)
          if (cb) cb(user);
        }
      });
    }


    return user;
  }
});