

module.exports = ({authorizedUuid, clientSecret, serviceUrl}) ->
  $set:
    'endo.authorizedUuid': authorizedUuid
    'endo.clientSecret'  : clientSecret
    'meshblu.forwarders.message.received': [{
      type: 'webhook'
      url:  serviceUrl
      method: 'POST'
      generateAndStoreToken: true
    }]
