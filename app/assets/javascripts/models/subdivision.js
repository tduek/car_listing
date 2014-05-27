CarListing.Models.Subdivision = Backbone.Model.extend({
  parse: function (json) {
    if (json.children) {
      this.children().set(json.children);
      delete json.children
    }

    return json;
  },

  children: function () {
    if (!this.get('children')) {
      this.set('children', new CarListing.Collections.Subdivisions())
    }

    return this.get('children');
  }
});