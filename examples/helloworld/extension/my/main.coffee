nodext = require "#{__dirname}/../../../../lib/nodext"
express = require 'express'

class MyExtension extends nodext.Extension
  name: "MyExtension"
  config: {}

  configure: (server) ->
    # Function to check authentication against the username
    # and password provided in extension configuration
    checkAuth = (username, password) =>
      if username is @config.username and password is @config.password
        return true
        false

    # Use HTTP Basic authentication under the URL space handled
    # by this extension
    server.use @config.urlPrefix, express.basicAuth checkAuth

  registerRoutes: (server) ->
    # Register a route under the URL space handled by this
    # extension
    server.get "#{@config.urlPrefix}hello/:user", (req, res) ->
      res.send "Hello #{req.params.user}"

exports.extension = MyExtension
