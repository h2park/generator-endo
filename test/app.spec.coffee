path = require 'path'
helpers = require('yeoman-test')
assert = require('yeoman-assert')

GENERATOR_NAME = 'app'
DEST = path.join __dirname, '..', 'temp', "endo-#{GENERATOR_NAME}"

describe 'app', ->
  before 'run the helper', (done) ->
    helpers
      .run path.join __dirname, '..', 'app'
      .inDir DEST
      .withOptions
        realname: 'Alex Gorbatchev'
        githubUrl: 'https://github.com/alexgorbatchev'
      .withPrompts
        githubUser: 'alexgorbatchev'
        generatorName: GENERATOR_NAME
        passportName: 'passport-app'
      .on 'end', done

  it 'creates expected files', ->
    assert.file '''
      Dockerfile
      src/message-handler.coffee
      src/schema-loader.coffee
      src/api-strategy.coffee
      src/jobs/get-user-events/action.coffee
      src/jobs/get-user-events/form.cson
      src/jobs/get-user-events/index.coffee
      src/jobs/get-user-events/job.coffee
      src/jobs/get-user-events/message.cson
      src/jobs/get-user-events/response.cson
      test/test_helper.coffee
      test/mocha.opts
      command.js
      command.coffee
      coffeelint.json
      .gitignore
      .travis.yml
      LICENSE
      README.md
      package.json
    '''.split /\s+/g
