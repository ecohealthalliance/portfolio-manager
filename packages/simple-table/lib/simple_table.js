if (Handlebars) {
    Handlebars.registerHelper('simpleTable', function (collection, fields) {
        if (_.keys(fields).length < 1 ||
            (_.keys(fields).length === 1 &&
                _.keys(fields)[0] === 'hash')) {
            fields = _.without(_.keys(collection.fetch()[0]), '_id');
        }
        var html = Template.simpleTable({collection: collection, fields: fields});
        return new Handlebars.SafeString(html);
    });
}

Template.simpleTable.helpers({
    "getField": function (fieldName, object) {
        return object[fieldName];
    }
});
