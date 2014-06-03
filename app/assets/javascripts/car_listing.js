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

    this.searchParams = this.searchParams || window.searchParams;
    this.sortOptions = bootstrappedData.sortOptions;


    var indexView = new this.Views.IndexContainer()
    $('main#content').html(indexView.render().$el);
  },

  loadClippy: function () {
    var clippySuccess = function (agent) { CarListing.clippy = agent; };
    clippy.load('Clippy', clippySuccess, function () {
      CarListing.clippy = false;
    });
  },

  windowPos: {left: $(window).scrollLeft(), top: $(window).scrollTop()},

  updateWindowPos: function (newLeft, newTop) {
    this.windowPos.left = newLeft;
    this.windowPos.top = newTop;
  },

  deltaWindowPos: function () {
    var newLeft = $(window).scrollLeft();
    var newTop = $(window).scrollTop();
    var dx = this.windowPos.left - newLeft;
    var dy = this.windowPos.top - newTop;
    var result = {dx: dx, dy: dy}
    this.updateWindowPos(newLeft, newTop);
    return result;
  }
};

$(document).ready(function(){
  if ($('#bootstrapped-listings').html()) {
    CarListing.initialize();
  }
});

$(document).ready(function () {
  var requestingNextPage = false;
  $(window).scroll(function(event) {
    return
    // var $clippy = $('.clippy');
    // var deltaWindowPos = CarListing.deltaWindowPos();
    // var currentClippyX = $clippy.css('left');
    // var currentClippyY = $clippy.css('top');
    // if (currentClippyX && currentClippyY) {
    //   var newClippyX = currentClippyX + deltaWindowPos.dx;
    //   var newClippyY = currentClippyY + deltaWindowPos.dy;
    //   $clippy.css('top', ''+newClippyY);
    //   $clippy.css('left', ''+newClippyX);
    // }
    // console.log(parseInt(currentClippyX), parseInt(currentClippyY));
    // $('.clippy, .clippy-balloon')

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
