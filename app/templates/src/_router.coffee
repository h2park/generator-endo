MeshbluAuth = require 'express-meshblu-auth'
passport    = require 'passport'
CredentialsDeviceController = require './controllers/credentials-device-controller'
UserDevicesController = require './controllers/user-devices-controller'
OctobluAuthController = require './controllers/octoblu-auth-controller'

class Router
  constructor: ({@credentialsDeviceService, @meshbluConfig}) ->
    @credentialsDeviceController = new CredentialsDeviceController {@credentialsDeviceService}
    @userDevicesController = new UserDevicesController {@credentialsDeviceService}
    @octobluAuthController = new OctobluAuthController

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

module.exports = Router
