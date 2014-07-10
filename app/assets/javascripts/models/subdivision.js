CarListing.Models.Subdivision = Backbone.Model.extend({

  initialize: function (models, options) {
    if (options.parent) this.parent = options.parent;
  },

  parse: function (json) {
    if (json.children) {
      this.children().set(json.children);
      delete json.children
    }

    return json;
  },

  children: function () {
    if (!this.get('children')) {
      this.set('children', new CarListing.Collections.Subdivisions([], {
        parent: this
      }));
    }

    return this.get('children');
  }
});