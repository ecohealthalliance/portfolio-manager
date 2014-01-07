var getSessionSortKey = function (identifier) {
    return identifier + '-simple-table-sort-key';
}

if (Handlebars) {
    Handlebars.registerHelper('simpleTable', function (identifier, collection, fields, attrs) {
        if (_.keys(fields).length < 1 ||
            (_.keys(fields).length === 1 &&
                _.keys(fields)[0] === 'hash')) {
            fields = _.without(_.keys(collection.findOne()), '_id');
        }
        Session.setDefault(getSessionSortKey(identifier), fields[0].key);
        var html = Template.simpleTable({identifier: identifier, collection: collection, fields: fields, attrs: attrs});
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
    },

    "isSortKey": function (identifier) {
        var sortKey = Session.get(getSessionSortKey(identifier));
        return this.key === sortKey;
    },

    "isSortable": function () {
        return !this.fn;
    },

    "sortedRows": function () {
        var sortKey = Session.get(getSessionSortKey(this.identifier));
        var sortQuery = {};
        sortQuery[sortKey] = 1;
        return this.collection.find({}, {sort: sortQuery});
    }
});

Template.simpleTable.events({
    "click .simple-table .sortable": function (event) {
        var sortKey = $(event.target).attr("key");
        var identifier = $(event.target).parents('.simple-table').attr('simple-table-id');
        Session.set(getSessionSortKey(identifier), sortKey);
    }
});
