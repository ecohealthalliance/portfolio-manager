var getSessionSortKey = function (identifier) {
    return identifier + '-reactive-table-sort';
};

var getSessionRowsPerPageKey = function (identifier) {
    return identifier + '-reactive-table-rows-per-page';
};

var getSessionCurrentPageKey = function (identifier) {
    return identifier + '-reactive-table-current-page';
};


if (Handlebars) {
    Handlebars.registerHelper('reactiveTable', function (collection, fields, attrs) {
        if (_.keys(fields).length < 1 ||
                (_.keys(fields).length === 1 &&
                _.keys(fields)[0] === 'hash')) {
            fields = _.without(_.keys(collection.findOne()), '_id');
        }
        var identifier = collection._name + _.uniqueId();
        Session.setDefault(getSessionSortKey(identifier), fields[0].key || fields[0]);
        Session.setDefault(getSessionRowsPerPageKey(identifier), 10);
        Session.setDefault(getSessionCurrentPageKey(identifier), 0);
        var html = Template.reactiveTable({
                identifier: identifier,
                collection: collection,
                fields: fields,
                attrs: attrs
            });
        return new Handlebars.SafeString(html);
    });
}

Template.reactiveTable.helpers({
    "getField": function (object) {
        var fn = this.fn || function (value) { return value; };
        return fn(object[this.key || this]);
    },

    "getAttrs": function (attrs) {
        var attrStrings = _.map(attrs, function (attr, name) {
            return name + '=' + this[attr]
        }, this);
        return attrStrings.join(' ');
    },

    "getKey": function () {
        return this.key || this;
    },

    "getLabel": function () {
        return this.label || this;
    },

    "isSortKey": function (field, identifier) {
        return Session.equals(getSessionSortKey(identifier), field.key || field);
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
        return this.collection.find({}, {
            sort: sortQuery,
            skip: skip,
            limit: limit
        });
    },

    "getRowsPerPage" : function () {
        return Session.get(getSessionRowsPerPageKey(this.identifier));
    },

    "getCurrentPage" : function () {
        return 1 + Session.get(getSessionCurrentPageKey(this.identifier));
    },

    "isntFirstPage" : function () {
        return Session.get(getSessionCurrentPageKey(this.identifier)) > 0;
    },

    "isntLastPage" : function () {
        var currentPage = 1 + Session.get(getSessionCurrentPageKey(this.identifier));
        var rowsPerPage = Session.get(getSessionRowsPerPageKey(this.identifier));
        var count = this.collection.find().count();
        return currentPage < Math.ceil(count / rowsPerPage);
    },

    "getPageCount" : function () {
        var rowsPerPage = Session.get(getSessionRowsPerPageKey(this.identifier));
        var count = this.collection.find().count();
        return Math.ceil(count / rowsPerPage);
    }
});

Template.reactiveTable.events({
    "click .reactive-table .sortable": function (event) {
        var sortKey = $(event.target).attr("key");
        var identifier = $(event.target).parents('.reactive-table').attr('reactive-table-id');
        Session.set(getSessionSortKey(identifier), sortKey);
    },

    "change .reactive-table-navigation .rows-per-page input": function (event) {
        try {
            var rowsPerPage = parseInt($(event.target).val(), 10);
            var identifier = $(event.target).parents('.reactive-table-navigation').attr('reactive-table-id');
            Session.set(getSessionRowsPerPageKey(identifier), rowsPerPage);
        } catch (e) {
            console.log("rows per page must be an integer");
        }
    },

    "change .reactive-table-navigation .current-page input": function (event) {
        try {
            var currentPage = parseInt($(event.target).val(), 10) - 1;
            var identifier = $(event.target).parents('.reactive-table-navigation').attr('reactive-table-id');
            Session.set(getSessionCurrentPageKey(identifier), currentPage);
        } catch (e) {
            console.log("current page must be an integer");
        }
    },

    "click .reactive-table-navigation .previous-page": function (event) {
        var identifier = $(event.target).parents('.reactive-table-navigation').attr('reactive-table-id');
        var currentPageKey = getSessionCurrentPageKey(identifier);
        var currentPage = Session.get(currentPageKey);
        Session.set(currentPageKey, currentPage - 1);
    },

    "click .reactive-table-navigation .next-page": function (event) {
        var identifier = $(event.target).parents('.reactive-table-navigation').attr('reactive-table-id');
        var currentPageKey = getSessionCurrentPageKey(identifier);
        var currentPage = Session.get(currentPageKey);
        Session.set(currentPageKey, currentPage + 1);
    }
});
