fs = require 'fs'
path = require 'path'

exports.getConfigFile = ->
  if process.argv.length > 2
    return process.argv[2]

  "configuration.json"

exports.getProjectRoot = (configFile) ->
  configFile = exports.getConfigFile() unless configFile

  # Convert to absolute path
  configFile = path.resolve process.cwd(), configFile

  # Remove filename, and optionally 'configuration' subdir
  configFileParts = configFile.split '/'
  configFileParts.pop()
  if configFileParts[configFileParts.length - 1] is 'configuration'
    configFileParts.pop()

  configFileParts.join '/'

exports.getConfig = (configFile) ->
  configFile = exports.getConfigFile() unless configFile

  cfg = JSON.parse fs.readFileSync "#{process.cwd()}/#{configFile}"

  cfg.projectRoot ?= exports.getProjectRoot configFile

  cfg
