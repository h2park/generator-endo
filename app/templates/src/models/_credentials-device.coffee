MeshbluHTTP = require 'meshblu-http'
Encryption  = require 'meshblu-encryption'

class CredentialsDevice
  constructor: (meshbluConfig) ->
    {@uuid} = meshbluConfig
    @meshblu = new MeshbluHTTP meshbluConfig
    @encryption = Encryption.fromJustGuess meshbluConfig.privateKey

  update: ({authorizedUuid, clientSecret}, callback) =>
    update =
      $set:
        'endo.authorizedUuid': authorizedUuid
        'endo.clientSecret'  : @encryption.encryptOptions clientSecret

    @meshblu.updateDangerously @uuid, update, callback


module.exports = CredentialsDevice
