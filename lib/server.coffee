http = require 'express'
path = require 'path'

exports.createApplication = (config) ->
  extensions = require('./Extension').loadExtensions config

  schema = require('./database').getSchema config
  models = require('./models').getModels schema, config

  if config.server.privateKey and config.server.certificate
    config.server.privateKey = path.resolve config.projectRoot, config.server.privateKey
    config.server.certificate = path.resolve config.projectRoot, config.server.certificate
    fs = require 'fs'
    serverOptions =
      key: fs.readFileSync config.server.privateKey
      cert: fs.readFileSync config.server.certificate
    server = http.createServer serverOptions
  else
    server = http.createServer()

  server.configure ->
    server.use http.logger()

    server.use http.bodyParser()
    server.use http.cookieParser()

    for name, extension of extensions
      extension.configure server, models

    if config.server.view
      config.server.view.engine ?= 'jade'
      server.set 'view engine', config.server.view.engine

  for name, extension of extensions
    extension.registerRoutes server

  server
