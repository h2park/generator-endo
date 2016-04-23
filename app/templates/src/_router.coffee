MeshbluAuth = require 'express-meshblu-auth'
passport    = require 'passport'
CredentialsDeviceController = require './controllers/credentials-device-controller'
MessagesController = require './controllers/messages-controller'
OctobluAuthController = require './controllers/octoblu-auth-controller'
UserDevicesController = require './controllers/user-devices-controller'

class Router
  constructor: ({@credentialsDeviceService, @meshbluConfig, @messageHandlers}) ->
    throw new Error 'credentialsDeviceService is required' unless @credentialsDeviceService?
    throw new Error 'meshbluConfig is required' unless @meshbluConfig?
    throw new Error 'messageHandlers are required' unless @messageHandlers?

    @credentialsDeviceController = new CredentialsDeviceController {@credentialsDeviceService}
    @messagesController    = new MessagesController {@credentialsDeviceService, @messageHandlers}
    @octobluAuthController = new OctobluAuthController
    @userDevicesController = new UserDevicesController {@credentialsDeviceService}

  route: (app) =>
    meshbluAuth = new MeshbluAuth @meshbluConfig

    app.get '/auth/octoblu', passport.authenticate('octoblu')
    app.get '/auth/octoblu/callback', passport.authenticate('octoblu', failureRedirect: '/auth/octoblu'), @octobluAuthController.storeAuthAndRedirect

    app.use meshbluAuth.retrieve()
    app.use meshbluAuth.gatewayRedirect('/auth/octoblu')

    app.get '/', (req, res) => res.send user: req.user, meshbluAuth: req.meshbluAuth
    app.get '/auth/<%= instancePrefix %>', passport.authenticate('<%= instancePrefix %>')
    app.get '/auth/<%= instancePrefix %>/callback', passport.authenticate('<%= instancePrefix %>'), @credentialsDeviceController.upsert
    app.get '/:credentialsDeviceUuid/user-devices', @userDevicesController.list
    app.post '/:credentialsDeviceUuid/user-devices', @userDevicesController.create

    app.post '/messages', @messagesController.create

module.exports = Router
