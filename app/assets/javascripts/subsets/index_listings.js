CarListing.Subsets.ListingsIndex = Backbone.Subset.extend({

  url: '/api/listings',

  initialize: function (models, options) {

  },

  parse: function (json) {
    if (json.listingsCount) this.listingsCount = parseInt(json.listingsCount);
    if (json.totalPages) this.totalPages = parseInt(json.totalPages);
    if (json.currentPage) this.currentPage = parseInt(json.currentPage);
    if (json.searchParams) this.searchParams = json.searchParams;
    if (json.maxCountForBestDealSort) this.maxCountForBestDealSort = parseInt(json.maxCountForBestDealSort);

    return json.listings;
  },

  canSortByBestDeal: function () {
    return this.listingsCount <= this.maxCountForBestDealSort
  },

  fetchNextPage: function ($endOfPage) {
    if (this.requestingNextPage) return;

    this.requestingNextPage = true;
    $endOfPage.show();

    var listings = this;
    var fetchOptions = {
      remove: false,
      data: {
        search: listings.searchParams,
        page:   listings.currentPage + 1
      },
      success: function () {
        $endOfPage.hide();
      },
      error: function (data) {
        console.log('hit listings fetch error', data);
      },
      complete: function () {
        listings.requestingNextPage = false;
      }
    };

    listings.fetch(fetchOptions);
  },

  formattedTotalCount: function () {
    return accounting.formatNumber(this.listingsCount);
  }
});