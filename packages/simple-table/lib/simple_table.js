if (Handlebars) {
    Handlebars.registerHelper('simpleTable', function (collection, fields, attrs) {
        if (_.keys(fields).length < 1 ||
            (_.keys(fields).length === 1 &&
                _.keys(fields)[0] === 'hash')) {
            fields = _.without(_.keys(collection.fetch()[0]), '_id');
        }
        var html = Template.simpleTable({collection: collection, fields: fields, attrs: attrs});
        return new Handlebars.SafeString(html);
    });
}

Template.simpleTable.helpers({
    "getField": function (object) {
        var fn = this.fn || function (value) { return value; };
        return fn(object[this.key || this]);
    },

    "getAttrs": function (attrs) {
        attrStrings = _.map(attrs, function (attr, name) {
            return name + '=' + this[attr]
        }, this);
        return attrStrings.join(' ');
    }
});
