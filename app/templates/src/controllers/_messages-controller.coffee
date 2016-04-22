MessagesService     = require '../services/messages-service'

class MessagesController
  constructor: ({messageHandlers}) ->
    throw new Error 'messageHandlers are required' unless messageHandlers
    @messageService = new MessagesService {messageHandlers}

  create: (req, res) =>
    @messageService.send auth: req.meshbluAuth, message: req.body, (error) =>
      return res.sendError error if error?
      res.sendStatus 201

module.exports = MessagesController
