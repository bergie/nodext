NodeXT - Plugin-driven Node.js applications
===========================================

[![Greenkeeper badge](https://badges.greenkeeper.io/bergie/nodext.svg)](https://greenkeeper.io/)

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

    nodext = require 'nodext'
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

### Configuring and running extensions

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

#### Running on Heroku

NodeXT has tentative Heroku support. With it, the `server.port` parameter of your NodeXT configuration will be overridden with `process.env.PORT`, if defined.

You'll also want to define a `Procfile` with something like:

    web: ./node_modules/nodext/bin/nodext my_config_file.json

If you have the [Heroku toolbelt](https://toolbelt.heroku.com/) installed, you can try this with:

    $ foreman start -f examples/helloworld/Procfile

and then making a request to <http://localhost:5000/foo/hello/World>.

See [getting started with Node.js on Heroku](https://devcenter.heroku.com/articles/nodejs) for more information.

#### Extensions from NPM packages

[NPM](http://npmjs.org/) packages may also contain extensions. For example, to use the [nodext-create](https://github.com/bergie/nodext-create) extension, install it with:

    $ npm install nodext-create

And then enable in your configuration with:

    "/create/": {
      "name": "create",
      "location": "./node_modules/nodext-create",
      "configuration": {}
    }

If NodeXT takes off, this might be a great way to ship reusable website components like user management, news listings, and others for Node.js web applications.

## Using NodeXT with SSL

NodeXT can be configured to run with HTTPS quite easily. You'll need the necessary certificate files. To generate simple ones for local testing, run:

    $ openssl genrsa -out privatekey.pem 1024 
    $ openssl req -new -key privatekey.pem -out certrequest.csr 
    $ openssl x509 -req -in certrequest.csr -signkey privatekey.pem -out certificate.pem

And then just configure your NodeXT server to use them:

      "server": {
        "hostname": "127.0.0.1",
        "port": 443,
        "privateKey": "privatekey.pem",
        "certificate": "certificate.pem"
      },

## Optional ORM integration

NodeXT has optional integration with the [JugglingDB](https://github.com/1602/jugglingdb#readme) ORM. This allows very easy creation of database-backed Node.js applications.

JugglingDB can persist content in multiple storage back-ends including MySQL, MongoDB and Redis. The JugglingDB connection can be set up in your NodeXT configuration file. Here is an example of using a local Redis service:

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

### Registering models

Any extension can register JugglingDB models in the `getModels` method. For example:

    class MyExtension extends nodext.Extension
      name: "MyExtension"
      config: {}
      models: {}
      schema: {}

      getModels: (@schema, otherModels) ->
        {Schema} = require 'jugglingdb'
        @models.Post = schema.define 'Post',
          title:
            type: String
            length: 255
            index: true
          content:
            type: Schema.Text
          published_at:
            type: Date
        @models

This way the extension itself keeps track of the models it registers, so they can later be used in routes, but at the same time they are registered with NodeXT so that it can centrally handle configuration and storage creation.

### Using models and views

Now the routes will have full JugglingDB access. For example:

      registerRoutes: (server) ->
        # The root route of this component serves a list of
        # posts
        server.get "#{@config.urlPrefix}", (req, res) ->

          # Use the extension's views directory
          server.set 'views', "#{__dirname}/views"

          # Fetch all Post entries and display them
          @models.Post.all (err, posts) ->
            res.render "posts",
              locals:
                items: posts
                as: 'post'

#### Semi-automatic CRUD with Resource-Juggling

[Resource-Juggling](http://search.npmjs.org/#/resource-juggling) is a useful library for generating CRUD routes for JugglingDB models and can also be used with NodeXT. Example:

      registerRoutes: (server) ->    
        resource = require 'express-resource'
        resourceJuggling = require 'resource-juggling'

        posts = server.resource resourceJuggling.getResource
          schema: @schema
          name: 'Post'
          model: @models.Post
          base: @config.urlPrefix

This would create all the necessary routes for Create, Read, Update, and Delete for the model. See [Resource-Juggling documentation](https://github.com/bergie/resource-juggling#readme) for more information.

### Creating storage

With MySQL you need to create the storage tables before using them. With NodeXT you can use the `nodext_storage_create` command (**note** this will drop any existing data in the JugglingDB database):

    $ nodext_storage_create my_config_file.json

Running this command with the other JugglingDB adapters doesn't have any effect.

### Query logging

For debugging purposes it is nice to see the database queries executed by JugglingDB. To enable query logging in NodeXT, add the following to the `database` section of your configuration:

      "logQueries": true

Depending on your database provider, you should see output like:

    SELECT * FROM Post WHERE 1331650495746 

...or:

    KEYS Post:* 1331650628592
