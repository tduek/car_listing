CarListing.Views.PhoneRecaptcha = Backbone.View.extend({
  initialize: function (options) {
    this.model = options.model;
  },

  tagName: 'form',

  className: 'phone clear-fix',

  template: JST['listings/show/phone_recaptcha'],

  render: function () {
    var renderedContent = this.template();
    this.$el.html(renderedContent);

    return this;
  },

  showRecaptcha: function (cb) {
    var view = this;
    Recaptcha.create(CarListing.RECAPTCHA_PUBLIC_KEY, '#recaptcha_widget', {
      theme: 'custom',
      custom_theme_widget: 'recaptcha_widget',
      callback: function () {
        view.$el.addClass('show');
        Recaptcha.focus_response_field()
      }
    });
  },

  events: {
    'submit': 'submitRecaptcha'
  },

  submitRecaptcha: function (event) {
    event.preventDefault();
    var view = this;
    var $textInput = view.$el.find('input[type="text"]');

    $.ajax({
      method: 'get',
      url: view.listing.phoneURL(),
      accepts: 'json',
      data: view.$el.serializeJSON(),
      beforeSend: function () {
        $textInput.prop('disabled', true)
        view.$el.addClass('busy')
      },
      success: function (data) {
        Recaptcha.destroy();
        view.$el.before('<span>' + data.phone + '</span>');
        view.remove();
      },
      error: function (data) {
        $('.recaptcha_nothad_incorrect_sol').removeClass(
          'recaptcha_nothad_incorrect_sol'
        );

        view.$el.find('.recaptcha_only_if_incorrect_sol')
          .stop()
          .slideDown(200)
          .fadeTo(300, 0.1).fadeTo(300, 1)
          .fadeTo(300, 0.1).fadeTo(300, 1)
          .delay(1000)
          .slideUp(200)
          .promise().done(function () {
            Recaptcha.reload()
            $textInput.prop('disabled', false);
          }
        );
      },
      complete: function () {
        view.$el.removeClass('busy');
      }
    });
  }

});