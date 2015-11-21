# https://github.com/joycehan/strikingly-interview-test-instructions/tree/new

_ = require 'lodash'
co = require 'co'
Promise = require 'bluebird'
GameTable = require './game_table'
WordSession = require './word_session'

module.exports = class Gamer
  constructor: (urlPrefix, playerId) ->
    @table = new GameTable urlPrefix, playerId

  startGame: -> co =>
    data = yield @table.startGame()
    {@sessionId, data: @gameInfo} = data
    @letsGuess 'next'

  letsGuess: (whichOne) ->
    promise = co =>
      if whichOne is 'next'
        wordInfo = yield @table.nextWord @sessionId
        @currWordSession = new WordSession wordInfo, this

      suggestion = @currWordSession.suggestChar()
      return @letsGuess 'next' if not suggestion

      guessResult = yield @table.guess @sessionId, suggestion.toUpperCase()
      @currWordSession.receiveResult guessResult
      if @currWordSession.isWordGuessFinished()
        @letsGuess 'next'
      else if @isSessionFinished guessResult
        @printResult()
      else
        @letsGuess()

    promise.catch (err) =>
      try
        data = JSON.parse err
      catch throwErr
        Promise.reject err
      if data?.message is 'No more guess left.'
        @letsGuess 'next'
      else
        Promise.reject err

  isSessionFinished: (guessResult) ->
    guessResult.totalWordCount is @gameInfo.numberOfWordsToGuess

  printResult: -> co =>
    console.log 'Current Score: ', JSON.stringify yield @table.getResult()
