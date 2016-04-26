_               = require 'lodash'
MeshbluConfig   = require 'meshblu-config'
Endo            = require 'endo-lib'
OctobluStrategy = require 'endo-lib/octoblu-strategy'
ApiStrategy     = require './src/strategies/api-strategy'
MessageHandlers = require './src/message-handlers'

class Command
  getOptions: =>
    throw new Error('Missing required environment variable: ENDO_<%= constantPrefix %>_SERVICE_URL') if _.isEmpty process.env.ENDO_<%= constantPrefix %>_SERVICE_URL

    meshbluConfig   = new MeshbluConfig().toJSON()
    apiStrategy     = new ApiStrategy process.env
    octobluStrategy = new octobluStrategy process.env, meshbluConfig

    return {
      deviceType:      '<%= appname %>'
      port:            process.env.PORT || 80
      disableLogging:  process.env.DISABLE_LOGGING == "true"
      meshbluConfig:   meshbluConfig
      apiStrategy:     apiStrategy
      octobluStrategy: octobluStrategy
      serviceUrl:      process.env.ENDO_<%= constantPrefix %>_SERVICE_URL
      messageHandlers: new MessageHandlers
    }

  run: =>
    server = new Endo @getOptions()
    server.run (error) =>
      throw error if error?

      {address,port} = server.address()
      console.log "Server listening on #{address}:#{port}"

command = new Command()
command.run()
