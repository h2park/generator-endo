util       = require 'util'
path       = require 'path'
url        = require 'url'
GitHubApi  = require 'github'
htmlWiring = require 'html-wiring'
yeoman     = require 'yeoman-generator'
_          = require 'lodash'

class OctobluServiceGenerator extends yeoman.Base
  constructor: (args, options, config) ->
    super
    @currentYear = (new Date()).getFullYear()
    {@realname, @githubUrl} = options
    @on 'end', => @installDependencies skipInstall: options['skip-install']
    @pkg = JSON.parse htmlWiring.readFileAsString path.join __dirname, '../package.json'

  prompting: ->
    # have Yeoman greet the user.

    done = @async()
    generatorName = @extractGeneratorName @appname

    prompts = [
      name: 'githubUser'
      message: 'Would you mind telling me your username on GitHub?'
      default: 'someuser'
    ,
      name: 'generatorName'
      message: "What's the base name of your generator?"
      default: generatorName
    ]

    @prompt prompts, (props) =>
      @githubUser = props.githubUser
      @generatorName = props.generatorName
      done()

  extractGeneratorName: (appName) =>
    _.kebabCase appName

  userInfo: =>
    return if @realname? and @githubUrl?

    done = @async()

    @githubUserInfo @githubUser, (err, res) =>
      @realname = res.name
      @email = res.email
      @githubUrl = res.html_url
      done()

  projectfiles: ->
    appName = _.kebabCase @generatorName
    generatorNameWithoutService = _.trimEnd @generatorName, '-service'
    filePrefix = _.kebabCase generatorNameWithoutService
    instancePrefix = _.camelCase generatorNameWithoutService
    classPrefix = _.upperFirst instancePrefix

    serviceClass    = "#{classPrefix}Service"
    serviceInstance = "#{instancePrefix}Service"

    controllerClass = "#{classPrefix}Controller"
    controllerInstance = "#{instancePrefix}Controller"

    context = {
      @githubUrl
      @realname
      filePrefix
      serviceClass
      serviceInstance
      controllerClass
      controllerInstance
      appName
    }
    @template "_package.json", "package.json", context
    @template "src/_server.coffee", "src/server.coffee", context
    @template "src/_router.coffee", "src/router.coffee", context
    @template "src/services/_service.coffee", "src/services/#{filePrefix}-service.coffee", context
    @template "src/controllers/_controller.coffee", "src/controllers/#{filePrefix}-controller.coffee", context
    @template "test/_mocha.opts", "test/mocha.opts", context
    @template "test/_test_helper.coffee", "test/test_helper.coffee", context
    @template "test/integration/_sample-integration-spec.coffee", "test/integration/#{filePrefix}-integration-spec.coffee", context
    @template "test/integration/_hello-spec.coffee", "test/integration/#{filePrefix}-hello-spec.coffee", context
    @template "_index.js", "index.js", context
    @template "_command.js", "command.js", context
    @template "_command.coffee", "command.coffee", context
    @template "_travis.yml", ".travis.yml", context
    @template "_Dockerfile", "Dockerfile", context
    @template "_dockerignore", ".dockerignore", context
    @template "README.md", "README.md", context
    @template "LICENSE", "LICENSE", context

  gitfiles: ->
    @copy '_gitignore', '.gitignore'

  app: ->

  templates: ->

  tests: ->

  githubUserInfo: (name, callback) =>
    github = new GitHubApi version: '3.0.0'
    github.user.getFrom user: name, callback

module.exports = OctobluServiceGenerator
