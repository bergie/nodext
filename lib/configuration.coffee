fs = require 'fs'

exports.getConfigFile = ->
  if process.argv.length > 2
    return process.argv[2]

  "configuration.json"

exports.getConfig = (configFile) ->
  configFile = exports.getConfigFile() unless configFile

  cfg = JSON.parse fs.readFileSync "#{process.cwd()}/#{configFile}"
  cfg
