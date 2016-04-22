fs          = require 'fs'
_           = require 'lodash'
MeshbluHTTP = require 'meshblu-http'
Encryption  = require 'meshblu-encryption'
path        = require 'path'

userDeviceConfigGenerator = require '../user-device-config-generator'

class CredentialsDevice
  constructor: (meshbluConfig) ->
    {@uuid, @privateKey} = meshbluConfig
    @meshblu = new MeshbluHTTP meshbluConfig

  createUserDevice: ({authorizedUuid}, callback) =>
    userDeviceConfig = userDeviceConfigGenerator authorizedUuid: authorizedUuid, credentialsUuid: @uuid

    @meshblu.register userDeviceConfig, (error, userDevice) =>
      return callback error if error?

      subscription = {subscriberUuid: @uuid, emitterUuid: userDevice.uuid, type: 'message.received'}
      @meshblu.createSubscription subscription, (error) =>
        return callback error if error?
        return callback null, userDevice

  getUserDevices: (callback) =>
    @meshblu.subscriptions @uuid, (error, subscriptions) =>
      return callback error if error?
      return callback null, @_userDevicesFromSubscriptions subscriptions

  getUuid: => @uuid

  update: ({authorizedUuid, clientSecret}, callback) =>
    encryption = Encryption.fromJustGuess @privateKey
    update =
      $set:
        'endo.authorizedUuid': authorizedUuid
        'endo.clientSecret'  : encryption.encryptOptions clientSecret

    @meshblu.updateDangerously @uuid, update, (error) =>
      return callback error if error?
      subscription = {subscriberUuid: @uuid, emitterUuid: @uuid, type: 'message.received'}
      @meshblu.createSubscription subscription, (error) =>
        return callback error if error?
        return callback()

  _userDevicesFromSubscriptions: (subscriptions) =>
    _(subscriptions)
      .filter type: 'message.received'
      .map ({emitterUuid}) => {uuid: emitterUuid}
      .value()

module.exports = CredentialsDevice
