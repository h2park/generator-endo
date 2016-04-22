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
      src/user-device-config-generator.coffee
      src/server.coffee
      src/router.coffee
      src/controllers/app-controller.coffee
      src/controllers/octoblu-auth-controller.coffee
      src/controllers/credentials-device-controller.coffee
      src/controllers/user-devices-controller.coffee
      src/services/credentials-device-service.coffee
      test/integration/app-spec.coffee
      test/integration/user-devices-spec.coffee
      test/data/private-key.pem
      test/mock-strategy.coffee
      test/test_helper.coffee
      test/mocha.opts
      index.js
      command.js
      command.coffee
      coffeelint.json
      .gitignore
      .travis.yml
      LICENSE
      README.md
      package.json
    '''.split /\s+/g
