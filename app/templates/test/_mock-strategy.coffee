_ = require 'lodash'
passport = require 'passport-strategy'

class MockStrategy extends passport.Strategy
  authenticate: (req, options) -> # keep this guy skinny
    return @success({}) if req.query.oauth_token?
    @fail message: 'no', 302

module.exports = MockStrategy
