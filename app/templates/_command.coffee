_               = require 'lodash'
MeshbluConfig   = require 'meshblu-config'
path            = require 'path'
Endo            = require 'endo-core'
OctobluStrategy = require 'endo-core/octoblu-strategy'
ApiStrategy     = require './src/api-strategy'
MessageHandler  = require './src/message-handler'

MISSING_SERVICE_URL = 'Missing required environment variable: ENDO_<%= constantPrefix %>_SERVICE_URL'
MISSING_MANAGER_URL = 'Missing required environment variable: ENDO_<%= constantPrefix %>_MANAGER_URL'

class Command
  getOptions: =>
    throw new Error MISSING_SERVICE_URL if _.isEmpty process.env.ENDO_<%= constantPrefix %>_SERVICE_URL
    throw new Error MISSING_MANAGER_URL if _.isEmpty process.env.ENDO_<%= constantPrefix %>_MANAGER_URL

    meshbluConfig   = new MeshbluConfig().toJSON()
    apiStrategy     = new ApiStrategy process.env
    octobluStrategy = new OctobluStrategy process.env, meshbluConfig

    return {
      apiStrategy:     apiStrategy
      deviceType:      '<%= appname %>'
      disableLogging:  process.env.DISABLE_LOGGING == "true"
      meshbluConfig:   meshbluConfig
      messageHandler:  new MessageHandler
      octobluStrategy: octobluStrategy
      port:            process.env.PORT || 80
      serviceUrl:      process.env.ENDO_<%= constantPrefix %>_SERVICE_URL
      userDeviceManagerUrl: process.env.ENDO_<%= constantPrefix %>_MANAGER_URL
    }

  run: =>
    server = new Endo @getOptions()
    server.run (error) =>
      throw error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

command = new Command()
command.run()
