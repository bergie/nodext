###
# NodeXT web server

This module sets up the [Express](http://expressjs.com/) server
used by NodeXT and registers the middleware and routes from all
enabled extensions for it.
###
http = require 'express'
path = require 'path'

exports.createApplication = (config) ->
  ###
  Instantiate an Express server based on the configuration.

  To enable SSL, provide something like the following configuration:

      "server": {
        "hostname": "127.0.0.1",
        "port": 443,
        "privateKey": "privatekey.pem",
        "certificate": "certificate.pem"
      },

  Express view engines can be configured with:

      "server": {
        ...
        "view": {
          "engine": "jade"
        }
      }
  ###
  extensions = require('./Extension').loadExtensions config

  database = require './database'
  schema = database.getSchema config
  models = database.getModels schema, config

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
    for name, extension of extensions
      extension.configure server, models

    if config.server.view
      config.server.view.engine ?= 'jade'
      server.set 'view engine', config.server.view.engine

  for name, extension of extensions
    extension.registerRoutes server

  server
