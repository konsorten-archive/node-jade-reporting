jade = require "jade"
wkhtmltopdf = require "wkhtmltopdf"
path = require "path"
validate = require("jsonschema").validate;
tmp = require "tmp"
exec = require("child_process").exec
info = require "./../package.json"
fs = require "fs"
moment = require "moment"

module.exports =
  checkDependencies: (config = {}, callback = (installed) -> throw "Missing dependencies" unless installed is true) ->
    try
      exec((config.executables?.wkhtmltopdf ? "wkhtmltopdf") + " -V", (err, stdout, stderr) ->
        if err?
          callback(false)
          return
        else
          exec((config.executables?.pdftk ? "pdftk") + " -h", (err, stdout, stderr) ->
            if err?
              callback(false)
              return
            else
              callback(true)
              return
          )
      )
    catch ex
      callback(false)
      return


  generate: (template, output, data = {}, config = {}, callback = (error, data) -> throw error if error?) ->
    try
      throw "No template provided" if isEmptyOrNull(template)
      throw "No output file provided" if isEmptyOrNull(output)

      _validationError = validateConfig(config).errors
      if _validationError.length > 0
        _err = Error "Config is invalid"
        _err.stack = _validationError
        throw _err
        return

      wkhtmltopdf.command = config.executables?.wkhtmltopdf ? "wkhtmltopdf"

      this.checkDependencies config, (installed) ->
        unless installed is true
          callback(Error("Missing dependencies"), null)
          return

        try
          if isPath(template)
            fs.exists(template, (exists) ->
              if exists is true
                _html = jade.renderFile(template, enrichData(data))
                throw "Error during html generation. Please check Jade syntax." if isEmptyOrNull(_html)
                generatePDF(_html, output, config, (error, pdf) ->
                  callback(error, pdf)
                )
              else
                _html = jade.render(template, enrichData(data))
                console.log wkhtmltopdf.command
                throw "Error during html generation. Please check Jade syntax." if isEmptyOrNull(_html)
                generatePDF(_html, output, config, (error, pdf) ->
                  callback(error, pdf)
                )
            )
          else
            _html = jade.render(template, enrichData(data))
            throw "Error during html generation. Please check Jade syntax." if isEmptyOrNull(_html)
            generatePDF(_html, output, config, (error, pdf) ->
              callback(error, pdf)
            )
        catch ex
          callback(ex, null)
          _html = null
          return
    catch ex
      callback(ex, null)
      return


generatePDF = (html, output, config, callback) ->
  tmp.dir {prefix: "konsorten-"}, (err, tempdir, cleanupCallback) ->
    throw err if err?

    config.metaData ?= {}

    _infoFileTemplate = "InfoBegin\nInfoKey: Creator\nInfoValue: " + (config.metaData.creator ? "müller & konsorten (https://konsorten.de) PDF Report Generator") + "\nInfoBegin\nInfoKey: Producer\nInfoValue: " + info.name + " " + info.version + "\n#{if config.metaData.author? then 'InfoBegin\nInfoKey: Author\nInfoValue: ' +  (config.metaData.author ? '') + '\n' else ''}#{if config.metaData.title? then 'InfoBegin\nInfoKey: Title\nInfoValue: ' +  config.metaData.title + '\n' else ''}"
    config.stylesheet ?= "body {padding: 0; margin: 0; font-family: arial, \"sans-serif\";} * {max-width: 100%;}"

    _infoFileName = path.join(tempdir, "info.txt")
    _styleSheetFileName = path.join(tempdir, "style.css")
    _tempPDFName = path.join(tempdir, "generated.pdf")

    fs.writeFile(_infoFileName, _infoFileTemplate, (err) ->
      throw err if err?

      fs.writeFile(_styleSheetFileName, config.stylesheet, (err) ->
        throw err if err?

        htmlToPdf(html, _tempPDFName, _styleSheetFileName, config.margin ? {}, (code) ->
          unless code?
            exec("pdftk \"" + _tempPDFName + "\" update_info_utf8 \"" + _infoFileName + "\" output #{if config.letterhead? then '\"' + _tempPDFName + '_temp\"' else '\"' + output + '\"'}", (err, stdout, stderr) ->
              throw err if err?
              throw stderr if stderr

              _filesToDelete = [_infoFileName, _styleSheetFileName, _tempPDFName]

              _finish = ->
                deleteFiles(_filesToDelete, (err) ->
                  # do not handle errors
                  callback(null, output)
                  cleanupCallback()
                )

              if config.letterhead?
                _filesToDelete.push(_tempPDFName + "_temp")
                exec("pdftk " + _tempPDFName + "_temp multibackground \"" + config.letterhead + "\" output \"" + output + "\"", (err, stdout, stderr) ->
                  throw err if err?
                  throw stderr if stderr
                  _finish()
                )
              else
                _finish()

            )
            return true
          else
            err = Error(code)
            callback(err, null)
        )
      )
    )


htmlToPdf = (html, output, styleSheet, margin, callback) ->
  wkhtmltopdf(html,
    encoding: "utf-8"
    output: output
    pageSize: "a4"
    "margin-top": margin.top ? 15
    "margin-bottom": margin.bottom ? 15
    "margin-left": margin.left ? 15
    "margin-right": margin.right ? 15
    dpi: 300
    "image-quality": 100
    "user-style-sheet": styleSheet
  , (code, signal) ->
    callback code
  )

deleteFiles = (files, callback) ->
  i = files.length
  files.forEach (filepath) ->
    fs.unlink filepath, (err) ->
      i--
      if err
        callback err
        return
      else if i <= 0
        callback null
      return
    return
  return

enrichData = (data) ->
  data["tools"] =
    moment: moment
  data["today"] = (format = "L") ->
    return moment().format(format)
  return data


validateConfig = (config) ->
  shema =
    type: "object"
    additionalProperties: false
    properties:
      stylesheet:
        type: "string"
      header:
        type: "string"
      footer:
        type: "string"
      margin:
        type: "object"
        properties:
          top:
            type: "number"
          bottom:
            type: "number"
          left:
            type: "number"
          right:
            type: "number"
      letterhead:
        type: "string"
      metaData:
        type: "object"
        properties:
          creator:
            type: "string"
      executables:
        type: "object"
        properties:
          wkhtmltopdf:
            type: "string"
          pdftk:
            type: "string"

  return validate(config, shema)

isPath = (string) ->
  return /^[-\w^üäöÜÄÖß&'@{}[\]\\/:?#,$=!#().%+~ ]+$/.test(string)

isEmptyOrNull = (string) ->
  if !string? or string.length is 0
    return true
  else
    return false
