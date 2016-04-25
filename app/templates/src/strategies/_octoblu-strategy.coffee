_               = require 'lodash'
MeshbluConfig   = require 'meshblu-config'
PassportOctoblu = require 'passport-octoblu'

class OctobluStrategy extends PassportOctoblu
  constructor: (env) ->
    throw new Error('Missing required environment variable: ENDO_<%= constantPrefix %>_OCTOBLU_CLIENT_ID')     if _.isEmpty process.env.ENDO_<%= constantPrefix %>_OCTOBLU_CLIENT_ID
    throw new Error('Missing required environment variable: ENDO_<%= constantPrefix %>_OCTOBLU_CLIENT_SECRET') if _.isEmpty process.env.ENDO_<%= constantPrefix %>_OCTOBLU_CLIENT_SECRET
    throw new Error('Missing required environment variable: ENDO_<%= constantPrefix %>_OCTOBLU_OAUTH_URL')     if _.isEmpty process.env.ENDO_<%= constantPrefix %>_OCTOBLU_OAUTH_URL

    options = {
      clientID:         process.env.ENDO_<%= constantPrefix %>_OCTOBLU_CLIENT_ID
      clientSecret:     process.env.ENDO_<%= constantPrefix %>_OCTOBLU_CLIENT_SECRET
      authorizationURL: "#{process.env.ENDO_<%= constantPrefix %>_OCTOBLU_OAUTH_URL}/authorize"
      tokenURL:         "#{process.env.ENDO_<%= constantPrefix %>_OCTOBLU_OAUTH_URL}/access_token"
      meshbluConfig:    new MeshbluConfig().toJSON()
    }

    super options, (bearerToken, secret, {uuid}, next) =>
      next null, {uuid, bearerToken}

module.exports = OctobluStrategy
