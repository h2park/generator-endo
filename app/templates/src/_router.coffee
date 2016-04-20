MeshbluAuth = require 'express-meshblu-auth'
passport    = require 'passport'
<%= classPrefix %>Controller = require './controllers/<%= filePrefix %>-controller'
OctobluAuthController = require './controllers/octoblu-auth-controller'

class Router
  constructor: ({@meshbluConfig}) ->
    @<%= instancePrefix %>Controller = new <%= classPrefix %>Controller
    @octobluAuthController = new OctobluAuthController

  route: (app) =>
    meshbluAuth = new MeshbluAuth @meshbluConfig

    app.get '/auth/octoblu', passport.authenticate('octoblu')
    app.get '/auth/octoblu/callback', passport.authenticate('octoblu', failureRedirect: '/auth/octoblu'), @octobluAuthController.storeAuthAndRedirect

    app.use meshbluAuth.retrieve()
    app.use meshbluAuth.gatewayRedirect('/auth/octoblu')

    app.get '/', (req, res) => res.send user: req.user, meshbluAuth: req.meshbluAuth
    app.get '/auth/<%= instancePrefix %>', passport.authenticate('<%= instancePrefix %>')
    app.get '/auth/<%= instancePrefix %>/callback', passport.authenticate('<%= instancePrefix %>', successRedirect: '/')


module.exports = Router
