# https://github.com/joycehan/strikingly-interview-test-instructions/tree/new

_ = require 'lodash'
co = require 'co'
fetch = require 'node-fetch'
Promise = require 'bluebird'

fetch.Promise = Promise

letterSortedByFrequency = 'E T A O I N S H R D L C U M W F G Y P B V K J X Q Z'.split ' '

class WordSession
  constructor: (@sessionInfo, @gamer) ->
    @worldLength = @sessionInfo.word.length
    @guess 0

  guess: (charIndex) ->
    @lastTriedCharIndex = charIndex
    @gamer.guess letterSortedByFrequency[charIndex], this

  guessResult: (data) =>
    # 如果还没猜完
    if _.contains(data.word, '*')
      # 如果超过是猜测次数就到下一个单词
      if data.wrongGuessCountOfCurrentWord is @gamer.gameInfo.numberOfGuessAllowedForEachWord
        @nextWord data

      # 否则就接着猜
      else
        @guess @lastTriedCharIndex + 1

    # 如果单词猜完了
    else
      @nextWord data

  nextWord: (lastGuessResult) -> co =>
    console.log 'lastGuessResult', JSON.stringify lastGuessResult
    if lastGuessResult.totalWordCount is @gamer.gameInfo.numberOfWordsToGuess
      console.log 'final score: ', yield @gamer.getResult()
      @gamer.submitSession()
    else
      @gamer.nextWord()

module.exports = class Gamer
  constructor: (@urlPrefix, @playerId) ->

  requestWithData: (inputData) =>
    self = this
    console.log 'send request', inputData
    body = JSON.stringify _.extend (if @sessionId then {@sessionId} else {@playerId}), inputData
    headers = 'Content-Type': 'application/json'
    fetch("#{@urlPrefix.replace /\/$/, ''}/game/on", {method: 'post', body, headers})
      .then (res) -> co ->
        resp = yield res.text()
        if 200 <= res.status < 300 then resp else Promise.reject resp
      .then (resp) ->
        JSON.parse resp
      .then (data) ->
        self.sessionId = data.sessionId if data.sessionId and not self.sessionId
        console.log 'receive data', JSON.stringify data.data
        data.data

  startGame: -> co =>
    console.log 'startGame'
    @gameInfo = yield @requestWithData action: 'startGame'
    @nextWord()

  nextWord: => co =>
    console.log 'nextWorld'
    result = yield @requestWithData action: 'nextWord'
    new WordSession result, this

  guess: (char, wordSession) -> co =>
    wordSession.guessResult yield @requestWithData action: 'guessWord', guess: char

  getResult: ->
    @requestWithData action: 'getResult'

  submitSession: ->
    @requestWithData action: 'submitResult'
