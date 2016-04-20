cors               = require 'cors'
morgan             = require 'morgan'
express            = require 'express'
bodyParser         = require 'body-parser'
errorHandler       = require 'errorhandler'
meshbluHealthcheck = require 'express-meshblu-healthcheck'
MeshbluConfig      = require 'meshblu-config'
OctobluStrategy    = require 'passport-octoblu'
passport           = require 'passport'
debug              = require('debug')('<%= appname %>:server')
Router             = require './router'

class Server
  constructor: ({@disableLogging, @octobluOauthOptions, @port, @meshbluConfig})->
    throw new Error('meshbluConfig is required') unless @meshbluConfig?
    throw new Error('octobluOauthOptions are required') unless @octobluOauthOptions?

  address: =>
    @server.address()

  run: (callback) =>
    passport.serializeUser   (user, done) => done null, user
    passport.deserializeUser (user, done) => done null, user
    passport.use new OctobluStrategy @octobluOauthOptions, (req, bearerToken, secret, {uuid}, next) =>
      next null, {uuid, bearerToken}

    app = express()
    app.use meshbluHealthcheck()
    app.use morgan 'dev', immediate: false unless @disableLogging
    app.use cors()
    app.use errorHandler()
    app.use passport.initialize()
    app.use passport.session()
    app.use bodyParser.urlencoded limit: '1mb', extended : true
    app.use bodyParser.json limit : '1mb'
    app.options '*', cors()

    router = new Router {@meshbluConfig}
    router.route app

    @server = app.listen @port, callback

  stop: (callback) =>
    @server.close callback

module.exports = Server
