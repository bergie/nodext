exports.getModels = (schema, config) ->
  extensions = require('./Extension').loadExtensions config
  models = {}
  for name, extension of extensions
    extModels = extension.getModels schema, models
    for name, model of extModels
      models[name] = model
  models
