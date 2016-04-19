class CredentialsController
  authenticate: (req, res) =>
    res.cookie('meshblu_auth_bearer', req.user.bearerToken)
    res.redirect '/auth/<%= instancePrefix %>'

module.exports = CredentialsController
