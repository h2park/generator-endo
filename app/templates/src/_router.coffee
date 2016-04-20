MeshbluAuth = require 'express-meshblu-auth'
passport    = require 'passport'
<%= classPrefix %>Controller = require './controllers/<%= filePrefix %>-controller'

class Router
  constructor: ({@meshbluConfig}) ->
    @<%= instancePrefix %>Controller = new <%= classPrefix %>Controller

  route: (app) =>
    meshbluAuth = new MeshbluAuth @meshbluConfig

    app.get '/', (req, res) => res.redirect '/auth/octoblu'
    app.get '/auth/octoblu', passport.authenticate('octoblu')
    app.get '/auth/octoblu/callback', passport.authenticate('octoblu', failureRedirect: '/auth/octoblu', successRedirect: '/auth/twitter')

    # app.use meshbluAuth.retrieve()
    # app.use meshbluAuth.gatewayRedirect('/auth/octoblu')
    #
    # app.get '/auth/<%= instancePrefix %>', passport.authenticate('<%= instancePrefix %>')
    # app.get '/auth/<%= instancePrefix %>/callback', passport.authenticate('<%= instancePrefix %>', failureRedirect: '/login'), @<%= instancePrefix %>Controller.authenticated

module.exports = Router
