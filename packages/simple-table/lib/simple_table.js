var getSessionSortKey = function (identifier) {
    return identifier + '-simple-table-sort';
};

var getSessionRowsPerPageKey = function (identifier) {
    return identifier + '-simple-table-rows-per-page';
};

var getSessionCurrentPageKey = function (identifier) {
    return identifier + '-simple-table-current-page';
};


if (Handlebars) {
    Handlebars.registerHelper('simpleTable', function (collection, fields, attrs) {
        if (_.keys(fields).length < 1 ||
            (_.keys(fields).length === 1 &&
                _.keys(fields)[0] === 'hash')) {
            fields = _.without(_.keys(collection.findOne()), '_id');
        }
        var identifier = collection._name + _.uniqueId();
        Session.setDefault(getSessionSortKey(identifier), fields[0].key);
        Session.setDefault(getSessionRowsPerPageKey(identifier), 10);
        Session.setDefault(getSessionCurrentPageKey(identifier), 0);
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
        var limit = Session.get(getSessionRowsPerPageKey(this.identifier));
        var currentPage = Session.get(getSessionCurrentPageKey(this.identifier));
        var skip = currentPage * limit;
        return this.collection.find({}, {sort: sortQuery, skip: skip, limit: limit});
    },

    "getRowsPerPage" : function () {
        return Session.get(getSessionRowsPerPageKey(this.identifier));
    },

    "getCurrentPage" : function () {
        return 1 + Session.get(getSessionCurrentPageKey(this.identifier));
    },

    "getPageCount" : function () {
        var rowsPerPage = Session.get(getSessionRowsPerPageKey(this.identifier));
        var count = this.collection.find().count();
        return Math.ceil(count / rowsPerPage);
    }
});

Template.simpleTable.events({
    "click .simple-table .sortable": function (event) {
        var sortKey = $(event.target).attr("key");
        var identifier = $(event.target).parents('.simple-table').attr('simple-table-id');
        Session.set(getSessionSortKey(identifier), sortKey);
    },

    "change .simple-table-navigation .rows-per-page": function (event) {
        try {
            var rowsPerPage = parseInt($(event.target).val(), 10);
            var identifier = $(event.target).parents('.simple-table-navigation').attr('simple-table-id');
            Session.set(getSessionRowsPerPageKey(identifier), rowsPerPage);
        } catch (e) {
            console.log("rows per page must be an integer");
        }
    },

    "change .simple-table-navigation .current-page": function (event) {
        try {
            var currentPage = parseInt($(event.target).val(), 10) - 1;
            var identifier = $(event.target).parents('.simple-table-navigation').attr('simple-table-id');
            Session.set(getSessionCurrentPageKey(identifier), currentPage);
        } catch (e) {
            console.log("rows per page must be an integer");
        }
    }
});
