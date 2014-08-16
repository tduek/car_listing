window.CarListing = {
  Models: {},
  Collections: {},
  Subsets: {},
  Views: {},
  Routers: {},
  initialize: function(options) {
    this.loadClippy();
    this.currentUserID = options.currentUserID;
    this.users = new this.Collections.Users();

    var bootstrappedData = options.bootstrappedData;
    var listingsData = options.bootstrappedListings;

    // var listingsData = _.defaults(bootstrappedData.listingsData, options);
    this.allListings = new this.Collections.Listings(listingsData.listings, { parse: true });
    this.indexListings = new this.Subsets.ListingsIndex(listingsData, {
      parse: true,
      parentCollection: this.allListings,
      maxCountForBestDealSort: bootstrappedData.maxCountForBestDealSort
    });

    var subdivisionsJSON = bootstrappedData.subdivisions;
    this.subdivisions = new this.Collections.Subdivisions(subdivisionsJSON, { parse: true });

    this.years = bootstrappedData.years.sort().reverse();
    this.sortOptions = bootstrappedData.sortOptions;

    this.RECAPTCHA_PUBLIC_KEY = bootstrappedData.RECAPTCHA_PUBLIC_KEY;

    this.spinnerURL = bootstrappedData.spinnerURL;
    this.formAuthToken = options.formAuthToken;

    this.listingsRouter = new this.Routers.Listings();
    this.usersRouter = new this.Routers.Users();
    Backbone.history.start({ pushState: true });

    this.backbonifyLinks();
  },

  backbonifyLinks: function () {
    $('a.home').attr('href', '');
    $('a.dashboard').attr('href', 'dashboard');

    $(document).on('click', 'a', function(e) {
      var href = $(this).attr("href");
      var protocol = this.protocol + "//";

      if (
          href.slice(0, protocol.length) !== protocol
          && protocol !== 'javascript://'
          && href.substring(0, 1) !== '#'
        ) {

        e.preventDefault();
        Backbone.history.navigate(href, true);
      }
    });
  },

  loadClippy: function () {
    var clippySuccess = function (agent) { CarListing.clippy = agent; };
    var clippyFail = function () { CarListing.clippy = false; };
    clippy.load('Clippy', clippySuccess, clippyFail);
  },

  moveClippy: function ($subject, duration) {
    if (!duration) duration = 0;
    var subjectPos = $subject.offset();
    var clippyX = subjectPos.left;
    var clippyY = subjectPos.top;
    CarListing.clippy.moveTo(clippyX, clippyY, duration);
  },

  clippyTooltip: function ($tool, tipText, options) {
    options = _.extend({ hide: true, hold: false }, options)

    CarListing.clippy.stop();
    CarListing.moveClippy($tool);

    // $('body').addClass('no-scroll');
    CarListing.clippy.show();
    CarListing.clippy.speak(tipText, options.hold);

    if (options.hide) CarListing.clippy.hideWhenDone(function () {
      $('body').removeClass('no-scroll');
    });
  },

  userSignedIn: function () {
    console.log('called userSignedIn')
    return !!this.currentUserID;
  },

  currentUser: function () {
    if (this.currentUserID) {
      return this.users.getOrFetch(this.currentUserID);
    } else {
      return null;
    }
  },

  distanceFromBottom: function () {
    var doc = $(document);
    return doc.height() - (window.innerHeight + doc.scrollTop())
  },

  _swapView: function (view) {
    if (this._currentView) {
      this._currentView.remove();
      $('.flash').hide();
    }
    this._currentView = view;
    $('main#content').html(view.render().$el);
  }

};