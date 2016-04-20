GitHubApi  = require 'github'
_          = require 'lodash'

class Helpers
  extractEndoName: (appName) =>
    _.kebabCase appName

  githubUserInfo: (user, callback) =>
    github = new GitHubApi version: '3.0.0'

    unless _.isEmpty process.env.GITHUB_TOKEN
      github.authenticate
        type: 'oauth'
        token: process.env.GITHUB_TOKEN
        
    github.user.getFrom {user}, callback

module.exports = new Helpers
