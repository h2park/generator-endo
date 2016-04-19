path    = require 'path'
helpers = require 'yeoman-test'
assert  = require 'yeoman-assert'

GENERATOR_NAME = 'app'
DEST = path.join __dirname, '..', 'temp', "endo-github"

xdescribe 'package.json', ->
  describe 'when the passport name is left blank', ->
    before 'running the generator', (done) ->
      helpers
        .run path.join __dirname, '..', 'app'
        .inDir DEST
        .withOptions
          realname: 'Alex Gorbatchev'
          githubUrl: 'https://github.com/alexgorbatchev'
        .withPrompts {}
        .on 'end', done

    it 'adds passport-github to the package.json', ->
      assert.fileContent 'package.json', 'passport-github'
