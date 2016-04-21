_             = require 'lodash'
MeshbluConfig = require 'meshblu-config'
Server        = require './src/server'
ApiStrategy   = require 'passport-<%= instancePrefix %>'

class Command
  getOptions: =>
    @panic new Error('Missing required environment variable: ENDO_<%= constantPrefix %>_OCTOBLU_CLIENT_ID') if _.isEmpty process.env.ENDO_<%= constantPrefix %>_OCTOBLU_CLIENT_ID
    @panic new Error('Missing required environment variable: ENDO_<%= constantPrefix %>_OCTOBLU_CLIENT_SECRET') if _.isEmpty process.env.ENDO_<%= constantPrefix %>_OCTOBLU_CLIENT_SECRET
    @panic new Error('Missing required environment variable: ENDO_<%= constantPrefix %>_OCTOBLU_OAUTH_URL') if _.isEmpty process.env.ENDO_<%= constantPrefix %>_OCTOBLU_OAUTH_URL
    @panic new Error('Missing required environment variable: ENDO_<%= constantPrefix %>_OCTOBLU_CONSUMER_KEY') if _.isEmpty process.env.ENDO_<%= constantPrefix %>_TWITTER_CONSUMER_KEY
    @panic new Error('Missing required environment variable: ENDO_<%= constantPrefix %>_OCTOBLU_CONSUMER_SECRET') if _.isEmpty process.env.ENDO_<%= constantPrefix %>_TWITTER_CONSUMER_SECRET

    apiStrategy = new ApiStrategy {
      consumerKey: process.env.ENDO_<%= constantPrefix %>_TWITTER_CONSUMER_KEY
      consumerSecret: process.env.ENDO_<%= constantPrefix %>_TWITTER_CONSUMER_SECRET
    }, (token, tokenSecret, profile, next) =>
      next null, {token, tokenSecret, clientID: profile.id}

    return {
      port:           process.env.PORT || 80
      disableLogging: process.env.DISABLE_LOGGING == "true"
      meshbluConfig:  new MeshbluConfig().toJSON()
      apiStrategy:    apiStrategy
      octobluOauthOptions:
        clientID:         process.env.ENDO_<%= constantPrefix %>_OCTOBLU_CLIENT_ID
        clientSecret:     process.env.ENDO_<%= constantPrefix %>_OCTOBLU_CLIENT_SECRET
        authorizationURL: "#{process.env.ENDO_<%= constantPrefix %>_OCTOBLU_OAUTH_URL}/authorize"
        tokenURL:         "#{process.env.ENDO_<%= constantPrefix %>_OCTOBLU_OAUTH_URL}/access_token"
        passReqToCallback: true
        meshbluConfig:  new MeshbluConfig().toJSON()
    }

  panic: (error) =>
    console.error error.stack
    process.exit 1

  run: =>
    server = new Server @getOptions()
    server.run (error) =>
      return @panic error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

command = new Command()
command.run()
