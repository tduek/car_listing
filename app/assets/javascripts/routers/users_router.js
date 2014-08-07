CarListing.Routers.Users = Backbone.Router.extend({

  initialize: function () {

  },

  routes: {
    'sellers/:id': 'show',
    'dashboard': 'dashboard'
  },


  show: function (id) {
    CarListing.users.getOrFetch(id, function (user) {
      var view = new CarListing.Views.UserProfile({ user: user });
      CarListing._swapView(view);
    });
  },

  dashboard: function () {
    if (CarListing.userSignedIn()) {
      var view = new CarListing.Views.UserDashboard();

      CarListing._swapView(view);
    }
    else {
      window.location.href = "/listings/new";
    }
  }

});