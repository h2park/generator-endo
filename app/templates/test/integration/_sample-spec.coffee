http         = require 'http'
request      = require 'request'
shmock       = require '@octoblu/shmock'
MockStrategy = require '../mock-strategy'
Server       = require '../../src/server'

describe 'Sample Spec', ->
  beforeEach (done) ->
    @meshblu = shmock 0xd00d
    @oauth = shmock 0xcafe

    @apiStrategy = new MockStrategy name: '<%= instancePrefix %>'

    serverOptions =
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
      meshbluConfig:
        server: 'localhost'
        port: 0xd00d
        token: 'peter'

    @server = new Server serverOptions

    @server.run (error) =>
      return done error if error?
      @serverPort = @server.address().port
      done()

  afterEach (done) ->
    @server.stop done

  afterEach (done) ->
    @oauth.close done

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

      it 'should return a 302', ->
        expect(@response.statusCode).to.equal 302, @body

      it 'should redirect to oauth.octoblu.xxx/authorize', ->
        expect(@response.headers.location).to.equal(
          'http://oauth.octoblu.xxx/authorize?response_type=code&client_id=client-id'
        )

    describe 'On GET /auth/octoblu/callback with a valid code', ->
      beforeEach (done) ->
        @oauth
          .post '/access_token'
          .send
            code: new Buffer('client-id:u:t1').toString 'base64'
            grant_type: 'authorization_code'
            client_id: 'client-id'
            client_secret: '12345'
          .reply 200,
            token_type:   "bearer"
            access_token:  new Buffer('u:t2').toString 'base64'
            expires_in:    3600

        @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Bearer #{new Buffer('u:t2').toString 'base64'}"
          .reply 200, {}

        options =
          baseUrl: "http://localhost:#{@serverPort}"
          followRedirect: false
          qs:
            code: new Buffer('client-id:u:t1').toString 'base64'

        request.get '/auth/octoblu/callback', options, (error, @response, @body) =>
          done error

      it 'should return a 302', ->
        expect(@response.statusCode).to.equal 302

      it 'should redirect to /auth/twitter', ->
        expect(@response.headers.location).to.equal '/auth/twitter'

      it 'should set the meshblu auth cookies', ->
        expect(@response.headers['set-cookie']).to.contain 'meshblu_auth_bearer=dTp0Mg%3D%3D; Path=/'

  describe 'On GET /auth/<%= instancePrefix %>', ->
    beforeEach (done) ->
      userAuth = new Buffer('some-uuid:some-token').toString 'base64'

      @authDevice = @meshblu
        .get '/v2/whoami'
        .set 'Authorization', "Basic #{userAuth}"
        .reply 200, uuid: 'some-uuid', token: 'some-token'

      options =
        uri: '/auth/<%= instancePrefix %>'
        baseUrl: "http://localhost:#{@serverPort}"
        auth:
          username: 'some-uuid'
          password: 'some-token'
        json: true

      request.get options, (error, @response, @body) =>
        done error

    it 'should auth handler', ->
      @authDevice.done()

    it 'should return a 302', ->
      expect(@response.statusCode).to.equal 302

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
