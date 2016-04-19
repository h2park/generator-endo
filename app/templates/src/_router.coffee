passport = require 'passport'
<%= classPrefix %>Controller = require './controllers/<%= filePrefix %>-controller'

class Router
  constructor: () ->
    @<%= instancePrefix %>Controller = new <%= classPrefix %>Controller

  route: (app) =>
    app.get '/auth', passport.authenticate('<%= instancePrefix %>')

    app.get '/auth/callback',
      passport.authenticate('<%= instancePrefix %>', failureRedirect: '/login'),
      @<%= instancePrefix %>Controller.authenticated

module.exports = Router
