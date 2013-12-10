Package.describe({
    summary: "Simple table designed for Meteor"
});

Package.on_use(function (api) {
    api.use('templating', 'client');
    api.use('handlebars', 'client');
    api.use('jquery', 'client');
    api.use('underscore', 'client');
    api.use('bootstrap', 'client');

    api.add_files('lib/simple_table.html', 'client');
    api.add_files('lib/simple_table.js', 'client');

    if (api.export) {
        api.export('SimpleTable');
    }
});