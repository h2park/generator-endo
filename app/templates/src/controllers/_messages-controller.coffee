MessagesService     = require '../services/messages-service'

class MessagesController
  constructor: ({@credentialsDeviceService, messageHandlers}) ->
    throw new Error 'messageHandlers are required' unless messageHandlers
    @messageService = new MessagesService {messageHandlers}

  create: (req, res) =>
    @credentialsDeviceService.getEndoByUuid req.meshbluAuth.uuid, (error, endo) =>
      return res.sendError error if error?
      @messageService.send auth: req.meshbluAuth, endo: endo, message: req.body, (error) =>
        return res.sendError error if error?
        res.sendStatus 201

module.exports = MessagesController
