This package adds a handlebars helper called simpleTable.

Call it from a template and pass it the collection to put in the table: {{simpleTable collection}}.

To specify columns, pass an additional fields argument: {{simpleTable collection fields}}.

Fields should be an array of field elements, each with a key (an attribute in the collection) and a label (to display in the table header). You can also compute a function on the attribute's value to display in the table, by adding fn to the field.

E.g.:
        [
            { key: 'name', label: 'Name' },
            { key: 'location', label: 'Location' },
            { key: 'year', label: 'Year' },
            { 
                key: 'resources',
                label: 'Resources',
                fn: function (value) { return value.length; }
            }
        ]
        
Finally, you can add attributes to a row's html, by passing an attributes argument: {{simpleTable collection fields attrs}}

attrs should be an object, with the html attribute names as keys and the collection keys as values.

E.g.:
  
    { 'element-id': '_id' }