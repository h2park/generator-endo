_ = require 'lodash'
passport = require 'passport-strategy'

class MockStrategy extends passport.Strategy
  authenticate: -> # keep this guy skinny
    @fail message: 'no', 302

module.exports = MockStrategy
