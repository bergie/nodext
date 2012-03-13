{Schema} = require 'jugglingdb'

exports.getSchema = (config) ->
  schema = new Schema config.database.provider, config.database.configuration

  unless config.database.logQueries is undefined
    schema.adapter.log = console.log if config.database.logQueries
    delete config.database.logQueries

  schema
