Github = require 'github'
http   = require 'http'
_      = require 'lodash'

class GetUserEvents
  constructor: ({@encrypted}) ->
    console.log '@encrypted', JSON.stringify @encrypted
    @github = new Github
      debug: true
    @github.authenticate type: 'oauth', token: @encrypted.secrets.credentials.secret


  do: ({data}, callback) =>
    return callback @_userError(422, 'data.username is required') unless data.username?

    @github.activity.getEventsForUser {user: data.username}, (error, results) =>
      return callback error if error?
      return callback null, {
        metadata:
          code: 200
          status: http.STATUS_CODES[200]
        data: @_processResults results
      }

  _processResult: (result) =>
    {
      type:        result.type
      username:    result.actor.display_login
      repo_name:   result.repo.name
      commit_ref:  result.payload.ref
      commit_sha:  result.payload.head
      created_at:  result.created_at
      description: result.payload.description
    }

  _processResults: (results) =>
    _.map results, @_processResult

  _userError: (code, message) =>
    error = new Error message
    error.code = code
    return error

module.exports = GetUserEvents
