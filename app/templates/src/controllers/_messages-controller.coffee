_               = require 'lodash'
MeshbluHTTP     = require 'meshblu-http'
MessagesService = require '../services/messages-service'

class MessagesController
  constructor: ({@credentialsDeviceService, messageHandlers}) ->
    throw new Error 'messageHandlers are required' unless messageHandlers
    @messageService = new MessagesService {messageHandlers}

  create: (req, res) =>
    @credentialsDeviceService.getEndoByUuid req.meshbluAuth.uuid, (error, endo) =>
      return res.sendError error if error?
      @messageService.send auth: req.meshbluAuth, endo: endo, message: req.body, (error, statusCode, response) =>
        @sendResponse error, req, statusCode, response, (error) =>
          return res.sendError error if error?
          res.sendStatus 201

  sendResponse: (error, req, code, response, callback) =>
    return callback error if error?
    route = req.get 'x-meshblu-route'
    return callback new Error("Missing x-meshblu-route header in request") unless route
    firstHop   = _.first JSON.parse route
    senderUuid     = firstHop.from
    userDeviceUuid = firstHop.to

    message =
      devices: [senderUuid]
      metadata:
        code: code
      data:
        response

    meshblu = new MeshbluHTTP req.meshbluAuth
    meshblu.message message, as: userDeviceUuid, callback


module.exports = MessagesController
