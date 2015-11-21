Gamer = require './gamer'
playerInfo = require '../player_info'

gamer = new Gamer playerInfo.host, playerInfo.player_id
gamer.startGame().catch (err) ->
  console.error err.stack
