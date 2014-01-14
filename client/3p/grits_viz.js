/*globals $, console, d3, tangelo */

var kitware = {};

kitware.draw = function (url, selector) {
    "use strict";
    d3.json(url, function (d) {
        d.links = d.links.filter(function (d) {
            //return d.info_link;
            //return d.matching_symptoms > 4;
            //return d.geo_distance < 50;
            return d.matching_symptoms >= 3 || d.info_link || d.geo_distance < 50;
            //return d.distance = 400 / (d.matching_symptoms + 1);
            //return d.matching_symptoms >= 2;
        });
        d.nodes.forEach(function (d) {
            d.lat = +d.lat;
            d.lon = +d.lon;
            if (d.title.indexOf(">") >= 0) {
                d.shortTitle = d.title.split(">")[1].split("-")[0];
            } else {
                d.shortTitle = d.title.split(":")[1];
            }
        });
        $(selector).empty();
        $(selector).nodelink({
            data: d,
            nodeId: {field: "promed_id"},
            nodeLabel: {field: "shortTitle"},
            nodeCharge: {value: -20},
            nodeY: {field: "lat"},
            nodeX: {field: "lon"},
            linkOpacity: {value: 0.01},
            linkDistance: {value: 50},
            dynamicLabels: true
        });
    });
};

this.kitware = kitware;