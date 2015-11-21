
_ = require 'lodash'
co = require 'co'
fetch = require 'node-fetch'
Promise = require 'bluebird'
fetch.Promise = Promise

module.exports = class GameTable
  constructor: (@urlPrefix, @playerId) ->

  requestWithData: (inputData, options = {}) =>
    console.log 'send request', do ->
      data = _.clone inputData
      delete data.playerId
      delete data.sessionId
      JSON.stringify data

    self = this
    body = JSON.stringify inputData
    headers = 'Content-Type': 'application/json'
    fetch("#{@urlPrefix.replace /\/$/, ''}/game/on", {method: 'post', body, headers})
      .then (res) -> co ->
        resp = yield res.text()
        if 200 <= res.status < 300 then resp else Promise.reject resp
      .then (resp) ->
        JSON.parse resp
      .then (data) ->
        console.log 'receive data', JSON.stringify data.data
        if options.unpackData isnt false then data.data else data

  startGame: ->
    console.log 'startGame'
    @requestWithData {action: 'startGame', @playerId}, unpackData: false

  nextWord: (sessionId) ->
    console.log 'nextWorld'
    @requestWithData {action: 'nextWord', sessionId}

  guess: (sessionId, char) ->
    @requestWithData {action: 'guessWord', guess: char, sessionId}

  getResult: (sessionId) ->
    @requestWithData {action: 'getResult', sessionId}

  submitSession: (sessionId) ->
    @requestWithData {action: 'submitResult', sessionId}
