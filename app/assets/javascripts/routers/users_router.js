CarListing.Routers.Users = Backbone.Router.extend({

  initialize: function () {

  },

  routes: {
    'users/:id': 'show',
    'user_dashboard': 'dashboard'
  },


  show: function (id) {
    CarListing.users.getOrFetch(id, function (user) {
      var view = new CarListing.Views.UserProfile({ user: user });
      CarListing._swapView(view);
    });
  },

  dashboard: function () {
    var view = new CarListing.Views.UserDashboard();

    CarListing._swapView(view);
  }

});