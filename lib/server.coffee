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

  View engine layouts can be configured using the `layout` key.
  ###
  extensions = require('./Extension').loadExtensions config

  database = require './database'
  schema = database.getSchema config
  models = database.getModels schema, config

  server = http()

  server.configure ->
    done = ->
    pending = 0
    for name, extension of extensions
      extension.configure server, models
      unless extension.isReady()
        pending++
        extension.once 'ready', ->
          pending--
          do done unless pending
    root = path.resolve config.projectRoot, config.server.view.options.root
    if config.server.view
      config.server.view.engine ?= 'jade'
      config.server.view.options ?= {}
      config.server.view.options.root ?= './views'
      config.server.view.options.root = root
      server.set 'view engine', config.server.view.engine
      server.set 'view options', config.server.view.options
      server.set 'views', config.server.view.options.root

    do done unless pending

  registerRoutes = ->
    for name, extension of extensions
      extension.registerRoutes server

  pendingRoute = 0
  for name, extension of extensions
    unless extension.isReady()
      pendingRoute++
      extension.once 'ready', ->
        pendingRoute--
        do registerRoutes unless pendingRoute
  do registerRoutes unless pendingRoute

  server
