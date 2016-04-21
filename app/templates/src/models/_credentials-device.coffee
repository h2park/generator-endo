MeshbluHTTP = require 'meshblu-http'
class CredentialsDevice
  constructor: (meshbluConfig) ->
    console.log meshbluConfig
    {@uuid} = meshbluConfig
    @meshblu = new MeshbluHTTP meshbluConfig

  update: ({authorizedUuid, clientSecret}, callback) =>
    update =
      $set:
        'endo.authorizedUuid': authorizedUuid
        'endo.clientSecret'  : clientSecret
         
    @meshblu.updateDangerously @uuid, update, callback


module.exports = CredentialsDevice
