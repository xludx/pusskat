# Description:
#   An HTTP Listener for notifications on github pushes
#
# Dependencies:
#   "url": ""
#   "querystring": ""
#   "gitio2": "2.0.0"
#
# Configuration:
#   Just put this url <HUBOT_URL>:<PORT>/hubot/gh-commits?room=<room> into you'r github hooks
#
# Commands:
#   None
#
# URLS:
#   POST /hubot/gh-commits?room=<room>[&type=<type]
#
# Authors:
#   nesQuick

url = require('url')
querystring = require('querystring')
gitio = require('gitio2')

module.exports = (robot) ->

  robot.router.post "/hubot/gh-commits", (req, res) ->
    query = querystring.parse(url.parse(req.url).query)

    res.send 200

    user = {}
    user.room = query.room if query.room
    user.type = query.type if query.type

    return if req.body.zen? # initial ping
    push = req.body
    console.log "push: " + JSON.stringify push

    try
      if push.commits.length > 0
        commitWord = if push.commits.length > 1 then "commits" else "commit"
        username = push.commits[0].author.username;
        if username == "juhkov"
          username = "ludx"
        robot.send user, "Got #{push.commits.length} new #{commitWord} from #{username} on #{push.repository.name}"
        for commit in push.commits
          do (commit) ->
            gitio commit.url, (err, data) ->
              robot.send user, "  * #{commit.message} (#{if err then commit.url else data})"
      else
        if push.created
          robot.send user, "#{push.pusher.name} created: #{push.ref}: #{push.base_ref}"
        if push.deleted
          robot.send user, "#{push.pusher.name} deleted: #{push.ref}"

    catch error
      console.log "github-commits error: #{error}. Push: #{push}"

