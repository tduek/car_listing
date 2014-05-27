window.CarListing = {
  Models: {},
  Collections: {},
  Views: {},
  Routers: {},
  initialize: function() {
    var bootstrappedData = JSON.parse($('#bootstrapped-listings').html());

    var listingsJSON = bootstrappedData.listings;
    this.listings = new this.Collections.Listings(listingsJSON, {parse: true});

    var subdivisionsJSON = bootstrappedData.subdivisions;
    this.subdivisions = new this.Collections.Subdivisions(subdivisionsJSON, {parse: true});

    this.years = bootstrappedData.years.sort().reverse();

    if (!this.searchParams) {
      this.searchParams = window.searchParams;
    }

    var indexView = new this.Views.IndexContainer()
    $('main#content').html(indexView.render().$el);
  }
};

$(document).ready(function(){
  CarListing.initialize();
});

$(document).ready(function () {
  var requestingNextPage = false;

  $(window).scroll(function(event) {
    var listings = CarListing.listings;

    var distanceFromBottom = function () {
      var doc = $(document);
      return doc.height() - (window.innerHeight + doc.scrollTop())
    };

    if (distanceFromBottom() < 500) {
      console.log('currentPage: '+listings.currentPage+', totalPages: '+listings.totalPages+', requestingPage: '+requestingNextPage);
    }

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
