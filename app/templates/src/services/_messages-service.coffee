fs          = require 'fs'
_           = require 'lodash'
path        = require 'path'
{Validator} = require 'jsonschema'

ENDO_MESSAGE_INVALID = 'Message does not match endo schema'
JOB_TYPE_UNSUPPORTED = 'That jobType is not supported'
MESSAGE_DATA_INVALID = 'Message data does not match schema for jobType'

class MessagesService
  constructor: ->
    @endoMessageSchema = @_getEndoMessageSchemaSync()
    @schemas = @_getSchemasSync()
    @validator = new Validator

  send: ({auth,message}, callback) =>
    return callback @_userError(ENDO_MESSAGE_INVALID, 422) unless @_isValidEndoMessage message
    return callback @_userError(JOB_TYPE_UNSUPPORTED, 422) unless @_isSupportedJobType message.metadata.jobType
    return callback @_userError(MESSAGE_DATA_INVALID, 422) unless @_isValidMessageData message.metadata.jobType, message.data
    callback()

  _getEndoMessageSchemaSync: =>
    filepath = path.join __dirname, '../../endo-message-schema.json'
    JSON.parse fs.readFileSync(filepath, 'utf8')

  _getSchemasSync: =>
    directory = path.join __dirname, '../../schemas'
    filenames = fs.readdirSync directory

    _.tap {}, (schemas) =>
      _.each filenames, (filename) =>
        filepath = path.join directory, filename
        schemaName = _.replace filename, /-schema.json$/, ''
        schemas[schemaName] = JSON.parse fs.readFileSync(filepath, 'utf8')

  _isSupportedJobType: (jobType) =>
    @schemas[jobType]?

  _isValidEndoMessage: (message) =>
    {errors} = @validator.validate message, @endoMessageSchema
    _.isEmpty errors

  _isValidMessageData: (jobType, data) =>
    {errors} = @validator.validate data, @schemas[jobType]
    _.isEmpty errors

  _userError: (message, code) =>
    error = new Error message
    error.code = code if code?
    return error

module.exports = MessagesService
