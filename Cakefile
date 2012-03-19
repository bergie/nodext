{exec} = require 'child_process'

exerr = (err, sout, serr) ->
  console.log err if err
  console.log sout if sout
  console.log serr if serr

task 'apidoc', 'generate API documentation', ->
  exec "./node_modules/coffeedoc/bin/coffeedoc -o api lib", exerr
