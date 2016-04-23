_ = require 'lodash'
MeshbluHTTP = require 'meshblu-http'
CredentialsDevice = require '../models/credentials-device'
credentialsDeviceCreateGenerator = require '../config-generators/credentials-device-create-config-generator'

class CredentialsDeviceService
  constructor: ({@meshbluConfig, @serviceUrl}) ->
    @uuid = @meshbluConfig.uuid
    @meshblu = new MeshbluHTTP @meshbluConfig

  authorizedFindByUuid: ({authorizedUuid, credentialsDeviceUuid}, callback) =>
    @meshblu.search {uuid: credentialsDeviceUuid, 'endo.authorizedUuid': authorizedUuid}, {}, (error, devices) =>
      return callback(error) if error?
      return callback @_userError('credentials device not found', 403) if _.isEmpty devices
      return @_getCredentialsDevice {uuid: credentialsDeviceUuid}, callback

  getEndoByUuid: (uuid, callback) =>
    @meshblu.device uuid, (error, {endo}={}) =>
      return callback error if error?
      return callback null, endo

  findOrCreate: (clientID, callback) =>
    @_findOrCreate clientID, (error, device) =>
      return callback error if error?
      @_getCredentialsDevice device, callback

  _findOrCreate: (clientID, callback) =>
    return callback new Error('clientID is required') unless clientID?
    @meshblu.search 'endo.clientID': clientID, {}, (error, devices) =>
      return callback error if error?
      return callback null, _.first devices unless _.isEmpty devices
      record = credentialsDeviceCreateGenerator {clientID: clientID, serviceUuid: @uuid}
      @meshblu.register record, callback

  _getCredentialsDevice: ({uuid}, callback) =>
    @meshblu.generateAndStoreToken uuid, (error, {token}={}) =>
      return callback error if error?
      meshbluConfig = _.defaults {uuid, token}, @meshbluConfig
      return callback null, new CredentialsDevice {meshbluConfig, @serviceUrl}

  _userError: (message, code) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = CredentialsDeviceService
