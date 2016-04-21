class CredentialsDeviceController
  constructor: ({@credentialsDeviceService}) ->

  upsert: (req, res) =>
    {clientID, clientSecret} = req.user
    authorizedUuid = req.meshbluAuth.uuid

    @credentialsDeviceService.findOrCreate clientID, (error, credentialsDevice) =>
      return res.sendError error if error?
      
      credentialsDevice.update {clientSecret, authorizedUuid}, (error) =>
        return res.sendError error if error?

        @credentialsDeviceService.meshblu.device credentialsDevice.uuid, (error, credentialsDevice) =>
          return res.sendError error if error?
          return res.send credentialsDevice


module.exports = CredentialsDeviceController
