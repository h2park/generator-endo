class <%= classPrefix %>Controller
  constructor: () ->

  authenticated: (request, response) =>
    request.sendStatus 204

module.exports = <%= classPrefix %>Controller
