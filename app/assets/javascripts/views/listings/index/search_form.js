CarListing.Views.SearchForm = Backbone.View.extend({

  template: JST['listings/search_form'],

  initialize: function () {
  },

  className: 'search',

  tagName: 'form',

  events: {
    'submit': 'changedSearchParams',
    'change select': 'changeSearchParams',
    'change input': 'changeSearchParams',
    'change #search-make_id': 'updateModelSelect',
    // 'keyup input': 'changeSearchParams',
    'click .contains-tooltip': 'maybeShowTooltip'
  },

  render: function () {
    this.$el.attr('method', 'get');
    var $renderedContent = $(this.template({searchParams: CarListing.searchParams}));
    this.$el.html($renderedContent);
    return this;
  },

  setDefaults: function () {
    this.selectChanged(this.$el.find('#search-make_id'));
    this.selectChanged(this.$el.find('#search-model_id'));
    this.updateModelSelect();

    return this;
  },

  changeSearchParams: function (event) {
    event.preventDefault();
    var $target = $(event.currentTarget);
    if ($target.prop('tagName') === 'SELECT') this.selectChanged($target);
    var newsearchParams = $target.parents('form').serializeJSON();
    CarListing.searchParams = newsearchParams;
    this.refreshListings();
  },

  refreshListings: function () {
    CarListing.listings.fetch({
      data: {search: CarListing.searchParams},
      reset: true
    });
  },

  selectChanged: function ($select) {
    if ($select.val()) {
      $select.addClass('selected');
    }
    else {
      $select.removeClass('selected');
    }
  },

  updateModelSelect: function () {
    var makeID = this.$el.find('#search-make_id').val();
    var $modelSelect = this.$el.find('#search-model_id');
    $modelSelect.html('<option value="">Model</option>')
    if (makeID) {
      var models = CarListing.subdivisions.get(makeID).children();
      models.each(function(model) {
        $modelSelect.append('<option value="'+model.id+'">'+model.get('name')+'</option>')
      });
      $modelSelect.prop('disabled', false).siblings('.mask').hide();
    }
    else {
      $modelSelect.prop('disabled', true).siblings('.mask').show();
    }
  },

  maybeShowTooltip: function (event) {
    console.log('hit')
    var $td = $(event.currentTarget);
    var $select = $td.find('select');
    if ($select.prop('disabled')) {
      var $tooltip = $td.find('.tooltip');
      console.log('hit2')
      $tooltip.stop().fadeIn(400, function () {
        $tooltip.stop().fadeOut(1200);
      });
    }
  }





});