http = require 'http'

class GetUserEvents
  constructor: ({@options}) ->

  do: ({data}, callback) =>
    console.log 'GetUserEvents', JSON.stringify {data}
    callback null, {
      metadata:
        code: 501
        status: http.STATUS_CODES[501]
    }


module.exports = GetUserEvents
