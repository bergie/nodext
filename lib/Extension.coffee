###
# NodeXT extension handling

This module provides the necessary entry points to extension handling
in NodeXT:

* Base class for extensions
* Extension loader
###
{_} = require 'underscore'
path = require 'path'
events = require 'events'

class Extension extends events.EventEmitter
  ###
  ## NodeXT extension baseclass

  This class can be used for easily defining new NodeXT extensions
  without having to implement all the necessary interface methods.

  A minimal extension `main.coffee` would look like:

      nodext = require 'nodext'
      class MyExtension extends nodext.Extension
        name: "MyExtension"
        config: {}
      exports.extension = MyExtension

  After this, just implement the methods used in your extension.
  This will usually mean at least `configure` or `registerRoutes`.
  ###
  name: ""
  version: "0.0.1"
  config: {}

  #
  constructor: (config) ->
    ###
    Set up the extension with a given configuration.

    This will extend the extension's default configuration
    with the configuration received from NodeXT extension
    configuration object.
    ###
    @config = _.extend @config, config

  configure: (server) ->
    ###
    Do necessary configurations for the Express server.

    This can include registering middleware, though components
    should load them only for `@config.urlPrefix` instead of
    registering globally.
    ###

  # Get JugglingDB models for Schema
  getModels: (schema) ->
    ###
    Get the JugglingDB models for a given schema.

    If an extension uses the JugglingDB ORM, this is the place
    where models can be populated.
    ###
    {}

  registerRoutes: (server) ->
    ###
    Register routes to Express server under given prefix
    ###

  isReady: -> true

exports.Extension = Extension

loaded = {}
exports.loadExtensions = (config) ->
  ###
  Load all extensions enabled in configuration.

  The extension configuration object looks something like:

      "extensions": {
        "/foo/": {
          "name": "my",
          "location": "./extension/my",
          "configuration": {
            "username": "user",
            "password": "pass"
          }
        }
      }

  The URL prefix given as the key when enabling an extension
  will be set as the `urlPrefix` key of the extension configuration.
  ###
  config ?= {}
  config.extensionDefaults ?= {}
  config.extensions ?= []

  return loaded unless _.isEmpty loaded

  for prefix, extension of config.extensions
    extension.configuration ?= {}
    extension.configuration.urlPrefix = prefix

    extension.location ?= "../extension/#{extension.name}"
    extension.location = path.resolve config.projectRoot, extension.location

    ext = require "#{extension.location}/main"
    config = _.defaults extension.configuration, config.extensionDefaults
    loaded[extension.name] = new ext.extension config
  loaded
