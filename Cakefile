{exec} = require 'child_process'
{series} = require 'async'

sh = (command) -> (k) ->
  console.log "Executing #{command}"
  exec command, (err, sout, serr) ->
    console.log err if err
    console.log sout if sout
    console.log serr if serr
    do k

task 'apidoc', 'generate API documentation', ->
  exec "./node_modules/coffeedoc/bin/coffeedoc -o api lib"

task 'doc', 'generate documentation for *.coffee files', ->
  sh("docco-husky lib/*") ->

task 'docpub', 'publish API documentation', ->
  series [
    (sh "./node_modules/coffeedoc/bin/coffeedoc -o api lib")
    (sh "mv api api_tmp")
    (sh "git checkout gh-pages")
    (sh "cp -R api_tmp/* api/")
    (sh "git add api/*")
    (sh "git commit -m 'API docs update'")
    (sh "git checkout master")
  ]
