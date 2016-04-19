<%= controllerClass %> = require './controllers/<%= filePrefix %>-controller'

class Router
  constructor: ({@<%= serviceInstance %>}) ->
  route: (app) =>
    <%= controllerInstance %> = new <%= controllerClass %> {@<%= serviceInstance %>}

    app.get '/hello', <%= controllerInstance %>.hello
    # e.g. app.put '/resource/:id', someController.update

module.exports = Router
