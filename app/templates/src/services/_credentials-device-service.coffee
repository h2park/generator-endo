_ = require 'lodash'
MeshbluHTTP = require 'meshblu-http'
CredentialsDevice = require '../models/credentials-device'

class CredentialsDeviceService
  constructor: ({@meshbluConfig}) ->
    @uuid = @meshbluConfig.uuid
    @meshblu = new MeshbluHTTP @meshbluConfig

  findOrCreate: (clientID, callback) =>
    @_findOrCreate clientID, (error, device) =>
      return callback error if error?
      @_getCredentialsDevice device, callback

  _findOrCreate: (clientID, callback) =>
    return callback new Error('clientID is required') unless clientID?
    @meshblu.search 'endo.clientID': clientID, {}, (error, devices) =>
      return callback error if error?
      return callback null, _.first devices unless _.isEmpty devices
      @meshblu.register @newRecord(clientID), callback

  _getCredentialsDevice: ({uuid}, callback) =>
    @meshblu.generateAndStoreToken uuid, (error, {token}={}) =>
      return callback error if error?
      return callback null, new CredentialsDevice _.defaults({uuid, token}, @meshbluConfig)

  newRecord: (clientID) =>
    return {
      endo:
        clientID: clientID
      meshblu:
        version: '2.0.0'
        whitelists:
          discover:
            view: [{ uuid: @uuid}]
          configure:
            update: [{ uuid: @uuid}]
    }

module.exports = CredentialsDeviceService
