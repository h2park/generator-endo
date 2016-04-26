_    = require 'lodash'
fs   = require 'fs'
path = require 'path'

class SchemaLoader
  constructor: ({@schemaDir}={}) ->
    throw new Error('schemaDir is required') unless @schemaDir

  getSchemasSync: =>
    filenames = fs.readdirSync @schemaDir
    _.tap {}, (schemas) =>
      _.each filenames, (filename) =>
        filepath = path.join @schemaDir, filename
        schemaName = _.camelCase(_.replace filename, /-schema.json$/, '')
        schemas[schemaName] = JSON.parse fs.readFileSync(filepath, 'utf8')

module.exports = SchemaLoader
