fs   = require 'fs'
http = require 'http'
_    = require 'lodash'
path = require 'path'

NOT_FOUND_RESPONSE = {metadata: {code: 404, status: http.STATUS_CODES[404]}}

class MessageHandlers
  constructor: ->
    @jobs = @_getJobs()

  onMessage: ({data, encrypted, metadata}, callback) =>
    job = @jobs[metadata.jobType]
    return callback null, NOT_FOUND_RESPONSE unless job?

    job.action {data, encrypted, metadata}, (error, response) =>
      return callback error if error?
      return callback null, _.pick(response, 'data', 'metadata')

  _getJobs: =>
    dirnames = fs.readdirSync path.join(__dirname, './jobs')
    jobs = {}
    _.each dirnames, (dirname) =>
      key = _.upperFirst _.camelCase dirname
      dir = path.join 'jobs', dirname
      jobs[key] = require "./#{dir}"
    return jobs

module.exports = MessageHandlers
