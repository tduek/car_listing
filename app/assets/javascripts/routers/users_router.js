CarListing.Routers.Users = Backbone.Router.extend({

  initialize: function () {

  },

  routes: {
    'users/:id': 'show',
    'user_dashboard': 'dashboard'
  },


  show: function (id) {

  },

  dashboard: function () {
    var view = new CarListing.Views.UserDashboard();

    CarListing._swapView(view);
  }

});