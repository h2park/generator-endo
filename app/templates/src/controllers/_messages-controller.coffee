MessagesService     = require '../services/messages-service'

class MessagesController
  constructor: ->
    @messageService = new MessagesService

  create: (req, res) =>
    @messageService.send auth: req.meshbluAuth, message: req.body, (error) =>
      return res.sendError error if error?
      res.sendStatus 201

module.exports = MessagesController
