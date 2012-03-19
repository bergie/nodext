###
# NodeXT database handling

This is an optional module of NodeXT that sets up a [JugglingDB](https://github.com/1602/jugglingdb)
database connection based on the given configuration.
###
{Schema} = require 'jugglingdb'

exports.getSchema = (config) ->
  ###
  Returns a JugglingDB schema instance according to NodeXT
  configuration, or `null` if there is no database configured.

  Here is an example of using a local Redis service:

      "database": {
        "provider": "redis",
        "configuration": {}
      },

  And this is how a MySQL connection could be configured:

      "database": {
        "provider": "mysql",
        "configuration": {
          "username": "someuser",
          "password": "somepassword",
          "database": "dbname"
        }
      },
  ###
  return null unless config.database
  schema = new Schema config.database.provider, config.database.configuration

  unless config.database.logQueries is undefined
    schema.log = schema.adapter.log = console.log if config.database.logQueries
    delete config.database.logQueries

  schema

exports.getModels = (schema, config) ->
  ###
  Returns JugglingDB models registered by various extensions.

  This runs the `getModels` method of each enabled extension.
  ###
  extensions = require('./Extension').loadExtensions config
  models = {}
  return {} unless schema

  for name, extension of extensions
    extModels = extension.getModels schema, models
    for name, model of extModels
      models[name] = model
  models
