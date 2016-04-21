_ = require 'lodash'
fs           = require 'fs'
http         = require 'http'
request      = require 'request'
shmock       = require '@octoblu/shmock'
MockStrategy = require '../mock-strategy'
Server       = require '../../src/server'
Encryption   = require 'meshblu-encryption'

describe 'Sample Spec', ->
  beforeEach (done) ->
    @privateKey = fs.readFileSync "#{__dirname}/../data/private-key.pem", 'utf8'
    encryption = Encryption.fromPem @privateKey

    decryptClientSecret = (req, res, next) =>
      return next() unless req.body?.$set?['endo.clientSecret']?
      req.body.$set['endo.clientSecret'] = encryption.decryptOptions req.body.$set['endo.clientSecret']
      next()

    @meshblu = shmock 0xd00d, [decryptClientSecret]
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
        followRedirect: false
        auth:
          username: 'some-uuid'
          password: 'some-token'

      request.get options, (error, @response, @body) =>
        done error

    it 'should auth handler', ->
      @authDevice.done()

    it 'should return a 302', ->
      expect(@response.statusCode).to.equal 302

  describe 'On GET /auth/<%= instancePrefix %>/callback', ->
    describe 'when the credentials device does not exist', ->
      beforeEach (done) ->
        userAuth = new Buffer('some-uuid:some-token').toString 'base64'
        serviceAuth = new Buffer('peter:i-could-eat').toString 'base64'
        credentialsDeviceAuth = new Buffer('cred-uuid:cred-token2').toString 'base64'

        @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{userAuth}"
          .reply 200, uuid: 'some-uuid', token: 'some-token'

        @meshblu
          .post '/search/devices'
          .set 'Authorization', "Basic #{serviceAuth}"
          .send 'endo.clientID': 'oauth_token'
          .reply 200, []

        @createCredentialsDevice = @meshblu
          .post '/devices'
          .set 'Authorization', "Basic #{serviceAuth}"
          .send
            endo:
              clientID: 'oauth_token'
            meshblu:
              version: '2.0.0'
              whitelists:
                discover:
                  view: [{uuid: 'peter'}]
                configure:
                  update: [{uuid: 'peter'}]
          .reply 200, uuid: 'cred-uuid', token: 'cred-token'

        @meshblu
          .post '/devices/cred-uuid/tokens'
          .set 'Authorization', "Basic #{serviceAuth}"
          .reply 201, '{"uuid": "cred-uuid", "token": "cred-token2"}'

        @updateCredentialsDevice = @meshblu
          .put '/v2/devices/cred-uuid'
          .set 'Authorization', "Basic #{credentialsDeviceAuth}"
          .send
            '$set':
              'endo.authorizedUuid': 'some-uuid'
              'endo.clientSecret':   'oauth_verifier'
          .reply 204

        options =
          uri: '/auth/<%= instancePrefix %>/callback'
          baseUrl: "http://localhost:#{@serverPort}"
          followRedirect: false
          auth:
            username: 'some-uuid'
            password: 'some-token'
          qs:
            oauth_token: 'oauth_token'
            oauth_verifier: 'oauth_verifier'

        request.get options, (error, @response, @body) =>
          done error

      xit 'should return a 302', ->
        expect(@response.statusCode).to.equal 302

      xit 'should redirect to /', ->
        expect(@response.headers.location).to.equal '/'

      it 'should create a credentials device', ->
        @createCredentialsDevice.done()

      it 'should update the credentials device with the new clientSecret and authorizedUuid', ->
        @updateCredentialsDevice.done()

    describe 'when the credentials device does exist', ->
      beforeEach (done) ->
        userAuth = new Buffer('some-uuid:some-token').toString 'base64'

        @meshblu
          .get '/v2/whoami'
          .set 'Authorization', "Basic #{userAuth}"
          .reply 200, uuid: 'some-uuid', token: 'some-token'

        @meshblu
          .post '/search/devices'
          .send 'endo.clientID': 'oauth_token'
          .reply 200, [{uuid: 'cred-uuid', token: 'cred-token'}]

        options =
          uri: '/auth/<%= instancePrefix %>/callback'
          baseUrl: "http://localhost:#{@serverPort}"
          followRedirect: false
          auth:
            username: 'some-uuid'
            password: 'some-token'
          qs:
            oauth_token: 'oauth_token'
            oauth_verifier: 'oauth_verifier'

        request.get options, (error, @response, @body) =>
          done error

      xit 'should return a 302', ->
        expect(@response.statusCode).to.equal 302

      xit 'should redirect to /', ->
        expect(@response.headers.location).to.equal '/'
