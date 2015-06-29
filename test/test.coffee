report = require "../dist/module.js"
path = require "path"
test = require "tape"
tapSpec = require "tap-spec"

report.checkDependencies null, (installed) ->
  test.createStream()
    .pipe(tapSpec())
    .pipe(process.stdout)

  test 'report.generate(template, output[, data, config, callback]) throws an error when executing without template', (t) ->
    t.plan(3)
    t.throws ->
      report.generate(null, "Error.pdf")
    , "Error for null value thrown"
    t.throws ->
      report.generate(undefined, "Error.pdf")
    , "Error for undefinied value thrown"
    t.throws ->
      report.generate("", "Error.pdf")
    , "Error for empty value thrown"

  test 'report.generate(template, output[, data, config, callback]) throws an error when executing without output file', (t) ->
    t.plan(3)
    t.throws ->
      report.generate("p Text", null)
    , "Error for null value thrown"
    t.throws ->
      report.generate("p Text", undefined)
    , "Error for undefinied value thrown"
    t.throws ->
      report.generate("p Text", "")
    , "Error for empty value thrown"

  test 'report.generate(template, output[, data, config, callback]) throws an error when executables are not installed', (t) ->
    t.plan(2)

    report.generate("p Text", "Error.pdf", null,
      executables:
        wkhtmltopdf: "invalidwkhtmltopdf"
    , (error, pdf) ->
      t.assert error, "Error for wkhtmltopdf thrown"
    )

    report.generate("p Text", "Error.pdf", null,
      executables:
        pdftk: "invalidpdftk"
    , (error, pdf) ->
      t.assert error, "Error for pdftk thrown"
    )

  unless installed
    console.log "Missing dependencies. Aborting test..."
    return

  test 'report.generate(template, output[, data, config, callback]) throws an error when executing with invalid config object', (t) ->
    t.plan(2)
    t.throws ->
      report.generate("p Text", "Error.pdf", null,
        undefinedProperty: "shoudthrow"
      )
    , "Error for undefined value thrown"
    t.throws ->
      report.generate("p Text", "Error.pdf", null,
        stylesheet: true
      )
    , "Error for invalid type thrown"


  test "generates simple pdf from jade string", (t) ->
    t.plan(2)
    _start = Date.now()
    report.generate("h1 Report from string\np This is a string", "Jade Simple.pdf",
      subject: "Just a PDF"
    ,
      metaData:
        author: "Michael Müller"
        title: "Testreport"
    , (error, pdf) ->
      t.error error, "No error occurred"
      _end = Date.now()
      t.assert pdf, "PDF File created: " + pdf + " in " + (_end-_start) + "ms"
    )

  test "generates simple pdf without letterhead from file", (t) ->
    t.plan(2)
    _start = Date.now()
    report.generate(path.join(__dirname, "simple.jade"), "Jade Simple from File.pdf",
      subject: "Just a PDF"
    ,
      metaData:
        author: "Michael Müller"
        title: "Testreport"
    , (error, pdf) ->
      t.error error, "No error occurred"
      _end = Date.now()
      t.assert pdf, "PDF File created: " + pdf + " in " + (_end-_start) + "ms"
    )

  test "generates complex pdf with letterhead", (t) ->
    t.plan(2)
    _start = Date.now()
    report.generate(path.join(__dirname, "complex.jade"), "Jade Complex with Letterhead.pdf",
      subject: "Just A Report"
      tvshows:
        "Doctor Who":
          station: "BBC"
          rating: "Geronimo!"
        "Person of Interest":
          station: "CBS"
          rating: "Great"
        "The Mentalist":
          station: "CBS"
          rating: "Great"
        "The Simpsons":
          station: "FOX"
          rating: "Great"
        "Family Guy":
          station: "FOX"
          rating: "Great"
        "True Blood":
          station: "HBO"
          rating: "Bad"
        "Desperate Housewifes":
          station: "ABC"
          rating: "Bad"
    ,
      metaData:
        author: "Michael Müller"
        title: "Testreport"
      letterhead:"test/letterhead.pdf"
      margin:
        left: 20
        top: 50
        bottom: 50
    , (error, pdf) ->
      t.error error, "No error occurred"
      _end = Date.now()
      t.assert pdf, "PDF File created: " + pdf + " in " + (_end-_start) + "ms"
    )
