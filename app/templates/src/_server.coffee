cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
cookieParser       = require 'cookie-parser'
cookieSession      = require 'cookie-session'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
sendError          = require 'express-send-error'
MeshbluConfig      = require 'meshblu-config'
OctobluStrategy    = require 'passport-octoblu'
passport           = require 'passport'
debug              = require('debug')('<%= appname %>:server')
Router             = require './router'
CredentialsDeviceService = require './services/credentials-device-service'

class Server
  constructor: ({@disableLogging, @octobluOauthOptions, @port, @apiStrategy, @serviceUrl, @meshbluConfig})->
    throw new Error('meshbluConfig is required') unless @meshbluConfig?
    throw new Error('octobluOauthOptions are required') unless @octobluOauthOptions?
    throw new Error('apiStrategy is required') unless @apiStrategy?
    throw new Error('serviceUrl is required') unless @serviceUrl?

  address: =>
    @server.address()

  run: (callback) =>
    passport.serializeUser   (user, done) => done null, user
    passport.deserializeUser (user, done) => done null, user
    passport.use new OctobluStrategy @octobluOauthOptions, (req, bearerToken, secret, {uuid,token}, next) =>
      next null, {uuid, bearerToken}

    passport.use '<%= instancePrefix %>', @apiStrategy

    app = express()
    app.use meshbluHealthcheck()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use cookieSession secret: 'here, kitty, kitty'# @meshbluConfig.token
    app.use cookieParser()
    app.use passport.initialize()
    app.use passport.session()
    app.use bodyParser.urlencoded limit: '1mb', extended : true
    app.use bodyParser.json limit : '1mb'
    app.use sendError()
    app.options '*', cors()

    credentialsDeviceService = new CredentialsDeviceService {@meshbluConfig, @serviceUrl}

    router = new Router {credentialsDeviceService, @meshbluConfig}
    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
