CarListing.Views.SearchForm = Backbone.View.extend({

  template: JST['listings/index/search_form'],

  initialize: function (options) {
    this.listings = CarListing.indexListings;
  },

  className: 'search',

  tagName: 'form',

  events: {
    'change #search-make_id': 'updateModelSelect',
    'submit': 'changeSearchParams',
    'change select': 'changeSearchParams',
    'change input': 'changeSearchParams',
    // 'keyup input': 'changeSearchParams',
    'click .contains-tooltip': 'maybeShowTooltip',
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

    if ($makeSelect.val()) {
      this.updateModelSelect();
      var $modelSelect = this.$('#search-model_id');
      $modelSelect.val(this.listings.searchParams.model_id);
      this.selectChanged($modelSelect);
    }

    this.selectChanged(this.$('#search-sort_by'));
    this.maybeToggleSortByDistance();

    return this;
  },

  maybeToggleSortByDistance: function () {
    var distanceOption = this.$el.find('option[value="distance"]');
    distanceOption.prop('disabled', !(this.$el.find('#search-zip').val().length === 5));
  },

  changeSearchParams: function (event) {
    event.preventDefault();
    var $target = $(event.currentTarget);
    if ($target.prop('tagName') === 'SELECT') {
      this.selectChanged($target);
    }
    else {
      this.maybeToggleSortByDistance()
    }
    var newSearchParams = this.$el.serializeJSON();

    if ($target.is('#search-zip') && newSearchParams.zip.length != 5) {
      newSearchParams.zip = '';
      return
    }
    this.listings.searchParams = newSearchParams;
    this.refreshListings();
  },

  refreshListings: function () {
    this.listings.reset();
    this.listings.fetch({
      data: {search: CarListing.indexListings.searchParams},
      reset: true
    });
  },

  selectChanged: function ($select) {
    if ($select.val()) {
      $select.addClass('selected user-written');
    }
    else {
      $select.removeClass('selected user-written');
    }
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
      $modelSelect.prop('disabled', true).siblings('.mask').show();
    }
  },

  maybeShowTooltip: function (event) {
    var $td = $(event.currentTarget);
    var $select = $td.find('select');
    if ($select.prop('disabled')) {
      if (CarListing.clippy) {
        var makeSelectPos = $('#search-make_id').offset();
        var clippyX = makeSelectPos.left - $(window).scrollLeft() + 30;
        var clippyY = makeSelectPos.top - $(window).scrollTop() - 30;
        CarListing.clippy.moveTo(clippyX, clippyY);
        $('body').addClass('no-scroll');
        CarListing.clippy.show();
        CarListing.clippy.speak('Select make first');
        CarListing.clippy.play('GestureRight', 4000, function () {
          CarListing.clippy.hide();
          $('body').removeClass('no-scroll');
        });
      }
      else {
        var $tooltip = $td.find('.tooltip');
        $tooltip.stop().fadeIn(400, function () {
          $tooltip.stop().fadeOut(1200);
        });
      }
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
  }





});