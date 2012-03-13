http = require 'express'

exports.createApplication = (config) ->
  extensions = require('./Extension').loadExtensions config

  schema = require('./database').getSchema config
  models = require('./models').getModels schema, config

  if config.server.privateKey
    fs = require 'fs'
    serverOptions =
      key: fs.readFileSync "#{__dirname}/#{config.server.privateKey}"
      cert: fs.readFileSync "#{__dirname}/#{config.server.certificate}"
    server = http.createServer serverOptions
  else
    server = http.createServer()

  server.configure ->
    server.use http.logger()

    server.use http.bodyParser()
    server.use http.cookieParser()

    for name, extension of extensions
      extension.configure server, models

    server.set 'view engine', config.server.viewEngine

  for name, extension of extensions
    extension.registerRoutes server

  server
