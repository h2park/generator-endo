_            = require 'lodash'
fs           = require 'fs'
http         = require 'http'
request      = require 'request'
shmock       = require '@octoblu/shmock'
MockStrategy = require '../mock-strategy'
Server       = require '../../src/server'
Encryption  = require 'meshblu-encryption'

describe 'messages', ->
  beforeEach (done) ->
    @privateKey = fs.readFileSync "#{__dirname}/../data/private-key.pem", 'utf8'
    @encryption = Encryption.fromPem @privateKey

    @meshblu = shmock 0xd00d
    @apiStrategy = new MockStrategy name: '<%= instancePrefix %>'
    @messageHandlers = hello: sinon.stub()

    serverOptions =
      logFn: ->
      port: undefined,
      disableLogging: true
      octobluOauthOptions:
        clientID: 'client-id'
        clientSecret: '12345'
        authorizationURL: 'http://oauth.octoblu.xxx/authorize'
        tokenURL: "http://localhost:#{0xcafe}/access_token"
        passReqToCallback: true
        meshbluConfig:
          server: 'localhost'
          port: 0xd00d
      apiStrategy: @apiStrategy
      messageHandlers: @messageHandlers
      serviceUrl: 'http://octoblu.xxx'
      meshbluConfig:
        server: 'localhost'
        port: 0xd00d
        uuid: 'peter'
        token: 'i-could-eat'
        privateKey: @privateKey

    @server = new Server serverOptions

    @server.run (error) =>
      return done error if error?
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

  describe 'On POST /messages', ->
    describe 'when authorized', ->
      beforeEach ->
        userAuth = new Buffer('some-uuid:some-token').toString 'base64'
        serviceAuth = new Buffer('peter:i-could-eat').toString 'base64'
        credentialsDeviceAuth = new Buffer('cred-uuid:cred-token').toString 'base64'
        @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{credentialsDeviceAuth}"
          .reply 200,
            uuid: 'cred-uuid'
            endo:
              clientSecret: @encryption.encryptOptions 'decryptedClientSecret'

        @meshblu
          .get '/v2/devices/cred-uuid'
          .set 'Authorization', "Basic #{serviceAuth}"
          .reply 200,
            uuid: 'cred-uuid'
            endo:
              clientSecret: @encryption.encryptOptions 'decryptedClientSecret'

      describe 'when called with a message without metadata', ->
        beforeEach (done) ->
          options =
            baseUrl: "http://localhost:#{@serverPort}"
            json:
              data:
                greeting: 'hola'
            auth:
              username: 'cred-uuid'
              password: 'cred-token'

          request.post '/messages', options, (error, @response, @body) =>
            done error

        it 'should return a 422', ->
          expect(@response.statusCode).to.equal 422

      describe 'when called with valid metadata, but an invalid jobType', ->
        beforeEach (done) ->
          options =
            baseUrl: "http://localhost:#{@serverPort}"
            json:
              metadata:
                jobType: 'goodbye'
            auth:
              username: 'cred-uuid'
              password: 'cred-token'

          request.post '/messages', options, (error, @response, @body) =>
            done error

        it 'should return a 422', ->
          expect(@response.statusCode).to.equal 422

      describe 'when called with valid metadata, valid jobType, but invalid data', ->
        beforeEach (done) ->
          options =
            baseUrl: "http://localhost:#{@serverPort}"
            auth:
              username: 'cred-uuid'
              password: 'cred-token'
            json:
              metadata:
                jobType: 'hello'
              data:
                greeting: {
                  salutation: 'hail fellow well met'
                }

          request.post '/messages', options, (error, @response, @body) =>
            done error

        it 'should return a 422', ->
          expect(@response.statusCode).to.equal 422

      describe 'when called with a valid message', ->
        beforeEach (done) ->
          options =
            baseUrl: "http://localhost:#{@serverPort}"
            json:
              metadata:
                jobType: 'hello'
              data:
                greeting: 'hola'
            auth:
              username: 'cred-uuid'
              password: 'cred-token'

          request.post '/messages', options, (error, @response, @body) =>
            done error

        it 'should return a 201', ->
          expect(@response.statusCode).to.equal 201

        it 'should call the hello messageHandler with the message and auth', ->
          expect(@messageHandlers.hello).to.have.been.calledWith sinon.match {
            auth:
              uuid: 'cred-uuid'
              token: 'cred-token'
            data:
              greeting: 'hola'
            endo:
              clientSecret: 'decryptedClientSecret'
          }

      describe 'when called with a valid message, but the handler does not implement the method', ->
        beforeEach (done) ->
          options =
            baseUrl: "http://localhost:#{@serverPort}"
            json:
              metadata:
                jobType: 'namaste'
              data:
                greeting: 'hola'
            auth:
              username: 'cred-uuid'
              password: 'cred-token'

          request.post '/messages', options, (error, @response, @body) =>
            done error

        it 'should return a 501', ->
          expect(@response.statusCode).to.equal 501
