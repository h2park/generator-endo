http    = require 'http'
request = require 'request'
shmock  = require '@octoblu/shmock'
Server  = require '../../src/server'

describe 'Sample Spec', ->
  beforeEach (done) ->
    @meshblu = shmock 0xd00d

    serverOptions =
      port: undefined,
      disableLogging: true
      octobluOauthOptions:
        clientID: '12345'
        clientSecret: '12345'
      meshbluConfig:
        server: 'localhost'
        port: 0xd00d

    @server = new Server serverOptions

    @server.run (error) =>
      return done error if error?
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @meshblu.close done

  describe 'When inauthenticated', ->
    describe 'On GET /', ->
      beforeEach (done) ->
        options =
          baseUrl: "http://localhost:#{@serverPort}"
          followRedirect: false

        request.get '/', options, (error, @response, @body) =>
          done error

      it 'should return a 302', ->
        expect(@response.statusCode).to.equal 302, @body

      it 'should redirect to /auth/octoblu', ->
        expect(@response.headers.location).to.equal '/auth/octoblu'

    describe 'On GET /auth/octoblu', ->
      beforeEach (done) ->
        options =
          baseUrl: "http://localhost:#{@serverPort}"
          followRedirect: false

        request.get '/auth/octoblu', options, (error, @response, @body) =>
          done error

      it 'should redirect to /auth/octoblu', ->
        expect(@response.statusCode).to.equal 302, @body

  xdescribe 'When unauthenticated', ->
    describe 'On GET /', ->
      beforeEach (done) ->
        request.get "http://localhost:#{@serverPort}", followRedirect: false, (error, @response, @body) =>
          done error

      it 'should redirect to /auth/octoblu', ->
        expect(@response.statusCode).to.equal 302, @body


  xdescribe 'On GET /auth/twitter', ->
    beforeEach (done) ->
      userAuth = new Buffer('some-uuid:some-token').toString 'base64'

      @authDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{userAuth}"
        .reply 200, uuid: 'some-uuid', token: 'some-token'

      options =
        uri: '/hello'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          username: 'some-uuid'
          password: 'some-token'
        json: true

      request.get options, (error, @response, @body) =>
        done error

    it 'should auth handler', ->
      @authDevice.done()

    it 'should return a 200', ->
      expect(@response.statusCode).to.equal 200

  xdescribe 'when the service yields an error', ->
    beforeEach (done) ->
      userAuth = new Buffer('some-uuid:some-token').toString 'base64'

      @authDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{userAuth}"
        .reply 200, uuid: 'some-uuid', token: 'some-token'

      options =
        uri: '/hello'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          username: 'some-uuid'
          password: 'some-token'
        qs:
          hasError: true
        json: true

      request.get options, (error, @response, @body) =>
        done error

    it 'should auth handler', ->
      @authDevice.done()

    it 'should return a 755 because ya', ->
      expect(@response.statusCode).to.equal 755
