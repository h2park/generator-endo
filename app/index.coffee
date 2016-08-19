path       = require 'path'
htmlWiring = require 'html-wiring'
yeoman     = require 'yeoman-generator'
_          = require 'lodash'
helpers    = require './helpers'

class OctobluServiceGenerator extends yeoman.Base
  constructor: (args, options) ->
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
    deviceType     = "endo:#{instancePrefix}"

    context = {
      @githubUrl
      @realname
      @appname
      deviceType
      filePrefix
      classPrefix
      instancePrefix
      constantPrefix
    }
    @template "_package.json", "package.json", context
    @template "src/_api-strategy.coffee", "src/api-strategy.coffee", context
    @template "src/jobs/list-events-by-user/_action.coffee", "src/jobs/list-events-by-user/action.coffee", context
    @template "src/jobs/list-events-by-user/_form.cson", "src/jobs/list-events-by-user/form.cson", context
    @template "src/jobs/list-events-by-user/_index.coffee", "src/jobs/list-events-by-user/index.coffee", context
    @template "src/jobs/list-events-by-user/_job.coffee", "src/jobs/list-events-by-user/job.coffee", context
    @template "src/jobs/list-events-by-user/_message.cson", "src/jobs/list-events-by-user/message.cson", context
    @template "src/jobs/list-events-by-user/_response.cson", "src/jobs/list-events-by-user/response.cson", context
    @template "test/_mocha.opts", "test/mocha.opts", context
    @template "test/_test_helper.coffee", "test/test_helper.coffee", context
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
