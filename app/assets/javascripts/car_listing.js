window.CarListing = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  initialize: function() {
    this.loadClippy();
    var bootstrappedData = JSON.parse($('#bootstrapped-listings').html());

    var listingsJSON = bootstrappedData.listings;
    this.listings = new this.Collections.Listings(listingsJSON, {parse: true});

    var subdivisionsJSON = bootstrappedData.subdivisions;
    this.subdivisions = new this.Collections.Subdivisions(subdivisionsJSON, {parse: true});

    this.years = bootstrappedData.years.sort().reverse();
    this.sortOptions = bootstrappedData.sortOptions;

    this.currentUser = bootstrappedData.current_user;

    var indexView = new this.Views.IndexContainer()
    $('main#content').html(indexView.render().$el);
  },

  loadClippy: function () {
    var clippySuccess = function (agent) { CarListing.clippy = agent; };
    var clippyFail = function () { CarListing.clippy = false; };
    clippy.load('Clippy', clippySuccess, clippyFail);
  },

  userSignedIn: function () {
    return !!this.currentUser;
  }

};

$(document).ready(function(){
  if ($('#bootstrapped-listings').html()) {
    CarListing.initialize();
  }
});

var distanceFromBottom = function () {
  var doc = $(document);
  return doc.height() - (window.innerHeight + doc.scrollTop())
};

$(document).ready(function () {
  var listings = CarListing.listings;
  var requestingNextPage = false;
  $(window).scroll(function(event) {
    if (!listings) return

    if (distanceFromBottom() < 500 && !requestingNextPage) {
      requestingNextPage = true;

      if (listings.currentPage < listings.totalPages) {
        listings.fetch({
          data: {
            search: CarListing.searchParams,
            page:   (listings.currentPage + 1)
          },
          beforeSend: function () {
            $("#end-of-page").show();
          },
          success: function () {
            $("#end-of-page").hide();
          },
          error: function (data) {
            console.log('hit listings fetch error', data);
          },
          complete: function () {
            requestingNextPage = false;
          }
        });

      }
      else {
        $("#end-of-list").show();
      }
    }
  })

});
