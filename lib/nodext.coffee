###
# NodeXT library entrypoint

This is the main way for extensions and other applications to
access NodeXT functionality:

    nodext = require 'nodext'

To load all enabled extensions:

    extensions = nodext.loadExtensions()

To extend the Extension baseclass:

    class MyExtension extends nodext.Extension
###
extension = require "#{__dirname}/Extension"

exports.Extension = extension.Extension
exports.loadExtensions = extension.loadExtensions

config = require "#{__dirname}/configuration"
exports.getConfig = config.getConfig
exports.getConfigFile = config.getConfigFile

database = require "#{__dirname}/database"
exports.getSchema = database.getSchema
exports.getModels = database.getModels

exports.server = require "#{__dirname}/server"
