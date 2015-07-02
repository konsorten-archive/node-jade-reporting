![Title Image](https://s3.eu-central-1.amazonaws.com/konsorten/Github/node-jade-reporting/header.png)

# Jade Reporting [![Build Status](https://travis-ci.org/konsorten/node-jade-reporting.svg?branch=master)](https://travis-ci.org/konsorten/node-jade-reporting)

A easy-to-use and fully-customizable report generator for node.js. This library wraps [wkhtmltppdf](http://wkhtmltopdf.org/) using [node-wkhtmltopdf](https://github.com/devongovett/node-wkhtmltopdf) and [PDFtk](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) to generate good-looking PDF-reports from [jade](https://github.com/jadejs/jade) or HTML including your own stationery.

It can also be used as a simple HTML2PDF generator with background-PDF functionality.

## Installation
via npm:

    npm install jade-reporting

### Dependencies

Please make sure you have the command-line versions of [wkhtmltppdf](http://wkhtmltopdf.org/) and [PDFtk server](https://www.pdflabs.com/tools/pdftk-the-pdf-toolkit/) installed.

## Examples

#### Generating a simple PDF from an HTML string:

```javascript
var report = require("jade-reporting");

//report.generate(source string or file, output filename, report data, options, callback(error, filename))
report.generate("<h1>PDF from string</h1><p>This is a string</p>", "Jade Simple.pdf");
```

#### Generating a complex report from a jade template with letterhead:

[![PDF Icon](https://s3.eu-central-1.amazonaws.com/konsorten/Github/node-jade-reporting/pdficon_large.png) Generated Report](https://s3.eu-central-1.amazonaws.com/konsorten/Github/node-jade-reporting/Jade+Complex+with+Letterhead.pdf)

Jade template:

```jade
link(rel="stylesheet" src="reportstyle.css")
.content
  h1 Great Report
  h2 First Sub-Headline
  p= name
  p= mail
  p Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  p Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  h2 Second Sub-Headline
  p Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  p &nbsp;
  h1 List of TV-Shows
  table
  thead
    th TV Show Name
    th Station
    th My Rating
  each showData, showName in tvshows
    tr
      td= showName
      td= showData.station
      td= showData.rating
  p Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur. Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  p Lorem ipsum dolor sit amet, consectetur adipisicing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua. Ut enim ad minim veniam, quis nostrud exercitation ullamco laboris nisi ut aliquip ex ea commodo consequat. Duis aute irure dolor in reprehenderit in voluptate velit esse cillum dolore eu fugiat nulla pariatur.
  strong Excepteur sint occaecat cupidatat non proident, sunt in culpa qui officia deserunt mollit anim id est laborum.
  img(src="https://assets-cdn.github.com/images/modules/logos_page/Octocat.png")
```
Routine:

```javascript

var _data = {
  subject: "Just A Report",
  tvshows: {
    "Doctor Who": {
      station: "BBC",
      rating: "Geronimo!"
    },
    "Person of Interest": {
      station: "CBS",
      rating: "Great"
    },
    "The Mentalist": {
      station: "CBS",
      rating: "Great"
    },
    "The Simpsons": {
      station: "FOX",
      rating: "Great"
    },
    "Family Guy": {
      station: "FOX",
      rating: "Great"
    },
    "True Blood": {
      station: "HBO",
      rating: "Bad"
    },
    "Desperate Housewifes": {
      station: "ABC",
      rating: "Bad"
    }
  }
};

var _config = {
  metaData: {
    author: "Michael Müller",
    title: "Testreport"
  },
  letterhead: "test/letterhead.pdf",
  margin: {
    left: 20,
    top: 50,
    bottom: 50
  }
};

report.generate(path.join(__dirname, "complex.jade"), "Jade Complex with Letterhead.pdf", _data , function(error, pdf) {
  if (error) {
    console.log (error);
    return false;
  }
  console.log ("Report created: " + pdf)
});
```

## Options

* `stylesheet`  Injecting additional CSS-propertys to the template
* `header` HTML-formated header to display on each page of the report
* `footer` HTML-formated footer to display on each page of the report
* `margin` Margin of the generated PDF-pages
    * `left`
    * `rigth`
    * `top`
    * `bottom`
* `letterhead` Adding a PDF document as background to the report using PDFtk's multibackground function. Applies each page of the letterhead PDF to the corresponding page of the report. If the report has more pages than the letterhead PDF, then the final letterhead page is repeated across these remaining pages in the report.
* `metaData` Meta data for the generated PDF
    * `creator`
    * `author`
    * `title`
* `executables`
    * `wkhtmltopdf` Command to execute wkhtmltopdf. Default: "wkhtmltopdf"
    * `pdftk` Command to execute PDFtk Server. Default: "pdftk"


## License
MIT
