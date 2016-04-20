class OctobluAuthController
  storeAuthAndRedirect: (req, res) =>
    console.log 'meshblu_auth_bearer', req.user.bearerToken
    res.cookie('meshblu_auth_bearer', req.user.bearerToken)
    res.redirect '/auth/<%= instancePrefix %>'

module.exports = OctobluAuthController
