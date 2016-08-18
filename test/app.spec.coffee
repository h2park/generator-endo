{before, describe, it} = global

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
      src/api-strategy.coffee
      src/jobs/list-events-by-user/action.coffee
      src/jobs/list-events-by-user/form.cson
      src/jobs/list-events-by-user/index.coffee
      src/jobs/list-events-by-user/job.coffee
      src/jobs/list-events-by-user/message.cson
      src/jobs/list-events-by-user/response.cson
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
