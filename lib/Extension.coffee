{_} = require 'underscore'
path = require 'path'

class Extension
  name: ""
  version: "0.0.1"
  config: {}

  # Set up the extension with a given configuration
  constructor: (config) ->
    @config = _.extend @config, config

  # Do necessary configurations for the server
  configure: (server) ->

  # Get JugglingDB models for Schema
  getModels: (schema) -> {}

  # Register routes to Express server under given prefix
  registerRoutes: (server) ->

exports.Extension = Extension

loaded = {}
exports.loadExtensions = (config) ->
  config ?= {}
  config.extensions ?= []

  return loaded unless _.isEmpty loaded

  for prefix, extension of config.extensions
    extension.configuration ?= {}
    extension.configuration.urlPrefix = prefix

    extension.location ?= "../extension/#{extension.name}"
    extension.location = path.resolve config.projectRoot, extension.location

    ext = require "#{extension.location}/main"
    loaded[extension.name] = new ext.extension extension.configuration
  loaded
