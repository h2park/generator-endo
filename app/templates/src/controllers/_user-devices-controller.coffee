class UserDevicesController
  constructor: ({@credentialsDeviceService}) ->
    throw new Error 'credentialsDeviceService is required' unless @credentialsDeviceService?

  list: (req, res) =>
    {credentialsDeviceUuid} = req.params
    authorizedUuid = req.meshbluAuth.uuid
    @credentialsDeviceService.authorizedFindByUuid {authorizedUuid, credentialsDeviceUuid}, (error, credentialsDevice) =>
      return res.sendError error if error?
      credentialsDevice.getUserDevices (error, userDevices) =>
        return res.sendError error if error?
        res.send userDevices

module.exports = UserDevicesController
