util       = require 'util'
path       = require 'path'
url        = require 'url'
htmlWiring = require 'html-wiring'
yeoman     = require 'yeoman-generator'
_          = require 'lodash'
helpers    = require './helpers'

class OctobluServiceGenerator extends yeoman.Base
  constructor: (args, options, config) ->
    super
    @option 'github-user'
    @currentYear = (new Date()).getFullYear()
    {@realname, @githubUrl} = options
    @skipInstall = options['skip-install']
    @githubUser  = options['github-user']
    @pkg = JSON.parse htmlWiring.readFileAsString path.join __dirname, '../package.json'

  initializing: =>
    @appname = _.kebabCase @appname
    @noEndo = _.replace @appname, /^endo-/, ''
    @env.error 'appname must start with "endo-", exiting.' unless _.startsWith @appname, 'endo-'

  prompting: =>
    return if @githubUser?

    done = @async()

    prompts = [
      name: 'githubUser'
      message: 'Would you mind telling me your username on GitHub?'
      default: 'octoblu'
    ]

    @prompt prompts, (props) =>
      @githubUser = props.githubUser
      done()

  userInfo: =>
    return if @realname? and @githubUrl?

    done = @async()

    helpers.githubUserInfo @githubUser, (error, res) =>
      @env.error error if error?
      @realname = res.name
      @email = res.email
      @githubUrl = res.html_url
      done()

  configuring: =>
    @copy '_gitignore', '.gitignore'

  writing: =>
    filePrefix     = _.kebabCase @noEndo
    instancePrefix = _.camelCase @noEndo
    classPrefix    = _.upperFirst instancePrefix
    constantPrefix = _.toUpper _.snakeCase @noEndo

    context = {
      @githubUrl
      @realname
      @appname
      filePrefix
      classPrefix
      instancePrefix
      constantPrefix
    }
    @template "_package.json", "package.json", context
    @template "_endo-message-schema.json", "endo-message-schema.json", context
    @template "schemas/_hello-schema.json", "schemas/hello-schema.json", context
    @template "schemas/_namaste-schema.json", "schemas/namaste-schema.json", context
    @template "schemas/_userRepos-schema.json", "schemas/userRepos-schema.json", context
    @template "src/_message-handlers.coffee", "src/message-handlers.coffee", context
    @template "src/_router.coffee", "src/router.coffee", context
    @template "src/_server.coffee", "src/server.coffee", context
    @template "src/controllers/_credentials-device-controller.coffee", "src/controllers/credentials-device-controller.coffee", context
    @template "src/controllers/_octoblu-auth-controller.coffee", "src/controllers/octoblu-auth-controller.coffee", context
    @template "src/controllers/_messages-controller.coffee", "src/controllers/messages-controller.coffee", context
    @template "src/controllers/_user-devices-controller.coffee", "src/controllers/user-devices-controller.coffee", context
    @template "src/config-generators/_credentials-device-create-config-generator.coffee", "src/config-generators/credentials-device-create-config-generator.coffee", context
    @template "src/config-generators/_credentials-device-update-config-generator.coffee", "src/config-generators/credentials-device-update-config-generator.coffee", context
    @template "src/config-generators/_user-device-config-generator.coffee", "src/config-generators/user-device-config-generator.coffee", context
    @template "src/models/_credentials-device.coffee", "src/models/credentials-device.coffee", context
    @template "src/services/_credentials-device-service.coffee", "src/services/credentials-device-service.coffee", context
    @template "src/services/_messages-service.coffee", "src/services/messages-service.coffee", context
    @template "src/strategies/_octoblu-strategy.coffee", "src/strategies/octoblu-strategy.coffee", context
    @template "src/strategies/_api-strategy.coffee", "src/strategies/api-strategy.coffee", context
    @template "test/_mocha.opts", "test/mocha.opts", context
    @template "test/_test_helper.coffee", "test/test_helper.coffee", context
    @template "test/_mock-strategy.coffee", "test/mock-strategy.coffee", context
    @template "test/integration/_message-spec.coffee", "test/integration/message-spec.coffee", context
    @template "test/integration/_sample-spec.coffee", "test/integration/#{filePrefix}-spec.coffee", context
    @template "test/integration/_user-devices-spec.coffee", "test/integration/user-devices-spec.coffee", context
    @template "test/data/_private-key.pem", "test/data/private-key.pem", context
    @template "_index.js", "index.js", context
    @template "_command.js", "command.js", context
    @template "_command.coffee", "command.coffee", context
    @template "_coffeelint.json", "coffeelint.json", context
    @template "_travis.yml", ".travis.yml", context
    @template "_Dockerfile", "Dockerfile", context
    @template "_dockerignore", ".dockerignore", context
    @template "README.md", "README.md", context
    @template "LICENSE", "LICENSE", context

  install: =>
    return if @skipInstall

    @installDependencies npm: true, bower: false
    @npmInstall "passport-#{@noEndo}", save: true

  end: =>
    return if @skipInstall
    @log "\nBy the way, I installed 'passport-#{@noEndo}', so if that's not right, you should fix it.\n"

module.exports = OctobluServiceGenerator
