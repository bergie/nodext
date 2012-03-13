NodeXT - Plugin-driven Node.js applications
===========================================

NodeXT is a way to organize your Node.js web application so that it is driven by a collection of extensions. This makes the application easier to manage, as distinct collections of functionality can be isolated in their own extensions that can be enabled and disabled as needed.

Each extension runs within a URL prefix provided by configuration.

## Structure of an extension

At minimum, an extension provides a `main` file that exports method `extension`. This method returns a constructor function to the extension object.

The NodeXT extension loader calls this method for each enabled extension, and then instantiates the extension objects through the constructor functions.

These constructor functions get a configuration object that may contain extension-specific configurations.

The  extension might look like the following (in CoffeeScript):

    # Get the extension base class
    nodext = require 'nodext'

    class MyExtension extends nodext.Extension
      name: "MyExtension"
      config: {}

    exports.extension = MyExtension

There are several methods that the extensions may implement to provide actual behavior:

* `configure(server)`: run in the configuration phase of Express. An extension could add its own middlewares to server configuration here, for example to provide static servers or authentication
* `getModels(schema, otherModels)`: run whenever JugglingDB is used. Here the extension can provide its own JugglingDB models if necessary
* `registerRoutes(server)` run after server has been configured. Here the extension can register its own Express routes

The extension configuration contains a key `urlPrefix` that tells the URL prefix the extension should run under. A well-behaved component should only register middleware or routes to work under the prefix to ensure it doesn't step on the toes of other loaded extensions.

For example:

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

Such extension, stored in `extension/my/main.coffee` could be enabled by:

    {
      "server": {
        "hostname": "127.0.0.1",
        "port": 8001
      },
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
    }

Now, run this with NodeXT:

    $ nodext my_config_file.json

...and the extension's route should answer in <http://127.0.0.1/foo/hello/World>. Use _user_ / _pass_ to log in.
