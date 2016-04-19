GitHubApi  = require 'github'
_          = require 'lodash'

class Helpers
  extractGeneratorName: (appName) =>
    _.kebabCase appName

  githubUserInfo: (user, callback) =>
    github = new GitHubApi version: '3.0.0'
    github.user.getFrom {user}, callback

module.exports = new Helpers
