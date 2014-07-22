CarListing.Views.SearchForm = Backbone.View.extend({

  template: JST['listings/index/search_form'],

  initialize: function (options) {
    this.listings = CarListing.indexListings;
    this.listenTo(this.listings, 'sync', this.maybeToggleSortByDeal);
  },

  className: 'search',

  tagName: 'form',

  events: {
    'change #search-make_id': 'updateModelSelect',
    'submit': 'changeSearchParams',
    'change select': 'changeSearchParams',
    'change input': 'changeSearchParams',
    'click .contains-tooltip': 'maybeShowModelTooltip',
    'change .search-year': 'yearChanged'
  },

  render: function () {
    this.$el.attr('method', 'get');
    var renderedContent = this.template({
      searchParams: this.listings.searchParams
    });
    this.$el.html(renderedContent);
    return this;
  },

  setDefaults: function () {
    this.selectChanged(this.$('#search-year_from'));
    this.selectChanged(this.$('#search-year_to'));

    var $makeSelect = this.$('#search-make_id');
    this.selectChanged($makeSelect);

    this.updateModelSelect();
    if ($makeSelect.val()) {
      var $modelSelect = this.$('#search-model_id');
      $modelSelect.val(this.listings.searchParams.model_id);
      this.selectChanged($modelSelect);
    }

    this.selectChanged(this.$('#search-sort_by'));
    // this.maybeToggleSortByDistance();
    // this.maybeToggleSortByDeal();

    return this;
  },

  changeSearchParams: function (event) {
    event.preventDefault();
    var $target = $(event.currentTarget);
    if ($target.prop('tagName') === 'SELECT') {
      this.selectChanged($target);
    }

    var newSearchParams = this.cleanupSearchParams(this.$el.serializeJSON());

    if (!_.isEqual(this.listings.searchParams, newSearchParams)) {
      this.listings.searchParams = newSearchParams;
      this.refreshListings();
    }
  },

  cleanupSearchParams: function (params) {
    params = _.clone(params)
    for (var k in params) {
      if (k === 'zip' && params['zip'].length != 5) {
        if (params.distance) this.showDistanceTooltip();
        if (params.zip) this.showZipTooltip();
        delete params.zip;
      }
      if (!params[k]) delete params[k];
    }

    return params;
  },

  refreshListings: function () {
    this.currentRequest && this.currentRequest.abort();

    this.listings.reset();
    this.currentRequest = this.listings.fetch({
      data: {search: CarListing.indexListings.searchParams},
      reset: true
    });
  },

  selectChanged: function ($select) {
    if ($select.val()) {
      if ($select.is('#search-sort_by')) {
        this.tryToSortBy($select);
      } else {
        $select.addClass('selected user-written');
      }
    }
    else {
      $select.removeClass('selected user-written');
    }
  },

  yearChanged: function (event) {
    var $yearSelect = $(event.currentTarget);
    var selectedFromYear = $yearSelect.is('#search-year_from'); // boolean
    var mapper = (selectedFromYear ? 1 : -1)
    var selectedYear = parseInt($yearSelect.val());
    var otherYearSelectOptions = $yearSelect.siblings('select').find('option');

    otherYearSelectOptions.each(function (i, option) {
      var $option = $(option);
      var optionsYear = parseInt($option.val());
      if ((selectedYear - optionsYear) * mapper > 0) {
        $option.prop('disabled', true);
      }
      else {
        $option.prop('disabled', false);
      }
    });
  },

  updateModelSelect: function () {
    var makeID = this.$('#search-make_id').val();
    var $modelSelect = this.$('#search-model_id');
    $modelSelect.html('<option value="">Model</option>')
    $modelSelect.val('');
    if (makeID) {
      var models = CarListing.subdivisions.get(makeID).children();
      if (!models.get(this.listings.searchParams.model_id)) {
        this.listings.searchParams.model_id = '';
      }

      models.each(function (model) {
        $modelSelect.append('<option value="'+model.id+'">'+model.get('name')+'</option>')
      });
      $modelSelect.prop('disabled', false).siblings('.mask').hide();
      this.selectChanged($modelSelect);
    }
    else {
      this.selectChanged($modelSelect);
      $modelSelect.prop('disabled', true).siblings('.mask').show();
    }
  },

  tryToSortBy: function ($sortSelect) {
    var sortVal = $sortSelect.val();
    if (sortVal === 'best_deal' && !this.listings.canSortByBestDeal()) {
      // can't sort by best deal
      $sortSelect.val('');
      this.selectChanged($sortSelect);
      this.showSortDealTooltip();
    }
    else if (sortVal === 'distance' && !this.$('#search-zip').val()) {
      $sortSelect.val('');
      this.selectChanged($sortSelect);
      this.showSortDistanceTooltip();
    }
  },

  maybeShowModelTooltip: function (event) {
    var $td = $(event.currentTarget);
    var $select = $td.find('select');
    if ($select.prop('disabled')) this.showModelTooltip();
  },

  showModelTooltip: function () {
    if (CarListing.clippy) {
      var $modelSelect = this.$('#search-model_id');
      var tipText = 'Select make first';
      CarListing.clippyTooltip($modelSelect, tipText, { hide: false });
      this.clippyPointToMakeSelect();
    }
    else {
      var $td = $(event.currentTarget).parents('td');
      var $tooltip = $td.find('.tooltip');
      $tooltip.stop().fadeIn(400, function () {
        $tooltip.stop().fadeOut(1200);
      });
    }
  },

  clippyPointToMakeSelect: function () {
    var makeSelectPos = this.$('#search-make_id').offset();
    var clippyX = makeSelectPos.left + 30;
    var clippyY = makeSelectPos.top - 30;
    CarListing.clippy.moveTo(clippyX, clippyY, 200);

    CarListing.clippy.play('GestureRight', 4000, function () {
      $('body').removeClass('no-scroll');
      CarListing.clippy.hide();
    });
  },

  showZipTooltip: function () {
    throw 'tantrum';
  },

  showSortDistanceTooltip: function () {
    var $sortSelect = this.$('#search-sort_by');
    var text = 'Specify a zipcode first to sort by distance';

    CarListing.clippyTooltip($sortSelect, text, { hide: false });
    this.clippyPointToZip();
  },

  clippyPointToZip: function () {
    var zipPos = this.$('#search-zip').offset();
    var clippyX = zipPos.left - 110;
    var clippyY = zipPos.top - 30;
    CarListing.clippy.moveTo(clippyX, clippyY, 200);

    CarListing.clippy.play('GestureLeft', 4000, function () {
      $('body').removeClass('no-scroll');
      CarListing.clippy.hide();
    });
  },

  showSortDealTooltip: function () {
    var $sortSelect = this.$('#search-sort_by');
    var text = 'I can only sort by best deal if there are less than 100 listings. There are ' + this.listings.formattedTotalCount() + ' now. Try narrowing it down by selecting a specific year, make, or distance.'

    CarListing.clippyTooltip($sortSelect, text, { hold: true })
  }

});