_ = require 'lodash'
MeshbluHTTP = require 'meshblu-http'

class CredentialsDeviceService
  constructor: ({meshbluConfig}) ->
    @uuid = meshbluConfig.uuid
    @meshblu = new MeshbluHTTP meshbluConfig

  findOrCreate: (clientID, callback) =>
    @meshblu.search endo: {clientID}, {}, (error, devices) =>
      return callback error if error?
      return callback null, _.first devices unless _.isEmpty devices
      @meshblu.register @newRecord(clientID), callback

  newRecord: (clientID) =>
    return {
      endo:
        clientID: clientID
      meshblu:
        version: '2.0.0'
        discover:
          view:
            "#{@uuid}": {}
        configure:
          update:
            "#{@uuid}": {}
    }

module.exports = CredentialsDeviceService
