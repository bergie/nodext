###
# NodeXT configuration handling

This module provides configuration loading functionality for NodeXT
applications.
###
fs = require 'fs'
path = require 'path'

exports.getConfigFile = ->
  ###
  Get the name of configuration file used for the NodeXT application.
  
  By default returns the last argument NodeXT was started with,
  so when it is run with `nodext somefile.json`, will return
  `somefile.json`. If no argument was provided, it will default to
  `configuration.json`.
  ###
  if process.argv.length > 2
    return path.resolve process.cwd(), process.argv[2]
  path.resolve process.cwd(), "configuration.json"

exports.getProjectRoot = (configFile) ->
  ###
  Determine the root directory path of the NodeXT application.
  ###
  configFile = exports.getConfigFile() unless configFile

  # Remove filename, and optionally 'configuration' subdir
  configFileParts = configFile.split '/'
  configFileParts.pop()
  if configFileParts[configFileParts.length - 1] is 'configuration'
    configFileParts.pop()

  configFileParts.join '/'

exports.getConfig = (configFile) ->
  ###
  Get the parsed configuration object.
  ###
  configFile = exports.getConfigFile() unless configFile

  cfg = JSON.parse fs.readFileSync configFile

  # Set project root to configuration
  cfg.projectRoot ?= exports.getProjectRoot configFile

  # Heroku support, get server port from environment
  if process.env.PORT
    cfg.server?.port = process.env.PORT
  if process.env.DATABASE_URL
    cfg.database?.configuration?.url = process.env.DATABASE_URL

  cfg
