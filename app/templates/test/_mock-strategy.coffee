_ = require 'lodash'
passport = require 'passport-strategy'

class MockStrategy extends passport.Strategy
  authenticate: (req, options) -> # keep this guy skinny
    return @success({clientID:req.query.oauth_token, clientSecret:req.query.oauth_verifier}) if req.query.oauth_token?
    @fail message: 'no', 302

module.exports = MockStrategy
