MeshbluHTTP = require 'meshblu-http'

class CredentialsDeviceController
  constructor: ({@credentialsDeviceService}) ->

  upsert: (req, res) =>
    @credentialsDeviceService.findOrCreate req.user.clientID, (error, credentialsDevice) =>
      return res.sendError error if error?
      res.send credentialsDevice


module.exports = CredentialsDeviceController
